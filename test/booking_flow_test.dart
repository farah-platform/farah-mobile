import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/cubits/booking/booking_cubit.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/models/booking_model.dart';
import 'package:farah/data/models/booking_options_model.dart';
import 'package:farah/data/models/home/myBooking_model.dart' as my;
import 'package:farah/data/models/home/booking_request_model.dart';
import 'package:farah/data/models/home/payment_request_model.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/api_booking_repository.dart';
import 'package:farah/data/repositories/booking_repository.dart';
import 'package:farah/data/repositories/payment_repository.dart';
import 'package:farah/view/screens/user/booking_confirmation_screen.dart';
import 'package:farah/view/widgets/service_details/booking_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

class _NoTokenCache extends CacheDatasource {
  @override
  Future<String?> getToken() async => null;
}

class _Recorder extends Interceptor {
  final List<RequestOptions> requests = [];
  final Map<String, dynamic> Function(RequestOptions) respond;
  _Recorder(this.respond);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: respond(options),
      ),
    );
  }
}

DioClient _client(_Recorder recorder) {
  final client = DioClient(_NoTokenCache());
  client.dio.interceptors.add(recorder);
  return client;
}

/// Shape of BookingController::bookingData in the backend.
Map<String, dynamic> _apiBooking() => <String, dynamic>{
  'id': 9,
  'reference': 'BKG-1',
  'status': 'provider_pending',
  'date': '2026-11-20',
  'time': '17:00',
  'service': <String, dynamic>{'id': 5, 'title': 'api service'},
  'pricing': <String, dynamic>{
    'total': 900,
    'deposit': 180,
    'remaining': 720,
    'currency': 'ILS',
  },
  'payment_instructions': null,
};

BookingOptionsModel _options() => BookingOptionsModel.fromJson({
  'month': '2026-11',
  'price': 500,
  'currency': 'ILS',
  'days': [
    {
      'date': '2026-11-20',
      'day': 20,
      'is_past': false,
      'is_available': true,
      'slots': [
        {
          'label': 'api evening',
          'start_time': '17:00',
          'end_time': '22:00',
          'price': 900,
          'is_available': true,
        },
        {
          'label': 'api morning',
          'start_time': '10:00',
          'end_time': '15:00',
          'price': 700,
          'is_available': false,
        },
      ],
    },
    {
      'date': '2026-11-21',
      'day': 21,
      'is_past': false,
      'is_available': false,
      'slots': [],
    },
  ],
});

class _FakeBookingRepository implements BookingRepository {
  BookingRequestModel? created;

  @override
  Future<BookingOptionsModel> fetchBookingOptions(int id, String month) async =>
      _options();

  @override
  Future<BookingModel> createBooking(BookingRequestModel request) async {
    created = request;
    return BookingModel.fromJson(_apiBooking());
  }

  @override
  Future<void> cancelBooking(String id) async {}
  @override
  Future<List<BookingModel>> fetchProviderBookings() async => [];
  @override
  Future<List<BookingModel>> fetchUserBookings() async => [];
}

ServiceModel _service() =>
    ServiceModel.fromJson({'id': 5, 'title': 'api service', 'price': 500});

void main() {
  setUpAll(() => initializeDateFormatting('ar'));

  group('API requests', () {
    test('create booking posts to /services/{id}/bookings in H:i', () async {
      final recorder = _Recorder((_) => {'data': _apiBooking()});
      final repo = ApiBookingRepository(dioClient: _client(recorder));

      final booking = await repo.createBooking(
        BookingRequestModel(
          serviceId: 5,
          bookingDate: '2026-11-20',
          bookingTime: '17:00',
          bookingSlot: 'api evening',
          notes: 'note',
        ),
      );

      final req = recorder.requests.single;
      expect(req.method, 'POST');
      expect(req.path, '/services/5/bookings');
      expect(req.data, {
        'booking_date': '2026-11-20',
        'booking_time': '17:00',
        'booking_slot': 'api evening',
        'notes': 'note',
      });
      expect(booking.id, '9');
    });

    test('cancel uses POST and options pass the month', () async {
      final recorder = _Recorder(
        (o) => {
          'data': o.path.endsWith('booking-options')
              ? <String, dynamic>{'days': []}
              : <String, dynamic>{},
        },
      );
      final repo = ApiBookingRepository(dioClient: _client(recorder));
      await repo.cancelBooking('9');
      await repo.fetchBookingOptions(5, '2026-11');

      expect(recorder.requests[0].method, 'POST');
      expect(recorder.requests[0].path, '/bookings/9/cancel');
      expect(recorder.requests[1].path, '/services/5/booking-options');
      expect(recorder.requests[1].queryParameters, {'month': '2026-11'});
    });

    test('payment proof goes to /bookings/{id}/payment-proofs', () async {
      final recorder = _Recorder((_) => {'data': <String, dynamic>{}});
      final repo = ApiPaymentRepository(dioClient: _client(recorder));
      final dir = await Directory.systemTemp.createTemp('farah_test');
      final proof = File('${dir.path}/proof.jpg')..writeAsBytesSync([1, 2, 3]);

      await repo.submitPaymentReceipt(
        PaymentRequestModel(
          bookingId: '9',
          paymentMethod: 'bank_transfer',
          amount: 180,
          receiptImage: proof,
        ),
      );

      final req = recorder.requests.single;
      expect(req.path, '/bookings/9/payment-proofs');
      final form = req.data as FormData;
      expect(Map.fromEntries(form.fields), {
        'method': 'bank_transfer',
        'amount': '180.0',
      });
      expect(form.files.single.key, 'proof');
    });
  });

  test('BookingModel reads the API booking shape', () {
    final booking = BookingModel.fromJson(_apiBooking());
    expect(booking.status, BookingStatus.providerPending);
    expect(booking.serviceId, '5');
    expect(booking.serviceName, 'api service');
    expect(booking.totalPrice, 900);
    expect(booking.depositAmount, 180);
    expect(booking.eventDate, DateTime(2026, 11, 20));
    expect(
      BookingModel.fromJson({'status': 'payment_awaiting'}).status,
      BookingStatus.paymentAwaiting,
    );
  });

  testWidgets('bottom sheet shows API slots and prices, no placeholders', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0; // test font glyphs are wide
    addTearDown(tester.view.reset);

    final repo = _FakeBookingRepository();
    await tester.pumpWidget(
      RepositoryProvider<BookingRepository>.value(
        value: repo,
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () =>
                      BookingBottomSheetWidget.show(context, _service()),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // No hardcoded periods or fallback price.
    expect(find.text('الفترة الصباحية'), findsNothing);
    expect(find.textContaining('1400'), findsNothing);
    expect(find.text('اختر تاريخاً لعرض الفترات المتاحة'), findsOneWidget);

    // The fake API returns the same days for any month.
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    expect(find.text('api evening'), findsOneWidget);
    expect(find.text('api morning'), findsOneWidget);

    await tester.tap(find.text('api evening'));
    await tester.pumpAndSettle();
    expect(find.text('900 ILS'), findsOneWidget);

    // Unavailable slot cannot be selected.
    await tester.tap(find.text('api morning'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('900 ILS'), findsOneWidget);

    // A day the API marks unavailable cannot be selected.
    await tester.tap(find.text('21'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('api evening'), findsOneWidget);
  });

  testWidgets('confirmation sends API slot and returns instead of paying', (
    tester,
  ) async {
    final repo = _FakeBookingRepository();
    final slot = _options().days.first.slots.first;

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => BookingCubit(repo),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingConfirmationScreen(
                      service: _service(),
                      selectedDateTime: DateTime(2026, 11, 20),
                      slot: slot,
                      currency: 'ILS',
                      notes: 'note',
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('900 ILS'), findsOneWidget);
    expect(find.text('يُحدَّد عند قبول الطلب'), findsNWidgets(2));
    expect(find.textContaining('800'), findsNothing);

    await tester.tap(find.text('إرسال طلب الحجز'));
    await tester.pumpAndSettle();

    expect(repo.created!.serviceId, 5);
    expect(repo.created!.bookingTime, '17:00');
    expect(repo.created!.bookingSlot, 'api evening');
    expect(repo.created!.notes, 'note');
    // Back on the previous page, not on a payment screen.
    expect(find.text('open'), findsOneWidget);
    expect(
      find.text(
        'تم إرسال طلب الحجز إلى مقدّم الخدمة، وستصلك تعليمات الدفع بعد قبوله.',
      ),
      findsOneWidget,
    );
  });

  test('My Bookings reads the API shape and in-progress statuses', () {
    final b = my.MybookingModel.fromJson(_apiBooking());
    expect(b.title, 'api service');
    expect(b.price, 900);
    expect(b.date, '2026-11-20');
    expect(b.status, my.BookingStatus.pending);
    for (final s in ['payment_awaiting', 'review_under_proof']) {
      expect(
        my.MybookingModel.fromJson({'status': s}).status,
        my.BookingStatus.pending,
      );
    }
    expect(my.MybookingModel.fromJson({}).date, isEmpty);
  });
}
