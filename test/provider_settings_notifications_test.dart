import 'dart:typed_data';

import 'package:farah/cubits/notification/notification_cubit.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_external_booking/provider_external_booking_cubit.dart';
import 'package:farah/cubits/provider_orders/provider_order_details_cubit.dart';
import 'package:farah/cubits/provider_settings/provider_settings_cubit.dart';
import 'package:farah/cubits/provider_settings/provider_store_settings_cubit.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/data/repositories/notification_repository.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/notifications/provider_notifications_screen.dart';
import 'package:farah/view/screens/provider/orders/provider_external_booking_screen.dart';
import 'package:farah/view/screens/provider/orders/provider_payment_review_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_payout_account_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_settings_screen.dart';
import 'package:farah/view/widgets/provider/provider_month_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// A 1x1 transparent PNG, standing in for the uploaded transfer proof.
final _png = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

class _FakeRepo implements ProviderRepository {
  final List<String> calls = [];
  Map<String, dynamic>? externalBooking;
  bool overdue = false;
  bool notifications = true;

  @override
  Future<Map<String, dynamic>> getDashboardData() async => {
    'provider': {
      'business_name': 'api store',
      'category': {'name': 'api category'},
      'payout_account': {
        'bank_name': 'api bank',
        'account_number': 'api account',
        'iban': 'api iban',
      },
    },
    'subscription': {'is_active': true},
  };

  @override
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async => {
    'id': bookingId,
    'status': 'review_under_proof',
    'expires_at': overdue
        ? DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()
        : DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
    'customer': {'name': 'api customer'},
    'service': {'title': 'api service'},
    'pricing': {'currency': 'ILS'},
    'payments': [
      {'id': 3, 'amount': 800, 'status': 'submitted', 'proof_type': 'image'},
    ],
  };

  @override
  Future<List<int>> getPaymentProof(int bookingId, int paymentId) async => _png;

  @override
  Future<void> reviewPaymentProof(
    int bookingId,
    int paymentId,
    String decision, {
    String? reviewNote,
  }) async => calls.add('review:$decision:${reviewNote ?? ''}');

  @override
  Future<List<dynamic>> getProviderServices() async => [
    {'id': 5, 'title': 'api hall'},
  ];

  @override
  Future<Map<String, dynamic>> getServiceAvailability(
    int serviceId,
    String month,
  ) async {
    final next = DateTime(DateTime.now().year, DateTime.now().month + 1, 10);
    return {
      'unavailable_dates': [
        {'date': ProviderMonthCalendar.dateKey(next)},
      ],
      'reserved_dates': {},
    };
  }

  @override
  Future<void> addExternalBooking(Map<String, dynamic> data) async =>
      externalBooking = data;

  @override
  Future<bool> getNotificationsEnabled() async => notifications;

  @override
  Future<void> setNotificationsEnabled(bool enabled) async =>
      calls.add('notifications:$enabled');

  @override
  Future<Map<String, dynamic>> getOnboardingData() async => {'profile': {}};

  @override
  Future<List<dynamic>> getCities() async => [];

  @override
  Future<void> updatePayoutAccount({
    required String bankName,
    required String accountNumber,
    String? iban,
  }) async => calls.add('payout:$bankName:$accountNumber:$iban');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeNotifications implements NotificationRepository {
  final List<String> read = [];

  @override
  Future<List<NotificationModel>> fetchNotifications() async => [
    NotificationModel(
      id: '1',
      title: 'اشعار دفع من api customer',
      body: 'بانتظار المراجعة',
      isRead: false,
      type: NotificationType.paymentProofSubmitted,
      referenceId: '9',
      resourceType: 'booking',
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    NotificationModel(
      id: '2',
      title: 'api overdue',
      body: 'يرجى المراجعة في اقرب وقت',
      isRead: true,
      type: NotificationType.paymentReviewOverdue,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<void> markAsRead(String id) async => read.add(id);

  @override
  Future<void> markAllAsRead() async {}
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(412, 884);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(textDirection: TextDirection.rtl, child: child),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Text('route ${settings.name} ${settings.arguments}'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('notification times read like the design', () {
    final now = DateTime(2026, 10, 19, 15, 0);
    expect(
      notificationTimeLabel(DateTime(2026, 10, 19, 14, 48), now: now),
      'منذ 12 دقيقة',
    );
    expect(
      notificationTimeLabel(DateTime(2026, 10, 19, 14, 0), now: now),
      'منذ ساعة',
    );
    expect(
      notificationTimeLabel(DateTime(2026, 10, 18, 21, 15), now: now),
      'أمس 9:15 م',
    );
  });

  testWidgets('notifications open the payment review for proofs', (
    tester,
  ) async {
    final repo = _FakeNotifications();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => NotificationCubit(repo),
        child: const ProviderNotificationsScreen(),
      ),
    );

    expect(
      find.text('تابع دفعات الحجوزات واتخذ الاجراء المناسب'),
      findsOneWidget,
    );
    expect(find.text('اشعار دفع من api customer'), findsOneWidget);
    expect(find.text('منذ 12 دقيقة'), findsOneWidget);
    await tester.tap(find.text('اشعار دفع من api customer'));
    await tester.pumpAndSettle();
    expect(repo.read, ['1']);
    expect(find.text('route /provider/payment-review 9'), findsOneWidget);
  });

  Widget review(_FakeRepo repo) => BlocProvider(
    create: (_) => ProviderOrderDetailsCubit(repo, 9),
    child: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProviderOrderDetailsCubit>(),
                child: const ProviderPaymentReviewScreen(),
              ),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );

  testWidgets('payment review shows transfer details and accepts', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(tester, review(repo));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('انتهت مهلة المراجعة(24 ساعة)'), findsNothing);
    expect(find.text('api customer'), findsOneWidget);
    expect(find.text('800ILS'), findsOneWidget);
    expect(find.text('api bank'), findsOneWidget);
    expect(find.text('api iban'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.ensureVisible(find.text('قبول الاشعار'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('قبول الاشعار'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['review:confirmed:']);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('overdue review shows the warning and rejects with a reason', (
    tester,
  ) async {
    final repo = _FakeRepo()..overdue = true;
    await _pump(tester, review(repo));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('انتهت مهلة المراجعة(24 ساعة)'), findsOneWidget);
    await tester.ensureVisible(find.text('رفض'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('رفض'));
    await tester.pumpAndSettle();
    expect(find.text('سبب الرفض'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'api reason');
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الرفض'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['review:rejected:api reason']);
  });

  testWidgets('external booking blocks the chosen service date', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderExternalBookingCubit(repo),
        child: const ProviderExternalBookingScreen(),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'api name');
    await tester.enterText(fields.at(1), 'api phone');
    await tester.tap(find.text('أختر الخدمة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('api hall').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(2), '900');
    await tester.enterText(fields.at(3), '300');
    await tester.pumpAndSettle();
    expect(find.text('600'), findsOneWidget);

    // Next month: the 10th is taken, the 12th is free.
    await tester.ensureVisible(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10'));
    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('إضافة الحجز'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('إضافة الحجز'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    expect(repo.externalBooking, {
      'customer_name': 'api name',
      'customer_phone': 'api phone',
      'service_id': 5,
      'booking_date': ProviderMonthCalendar.dateKey(
        DateTime(now.year, now.month + 1, 12),
      ),
      'total_price': 900.0,
      'deposit_amount': 300.0,
      'payment_method': null,
      'status': 'confirmed',
      'notes': '',
    });
  });

  testWidgets('settings show the store and save the notifications switch', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ProviderDashboardCubit(repo)..loadDashboard(),
          ),
          BlocProvider(create: (_) => ProviderSettingsCubit(repo)),
        ],
        child: const Scaffold(body: ProviderSettingsScreen()),
      ),
    );

    expect(find.text('api store'), findsOneWidget);
    expect(find.text('الاشتراك نشط'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(repo.calls, ['notifications:false']);

    await tester.ensureVisible(find.text('حساب استلام الارباح'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حساب استلام الارباح'));
    await tester.pumpAndSettle();
    expect(find.text('route /provider/payout-account null'), findsOneWidget);
  });

  testWidgets('payout account is prefilled and saved', (tester) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderStoreSettingsCubit(repo),
        child: const ProviderPayoutAccountScreen(),
      ),
    );

    expect(find.text('api bank'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '42');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['payout:api bank:42:api iban']);
  });
}
