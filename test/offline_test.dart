import 'package:dio/dio.dart';
import 'package:farah/cubits/home/home_cubit.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';
import 'package:farah/data/datasources/local/offline_cache.dart';
import 'package:farah/data/models/home/home_response_model.dart';
import 'package:farah/data/repositories/home_repostory.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/provider_router_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// فرح: بدون نت: المزود ما بيرجع لشاشة التسجيل، والشاشات بتعرض آخر بيانات محفوظة.
DioException _offline(String path) => DioException(
  requestOptions: RequestOptions(path: path),
  type: DioExceptionType.connectionError,
);

class _OfflineHome implements HomeRepository {
  @override
  Future<HomeResponseModel> fetchHome() async => throw _offline('/home');

  @override
  Future<HomeResponseModel?> cachedHome() async =>
      HomeResponseModel.fromJson({'categories': []});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OfflineProvider implements ProviderRepository {
  @override
  Future<Map<String, dynamic>> getVerificationStatus() async =>
      throw _offline('/provider/verification');

  @override
  Future<Map<String, dynamic>> getDashboardData() async =>
      throw _offline('/provider/dashboard');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpRouter(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider(
        create: (_) => ProviderVerificationCubit(_OfflineProvider()),
        child: const ProviderRouterScreen(),
      ),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(body: Text('route ${settings.name}')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('home shows the last saved data without internet', () async {
    final cubit = HomeCubit(_OfflineHome());
    await cubit.loadHome();
    expect(cubit.state, isA<HomeLoaded>());
    expect((cubit.state as HomeLoaded).offline, isTrue);
  });

  test(
    'provider dashboard shows the last saved data without internet',
    () async {
      await OfflineCache.save(OfflineCache.providerDashboard, {
        'provider': {'business_name': 'api store'},
      });
      final cubit = ProviderDashboardCubit(_OfflineProvider());
      await cubit.loadDashboard();
      final state = cubit.state as ProviderDashboardLoaded;
      expect(state.offline, isTrue);
      expect(state.data['provider']['business_name'], 'api store');
    },
  );

  testWidgets('an approved provider opens home offline, not sign-up', (
    tester,
  ) async {
    await OfflineCache.save(OfflineCache.providerVerification, {
      'status': 'approved',
      'next_step': '',
    });
    await _pumpRouter(tester);
    expect(find.text('route /provider/home'), findsOneWidget);
    expect(find.text('route /provider/onboarding'), findsNothing);
  });

  testWidgets('without saved status it says offline and offers retry', (
    tester,
  ) async {
    await _pumpRouter(tester);
    expect(find.text('لا يوجد اتصال بالإنترنت'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.text('route /provider/onboarding'), findsNothing);
  });

  test('saved screens are wiped on logout', () async {
    await OfflineCache.save(OfflineCache.home, {'a': 1});
    await OfflineCache.clear();
    expect(await OfflineCache.read(OfflineCache.home), isNull);
  });
}
