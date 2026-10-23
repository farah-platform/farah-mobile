import 'package:farah/cubits/mybooking/mybooking_cubit.dart';
import 'package:farah/cubits/payment/payment_cubit.dart';
import 'package:farah/data/models/home/myBooking_model.dart';
import 'package:farah/data/models/home/payment_request_model.dart';
import 'package:farah/data/repositories/mybooking_repository.dart';
import 'package:farah/data/repositories/payment_repository.dart';
import 'package:farah/view/screens/user/MyBookingsScreen.dart';
import 'package:farah/view/screens/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: من "حجوزاتي" يفتح الدفع للحجز "بانتظار الدفع" بالعربون وتعليمات المزود من السيرفر.

Map<String, dynamic> _booking(int id, String status) => {
  'id': id,
  'status': status,
  'date': '2026-11-01',
  'payment_instructions': status == 'payment_awaiting'
      ? 'api instructions'
      : null,
  'service': {'id': 5, 'title': 'api service $id', 'image': null},
  'pricing': {'total': 900, 'deposit': 250, 'currency': 'ILS'},
};

class _FakeBookings implements MyBookingRepository {
  int loads = 0;

  @override
  Future<List<MybookingModel>> getBookings() async {
    loads++;
    return [
      MybookingModel.fromJson(_booking(1, 'payment_awaiting')),
      MybookingModel.fromJson(_booking(2, 'provider_pending')),
    ];
  }
}

class _NoopPayments implements PaymentRepository {
  @override
  Future<void> submitPaymentReceipt(PaymentRequestModel request) async {}
}

void main() {
  test('my booking reads the payment fields', () {
    final booking = MybookingModel.fromJson(_booking(1, 'payment_awaiting'));
    expect(booking.awaitingPayment, isTrue);
    expect(booking.deposit, 250);
    expect(booking.paymentInstructions, 'api instructions');
    expect(
      MybookingModel.fromJson(_booking(2, 'provider_pending')).awaitingPayment,
      isFalse,
    );
  });

  testWidgets('only the accepted booking can be paid, with API values', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _FakeBookings();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MybookingCubit(repo)),
          BlocProvider(create: (_) => PaymentCubit(_NoopPayments())),
        ],
        child: const MaterialApp(home: MyBookingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('api service 1'), findsOneWidget);
    expect(find.text('api service 2'), findsOneWidget);
    expect(find.text('ادفع العربون (250 ILS)'), findsOneWidget);

    await tester.tap(find.text('ادفع العربون (250 ILS)'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(find.text('api instructions'), findsOneWidget);

    Navigator.of(tester.element(find.byType(PaymentScreen))).pop();
    await tester.pumpAndSettle();
    expect(repo.loads, 2);
  });
}
