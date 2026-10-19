import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/provider_activate_subscription_screen.dart';
import 'package:farah/view/screens/provider/provider_subscription_plans_screen.dart';
import 'package:farah/view/screens/provider/provider_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ProviderRepository {
  Map<String, dynamic> bank = {};
  final List<String> activated = [];

  @override
  Future<List<dynamic>> getSubscriptionPlans() async => [
    {
      'slug': 'trial',
      'name': 'api trial',
      'description': 'api trial text',
      'price': '0.00',
      'currency': 'ILS',
      'interval': 'month',
    },
    {
      'slug': 'm',
      'name': 'api monthly',
      'price': '100.00',
      'currency': 'ILS',
      'interval': 'month',
      'features': [
        {'name': 'api feature on', 'included': true},
        {'name': 'api feature off', 'included': false},
      ],
    },
    {
      'slug': 'y',
      'name': 'api yearly',
      'price': '175.00',
      'currency': 'ILS',
      'interval': 'year',
      'features': [
        {'name': 'api yearly feature', 'included': true},
      ],
    },
  ];

  @override
  Future<Map<String, dynamic>> getBankTransferDetails() async => bank;

  @override
  Future<Map<String, dynamic>> activateSubscription(
    String planSlug, {
    dynamic proof,
  }) async {
    activated.add(planSlug);
    return {'status': 'trialing'};
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async => {
    'status': 'pending',
    'title': 'api badge',
    'message': 'api review message',
    'next_step': 'wait',
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(412, 884);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(textDirection: TextDirection.rtl, child: child),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Text('route ${settings.name}'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('verification shows the API status', (tester) async {
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderVerificationCubit(_FakeRepo()),
        child: const ProviderVerificationScreen(),
      ),
    );

    expect(find.text('حالة التدقيق الحالية'), findsOneWidget);
    expect(find.text('api badge'), findsOneWidget);
    expect(find.text('api review message'), findsOneWidget);
  });

  testWidgets('plans: monthly open by default, toggle opens yearly', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderSubscriptionCubit(repo),
        child: const ProviderSubscriptionPlansScreen(),
      ),
    );

    expect(find.text('api trial'), findsOneWidget);
    expect(find.text('100 ILS'), findsOneWidget);
    expect(find.text('api feature off'), findsOneWidget);
    expect(find.text('api yearly feature'), findsNothing);

    await tester.tap(find.text('سنوي'));
    await tester.pumpAndSettle();
    expect(find.text('175 ILS'), findsOneWidget);
    expect(find.text('api yearly feature'), findsOneWidget);
    expect(find.text('api feature off'), findsNothing);
  });

  testWidgets('plans: the free month activates without a transfer', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderSubscriptionCubit(repo),
        child: const ProviderSubscriptionPlansScreen(),
      ),
    );

    await tester.tap(find.text('api trial'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تفعيل الاشتراك'));
    await tester.pumpAndSettle();
    expect(repo.activated, ['trial']);
    expect(find.text('route /provider/subscription-success'), findsOneWidget);
  });

  testWidgets('activation hides payment when no bank account is set', (
    tester,
  ) async {
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderSubscriptionCubit(_FakeRepo()),
        child: const ProviderActivateSubscriptionScreen(plan: {'slug': 'm'}),
      ),
    );

    expect(find.text('هذه الميزة غير متاحة حالياً'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('activation shows the bank account from the API', (
    tester,
  ) async {
    final repo = _FakeRepo()
      ..bank = {
        'bank_name': 'api bank',
        'account_number': 'api account',
        'iban': 'api iban',
      };
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderSubscriptionCubit(repo),
        child: const ProviderActivateSubscriptionScreen(plan: {'slug': 'm'}),
      ),
    );

    expect(find.text('api bank'), findsOneWidget);
    expect(find.text('api account'), findsOneWidget);
    expect(find.text('api iban'), findsOneWidget);

    // No receipt yet: nothing is sent.
    await tester.tap(find.text('تأكيد'));
    await tester.pump();
    expect(repo.activated, isEmpty);
    expect(find.text('الرجاء رفع إشعار التحويل البنكي'), findsOneWidget);
  });
}
