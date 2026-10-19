import 'dart:convert';

import 'package:farah/core/utils/arabic_date.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_cubit.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/provider_home_screen.dart';
import 'package:farah/view/screens/provider/services/provider_add_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _dashboard({bool withData = false}) => {
  'provider': {
    'business_name': 'api store',
    'category': {'id': 3, 'name': 'api category'},
    'is_bookable': withData,
  },
  'subscription': {
    'is_active': true,
    'days_remaining': withData ? 20 : 30,
    'starts_at': '2026-10-01T00:00:00Z',
    'ends_at': '2026-10-31T00:00:00Z',
  },
  'counts': {
    'new_orders': withData ? 4 : 0,
    'new_orders_today': withData ? 2 : 0,
    'services': withData ? 2 : 0,
  },
  'rating': {'average': 0, 'count': 0},
  'store_stats': {
    'completed_bookings': withData ? 7 : 0,
    'avg_response_minutes': withData ? 60 : null,
    'commitment_rate': withData ? 67 : null,
  },
  'unread_notifications': 0,
  'latest_orders': withData
      ? [
          {
            'id': 1,
            'status': 'provider_pending',
            'customer': {'name': 'api customer'},
            'service': {'title': 'api service'},
            'date': '2026-10-17',
            'total': 600,
            'currency': 'ILS',
          },
        ]
      : [],
};

Map<String, dynamic> _service({
  required int id,
  required String title,
  bool published = true,
}) => {
  'id': id,
  'title': title,
  'type': 'service',
  'description': 'api description',
  'category': {'id': 3, 'name': 'api category'},
  'images': [],
  'cover_image': null,
  'features': ['api feature'],
  'feature_items': [
    {'name': 'api feature', 'removable': true},
  ],
  'pricing': {'price': 600, 'original_price': 800, 'currency': 'ILS'},
  'execution_duration': 'api duration',
  'is_published': published,
  'is_draft': false,
};

class _FakeRepo implements ProviderRepository {
  final bool withData;
  final List<(int, bool)> visibility = [];
  Map<String, dynamic>? added;
  (int, Map<String, dynamic>)? updated;

  _FakeRepo({this.withData = false});

  @override
  Future<Map<String, dynamic>> getDashboardData() async =>
      _dashboard(withData: withData);

  @override
  Future<List<dynamic>> getProviderServices() async => withData
      ? [
          _service(id: 1, title: 'api active'),
          _service(id: 2, title: 'api paused', published: false),
        ]
      : [];

  @override
  Future<List<dynamic>> getCategories() async => [
    {'id': 3, 'name': 'api category'},
    {'id': 4, 'name': 'api other'},
  ];

  @override
  Future<void> toggleServiceVisibility(int id, bool isAvailable) async =>
      visibility.add((id, isAvailable));

  @override
  Future<void> addProviderService(
    Map<String, dynamic> data,
    List<dynamic> images,
  ) async => added = data;

  @override
  Future<void> updateProviderService(
    int id,
    Map<String, dynamic> data,
    List<dynamic> newImages,
  ) async => updated = (id, data);

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
        builder: (_) => Scaffold(body: Text('route ${settings.name}')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget _home(_FakeRepo repo) => MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => ProviderDashboardCubit(repo)),
    BlocProvider(create: (_) => ProviderServicesCubit(repo)),
  ],
  child: const ProviderHomeScreen(),
);

void main() {
  test('dates use the design format with Western digits', () {
    expect(formatArabicDate(DateTime(2026, 10, 17)), 'السبت، 17 أكتوبر 2026');
  });

  testWidgets('home without services invites the provider to add one', (
    tester,
  ) async {
    await _pump(tester, _home(_FakeRepo()));

    expect(find.text('اهلا بك api store'), findsOneWidget);
    expect(find.text('api category'), findsOneWidget);
    expect(find.text('متاح للحجز'), findsNothing);
    expect(find.text('متبقي 30يوم لإنهاء الاشتراك'), findsOneWidget);
    expect(find.text('ابدأ بإضافة خدماتك ليصلك أول طلب'), findsOneWidget);

    await tester.tap(find.text('أضف الآن'));
    await tester.pumpAndSettle();
    expect(find.text('route /provider/add-service'), findsOneWidget);
  });

  testWidgets('home shows API orders, counts and the bookable chip', (
    tester,
  ) async {
    await _pump(tester, _home(_FakeRepo(withData: true)));

    expect(find.text('متاح للحجز'), findsOneWidget);
    expect(find.text('+2 اليوم'), findsOneWidget);
    expect(find.text('ادارة الباقات'), findsOneWidget);
    expect(find.text('api customer'), findsOneWidget);
    expect(find.text('غير مؤكد'), findsOneWidget);
    expect(find.text('600ILS'), findsOneWidget);
    expect(find.text('السبت، 17 أكتوبر 2026'), findsOneWidget);
  });

  testWidgets('store page shows real stats and activates a paused service', (
    tester,
  ) async {
    final repo = _FakeRepo(withData: true);
    await _pump(tester, _home(repo));
    await tester.tap(find.text('خدماتي'));
    await tester.pumpAndSettle();

    expect(find.text('خلال 1 ساعة'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('api active'), findsOneWidget);
    expect(find.text('نشط'), findsOneWidget);
    expect(find.text('موقوفة'), findsOneWidget);
    expect(find.text('السعر: 600ILS'), findsNWidgets(2));
    // No made-up numbers from the old screen.
    expect(find.text('105'), findsNothing);
    expect(find.text('98%'), findsNothing);

    await tester.tap(find.text('تفعيل'));
    await tester.pumpAndSettle();
    expect(repo.visibility, [(2, true)]);
  });

  testWidgets('add service sends the form the API expects', (tester) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderServicesCubit(repo),
        child: const ProviderAddServiceScreen(),
      ),
    );

    expect(find.text('إضافة خدمة جديدة'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'api title');
    await tester.tap(find.text('اختر الفئة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('api other').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(1), 'Ribbon');
    await tester.tap(find.text('مشمولة').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('قابلة للازالة').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(3), '800');
    await tester.enterText(fields.at(4), '900');

    await tester.ensureVisible(find.text('حفظ كمسودة'));
    await tester.tap(find.text('حفظ كمسودة'));
    await tester.pumpAndSettle();
    expect(find.text('سعر العرض يجب أن يكون أقل من السعر'), findsOneWidget);
    expect(repo.added, isNull);

    await tester.enterText(fields.at(4), '600');
    await tester.tap(find.text('نشر الان'));
    await tester.pumpAndSettle();
    expect(find.text('أضف صورة واحدة على الأقل قبل النشر'), findsOneWidget);
    expect(repo.added, isNull);

    ScaffoldMessenger.of(
      tester.element(find.text('حفظ كمسودة')),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('حفظ كمسودة'));
    await tester.tap(find.text('حفظ كمسودة'));
    await tester.pumpAndSettle();
    final data = repo.added!;
    expect(data['title'], 'api title');
    expect(data['category_id'], '4');
    expect(data['price'], '800');
    expect(data['offer_price'], '600');
    expect(jsonDecode(data['features']), ['Ribbon']);
    expect(jsonDecode(data['removable_features']), ['Ribbon']);
    expect(data['save_as_draft'], '1');
    expect(data.containsKey('booking_slots'), isFalse);
  });
}
