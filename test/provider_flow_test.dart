import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/cubits/provider_onboarding/provider_onboarding_cubit.dart';
import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/repositories/api_provider_repository.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoTokenCache extends CacheDatasource {
  @override
  Future<String?> getToken() async => null;
}

/// Records every request and answers it without touching the network.
class _Recorder extends Interceptor {
  final List<RequestOptions> requests = [];
  final Map<String, dynamic> Function(RequestOptions) respond;
  final int statusCode;

  _Recorder(this.respond, {this.statusCode = 200});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    final response = Response(
      requestOptions: options,
      statusCode: statusCode,
      data: respond(options),
    );
    if (statusCode >= 400) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    } else {
      handler.resolve(response);
    }
  }
}

(ApiProviderRepository, _Recorder) _repo(
  Map<String, dynamic> Function(RequestOptions) respond, {
  int statusCode = 200,
}) {
  final client = DioClient(_NoTokenCache());
  final recorder = _Recorder(respond, statusCode: statusCode);
  client.dio.interceptors.add(recorder);
  return (ApiProviderRepository(dioClient: client), recorder);
}

Future<File> _tempImage(String name) async {
  final dir = await Directory.systemTemp.createTemp('farah_test');
  return File('${dir.path}/$name')..writeAsBytesSync([0xFF, 0xD8, 0xFF]);
}

void main() {
  test('provider endpoints no longer double the /api prefix', () async {
    final (repo, recorder) = _repo((_) => {'data': <String, dynamic>{}});
    await repo.getDashboardData();
    await repo.getVerificationStatus();
    for (final r in recorder.requests) {
      expect(r.uri.path.contains('/api/api/'), isFalse, reason: r.uri.path);
      expect(r.path.startsWith('/provider/'), isTrue);
    }
  });

  test('onboarding loads categories and cities from the API', () async {
    final (repo, recorder) = _repo(
      (o) => {
        'data': o.path == '/categories'
            ? [
                {'id': 11, 'name': 'from api category'},
              ]
            : [
                {'id': 22, 'name': 'from api city'},
              ],
      },
    );
    final cubit = ProviderOnboardingCubit(repo);
    await cubit.loadData();

    final state = cubit.state as ProviderOnboardingLoaded;
    expect(state.categories.single['id'], 11);
    expect(state.cities.single['id'], 22);
    expect(
      recorder.requests.map((r) => r.path),
      containsAll(['/categories', '/cities']),
    );
  });

  test('onboarding sends the field names the API validates', () async {
    final (repo, recorder) = _repo((_) => {'data': <String, dynamic>{}});
    final cubit = ProviderOnboardingCubit(repo);
    await cubit.submit(
      businessName: 'name',
      categoryId: '11',
      description: 'desc',
      cityId: '22',
      address: 'street',
      idProof: await _tempImage('id.jpg'),
      profitAccount: '123',
      commercialRegister: '999',
      coverImage: await _tempImage('cover.jpg'),
    );

    expect(cubit.state, isA<ProviderOnboardingSuccess>());
    final form = recorder.requests.single.data as FormData;
    final fields = Map.fromEntries(form.fields);
    expect(fields['address'], 'street');
    expect(fields.containsKey('commercial_register'), isFalse);
    // فرح: الرقم المكتوب ينبعت كـ commercial_register_number.
    expect(fields['commercial_register_number'], '999');
    expect(
      form.files.map((f) => f.key),
      containsAll(['identity_document', 'cover_image']),
    );
    expect(form.files.map((f) => f.key), isNot(contains('id_proof')));
  });

  test('onboarding shows the API validation message', () async {
    final (repo, _) = _repo(
      (_) => {'icon': 'error', 'title': 'api says address is required'},
      statusCode: 422,
    );
    final cubit = ProviderOnboardingCubit(repo);
    await cubit.submit(
      businessName: 'name',
      categoryId: '11',
      description: 'desc',
      cityId: '22',
      address: '',
      idProof: await _tempImage('id.jpg'),
      profitAccount: '',
      coverImage: await _tempImage('cover.jpg'),
    );
    expect(
      (cubit.state as ProviderOnboardingError).message,
      'api says address is required',
    );
  });

  test('subscription sends the plan slug only', () async {
    final (repo, recorder) = _repo((_) => {'data': <String, dynamic>{}});
    final cubit = ProviderSubscriptionCubit(repo);
    await cubit.activateSubscription(planSlug: 'monthly');

    expect(cubit.state, isA<ProviderSubscriptionSuccess>());
    expect((cubit.state as ProviderSubscriptionSuccess).pendingReview, isFalse);
    expect(recorder.requests.single.path, '/provider/subscription');
    expect(recorder.requests.single.data, {'plan': 'monthly'});
  });

  test('subscription surfaces the 409 message from the API', () async {
    final (repo, _) = _repo(
      (_) => {'status': false, 'message': 'free month already used'},
      statusCode: 409,
    );
    final cubit = ProviderSubscriptionCubit(repo);
    await cubit.activateSubscription(planSlug: 'monthly');
    expect(
      (cubit.state as ProviderSubscriptionError).message,
      'free month already used',
    );
  });

  test('paid plan sends the transfer proof and waits for review', () async {
    final (repo, recorder) = _repo(
      (_) => {
        'data': <String, dynamic>{'id': 3, 'status': 'submitted'},
      },
    );
    final cubit = ProviderSubscriptionCubit(repo);
    await cubit.activateSubscription(
      planSlug: 'yearly',
      proof: await _tempImage('transfer.jpg'),
    );

    expect((cubit.state as ProviderSubscriptionSuccess).pendingReview, isTrue);
    final req = recorder.requests.single;
    expect(req.path, '/provider/subscription');
    final form = req.data as FormData;
    expect(Map.fromEntries(form.fields), {'plan': 'yearly'});
    expect(form.files.single.key, 'proof');
  });

  test('bank details come from the public settings', () async {
    final (repo, recorder) = _repo(
      (_) => {
        'data': {
          'bank_transfer': {
            'bank_name': 'api bank',
            'account_number': null,
            'iban': 'api iban',
          },
        },
      },
    );
    final cubit = ProviderSubscriptionCubit(repo);
    await cubit.fetchBankDetails();

    expect(recorder.requests.single.path, '/settings');
    final bank = (cubit.state as ProviderSubscriptionBankLoaded).bank;
    expect(bank['bank_name'], 'api bank');
    expect(bank['iban'], 'api iban');
  });

  test(
    'empty plan list stays empty instead of showing placeholder plans',
    () async {
      final ProviderRepository repo = _repo((_) => {'data': []}).$1;
      final cubit = ProviderSubscriptionCubit(repo);
      await cubit.fetchPlans();
      expect((cubit.state as ProviderSubscriptionPlansLoaded).plans, isEmpty);
    },
  );

  test('service update uses POST without method spoofing', () async {
    final (repo, recorder) = _repo((_) => {'data': <String, dynamic>{}});
    await repo.updateProviderService(4, {'title': 't'}, []);
    final req = recorder.requests.single;
    expect(req.method, 'POST');
    expect(req.path, '/provider/services/4');
    final fields = Map.fromEntries((req.data as FormData).fields);
    expect(fields.containsKey('_method'), isFalse);
  });

  test('visibility sends the is_available flag the API requires', () async {
    final (repo, recorder) = _repo((_) => {'data': <String, dynamic>{}});
    await repo.toggleServiceVisibility(4, false);
    final req = recorder.requests.single;
    expect(req.method, 'PATCH');
    expect(req.path, '/provider/services/4/visibility');
    expect(req.data, {'is_available': false});
  });
}
