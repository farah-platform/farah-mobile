import 'package:dio/dio.dart';
import 'package:farah/cubits/vendor/vendor_details_cubit.dart';
import 'package:farah/data/models/vendor/public_provider_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:farah/view/screens/user/vendor_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: صفحة المزود من GET /providers/{id}، وبدون بيانات بديلة عند الخطأ.
class _Repo implements ServiceRepository {
  final List<int> requested = [];
  bool fail = false;

  @override
  Future<PublicProviderModel> fetchPublicProvider(int providerId) async {
    requested.add(providerId);
    if (fail) {
      final request = RequestOptions(path: '/providers/$providerId');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 404),
      );
    }
    return PublicProviderModel.fromJson({
      'id': providerId,
      'name': 'api store',
      'specialty': 'api category',
      'rating': 4.8,
      'services': [
        {'id': 5, 'title': 'api service', 'price': 300, 'currency': 'ILS'},
      ],
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, _Repo repo) async {
  tester.view.physicalSize = const Size(412, 884);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => VendorDetailsCubit(repo),
        child: const VendorDetailsScreen(
          vendorId: 42,
          initialVendorName: 'card name',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('reads the public provider and its services', () {
    final provider = PublicProviderModel.fromJson({
      'id': 42,
      'name': 'api store',
      'reviews_count': 4,
      'services': [
        {'id': 1, 'title': 'a'},
        {'id': 2, 'title': 'b'},
      ],
    });
    expect(provider.services.map((s) => s.title), ['a', 'b']);
    expect(provider.reviewsCount, 4);
  });

  testWidgets('shows the store and services from the API', (tester) async {
    final repo = _Repo();
    await _pump(tester, repo);

    expect(repo.requested, [42]);
    expect(find.text('api store'), findsWidgets);
    expect(find.text('api service'), findsOneWidget);
  });

  testWidgets('an unavailable provider shows an error, not made-up data', (
    tester,
  ) async {
    final repo = _Repo()..fail = true;
    await _pump(tester, repo);

    expect(find.text('هذا المزود غير متاح حالياً'), findsOneWidget);
    expect(find.text('api service'), findsNothing);
  });
}
