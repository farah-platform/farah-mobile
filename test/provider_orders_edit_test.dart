import 'dart:convert';

import 'package:farah/cubits/provider_orders/provider_order_details_cubit.dart';
import 'package:farah/cubits/provider_orders/provider_orders_cubit.dart';
import 'package:farah/cubits/provider_service_editor/provider_service_editor_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_cubit.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/orders/provider_order_details_screen.dart';
import 'package:farah/view/screens/provider/orders/provider_orders_screen.dart';
import 'package:farah/view/screens/provider/services/provider_add_service_screen.dart';
import 'package:farah/view/screens/provider/services/provider_edit_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

String _day(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Map<String, dynamic> _booking(String status, {String? date}) => {
  'id': 7,
  'reference': 'BKG-API',
  'status': status,
  'date': date ?? '2026-12-10',
  'time': '00:00',
  'slot': 'api slot',
  'customer': {
    'name': 'api customer',
    'phone': status == 'provider_pending' ? null : 'api phone',
  },
  'service': {'title': 'api service'},
  'pricing': {'total': 600, 'deposit': 120, 'remaining': 480, 'currency': 'ILS'},
  'payments': status == 'review_under_proof'
      ? [
          {'id': 3, 'amount': 120, 'status': 'submitted', 'proof_type': 'image'},
        ]
      : [],
};

class _FakeRepo implements ProviderRepository {
  String bookingStatus;
  final List<String?> listedStatuses = [];
  final List<String> calls = [];
  Map<String, dynamic>? added;
  (int, Map<String, dynamic>)? updated;
  List<String> blocked = [];

  _FakeRepo({this.bookingStatus = 'provider_pending'});

  @override
  Future<List<dynamic>> getProviderBookings({String? status}) async {
    listedStatuses.add(status);
    return status == 'completed' ? [] : [_booking('provider_pending')];
  }

  @override
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async =>
      _booking(bookingStatus, date: bookingStatus == 'confirmed' ? '2026-01-01' : null);

  @override
  Future<Map<String, dynamic>> getDashboardData() async => {
    'provider': {'payment_instructions': ''},
  };

  @override
  Future<void> updatePaymentInstructions(String instructions) async =>
      calls.add('instructions:$instructions');

  @override
  Future<void> decideBooking(
    int bookingId,
    String decision, {
    double? depositAmount,
    String? note,
  }) async {
    calls.add('decide:$decision:$depositAmount');
    bookingStatus = decision == 'accepted' ? 'payment_awaiting' : 'rejected';
  }

  @override
  Future<void> reviewPaymentProof(
    int bookingId,
    int paymentId,
    String decision, {
    String? reviewNote,
  }) async {
    calls.add('review:$paymentId:$decision');
    bookingStatus = 'confirmed';
  }

  @override
  Future<void> completeBooking(int bookingId) async {
    calls.add('complete');
    bookingStatus = 'completed';
  }

  @override
  Future<List<dynamic>> getCategories() async => [
    {'id': 3, 'name': 'api category'},
  ];

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
  Future<void> deleteProviderService(int id) async => calls.add('delete:$id');

  @override
  Future<Map<String, dynamic>> getServiceAvailability(
    int serviceId,
    String month,
  ) async => {'unavailable_dates': [], 'reserved_dates': {}};

  @override
  Future<void> updateServiceAvailability(
    int serviceId, {
    List<String> block = const [],
    List<String> unblock = const [],
  }) async => blocked = block;

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
    ),
  );
  await tester.pumpAndSettle();
}

Widget _editor(_FakeRepo repo, Map<String, dynamic> service) => BlocProvider(
  create: (_) => ProviderServiceEditorCubit(repo),
  child: Scaffold(
    body: Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<ProviderServiceEditorCubit>(),
              child: ProviderEditServiceScreen(service: service),
            ),
          ),
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

Map<String, dynamic> _service({
  String type = 'service',
  String? slug,
  List<Map<String, dynamic>> periods = const [],
  List<Map<String, dynamic>> features = const [],
  List<Map<String, dynamic>> items = const [],
  num? original,
  bool published = true,
}) => {
  'id': 5,
  'title': 'api title',
  'type': type,
  'description': 'api description',
  'category': {'id': 3, 'name': 'api category', 'slug': slug},
  'images': [],
  'feature_items': features,
  'package_items': items,
  'pricing': {'price': 600, 'original_price': original, 'currency': 'ILS'},
  'execution_duration': 'خلال 3أيام من الطلب',
  'booking_periods': periods,
  'is_published': published,
};

void main() {
  testWidgets('add package sends its contents as package items', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderServicesCubit(repo),
        child: const ProviderAddServiceScreen(isPackage: true),
      ),
    );

    expect(find.text('إضافةباقة جديدة'), findsOneWidget);
    expect(find.text('محتويات الباقة'), findsOneWidget);
    expect(find.text('مشمولة'), findsNothing);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'api package');
    await tester.tap(find.text('اختر الفئات التي تندرج تحت الباقة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('api category').last);
    await tester.pumpAndSettle();
    await tester.enterText(fields.at(1), 'api item');
    await tester.enterText(fields.at(3), '2500');
    await tester.ensureVisible(find.text('حفظ كمسودة'));
    await tester.tap(find.text('حفظ كمسودة'));
    await tester.pumpAndSettle();

    final data = repo.added!;
    expect(data['service_type'], 'package');
    expect(jsonDecode(data['package_items']), [
      {'title': 'api item', 'sort_order': 0},
    ]);
    expect(data.containsKey('features'), isFalse);
  });

  testWidgets('edit service: price and duration side by side, saves changes', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(tester, _editor(repo, _service()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('تعديل الخدمة'), findsOneWidget);
    expect(find.text('نبذة عن الخدمة'), findsOneWidget);
    expect(find.text('المواعيد المتاحة'), findsNothing);
    expect(find.text('600'), findsOneWidget);

    await tester.tap(find.text('خلال 3أيام من الطلب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('خلال أسبوع من الطلب').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch).last);
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(find.text('الخدمة مخفية عن العملاء'), findsOneWidget);

    await tester.ensureVisible(find.text('حفظ التعديلات'));
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();
    final (id, data) = repo.updated!;
    expect(id, 5);
    expect(data['execution_duration'], 'خلال أسبوع من الطلب');
    expect(data['is_available'], '0');
    expect(data.containsKey('offer_price'), isFalse);
    expect(data.containsKey('booking_slots'), isFalse);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('edit hall: amenities, calendar and periods are saved', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      _editor(
        repo,
        _service(
          slug: 'wedding-halls',
          original: 800,
          published: false,
          features: [
            {'name': 'الكراسي', 'removable': false},
            {'name': 'api amenity', 'removable': false},
          ],
          periods: [
            {'label': 'api evening', 'start_time': '17:00', 'end_time': '22:00'},
          ],
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('اسم الصالة'), findsOneWidget);
    expect(find.text('السعر الاساسي'), findsOneWidget);
    expect(find.text('800'), findsOneWidget);
    expect(find.text('600'), findsOneWidget);
    expect(find.text('api evening'), findsOneWidget);
    expect(find.text('5:00م _ 10:00م'), findsOneWidget);

    // Remove an amenity from its menu.
    await tester.ensureVisible(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.more_vert).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف المرفق'));
    await tester.pumpAndSettle();
    expect(find.text('api amenity'), findsNothing);

    // Block a future day (the 28th of next month).
    await tester.ensureVisible(find.byIcon(Icons.chevron_left));
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('28'));
    await tester.tap(find.text('28'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('حفظ التعديلات'));
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();
    final data = repo.updated!.$2;
    expect(data['offer_price'], '600');
    expect(data['price'], '800');
    expect(jsonDecode(data['features']), ['الكراسي']);
    expect(jsonDecode(data['booking_slots']), [
      {'label': 'api evening', 'start_time': '17:00', 'end_time': '22:00'},
    ]);
    final now = DateTime.now();
    expect(repo.blocked, [_day(DateTime(now.year, now.month + 1, 28))]);
  });

  testWidgets('edit package: switches mark items removable, delete asks first', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      _editor(
        repo,
        _service(
          type: 'package',
          published: false,
          items: [
            {'title': 'api item', 'removable': false},
          ],
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('تعديل الباقة'), findsOneWidget);
    expect(find.text('السعر الاجمالي'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('حفظ التعديلات'));
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();
    expect(jsonDecode(repo.updated!.$2['package_items']), [
      {'title': 'api item', 'removable': true, 'sort_order': 0},
    ]);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('حذف الباقة'));
    await tester.pumpAndSettle();
    expect(find.text('هل انت متأكد من حذف الباقة؟'), findsOneWidget);
    await tester.tap(find.text('حذف الباقة').last);
    await tester.pumpAndSettle();
    expect(repo.calls, contains('delete:5'));
  });

  testWidgets('orders tab lists API bookings and filters by status', (
    tester,
  ) async {
    final repo = _FakeRepo();
    await _pump(
      tester,
      Scaffold(
        body: BlocProvider(
          create: (_) => ProviderOrdersCubit(repo),
          child: const ProviderOrdersScreen(),
        ),
      ),
    );

    expect(find.text('api customer'), findsOneWidget);
    expect(find.text('غير مؤكد'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('مكتملة'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('مكتملة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('مكتملة'));
    await tester.pumpAndSettle();
    expect(repo.listedStatuses, [null, 'completed']);
    expect(find.text('لا توجد طلبات بهذه الحالة'), findsOneWidget);
  });

  Widget details(_FakeRepo repo) => BlocProvider(
    create: (_) => ProviderOrderDetailsCubit(repo, 7),
    child: const ProviderOrderDetailsScreen(),
  );

  testWidgets('accepting saves instructions and the deposit', (tester) async {
    final repo = _FakeRepo();
    await _pump(tester, details(repo));

    expect(find.text('يظهر رقم العميل بعد قبول الطلب.'), findsOneWidget);
    await tester.tap(find.text('قبول الطلب'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, 'api instructions text');
    await tester.tap(find.text('تأكيد القبول'));
    await tester.pumpAndSettle();

    expect(repo.calls, [
      'instructions:api instructions text',
      'decide:accepted:120.0',
    ]);
    expect(find.text('api phone'), findsOneWidget);
    expect(find.text('بانتظار الدفع'), findsOneWidget);
  });

  testWidgets('provider approves the deposit proof, then completes', (
    tester,
  ) async {
    final repo = _FakeRepo(bookingStatus: 'review_under_proof');
    await _pump(tester, details(repo));

    await tester.ensureVisible(find.text('اعتماد الدفع'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اعتماد الدفع'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['review:3:confirmed']);

    await tester.ensureVisible(find.text('تم تنفيذ الطلب'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تم تنفيذ الطلب'));
    await tester.pumpAndSettle();
    expect(repo.calls.last, 'complete');
    expect(find.text('مكتملة'), findsOneWidget);
  });
}
