import 'package:farah/cubits/payment/payment_cubit.dart';
import 'package:farah/data/models/booking_model.dart';
import 'package:farah/data/models/home/payment_request_model.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/payment_repository.dart';
import 'package:farah/view/screens/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopPaymentRepository implements PaymentRepository {
  @override
  Future<void> submitPaymentReceipt(PaymentRequestModel request) async {}
}

Widget _wrap(Widget child) => BlocProvider(
  create: (_) => PaymentCubit(_NoopPaymentRepository()),
  child: MaterialApp(
    home: Directionality(textDirection: TextDirection.rtl, child: child),
  ),
);

ServiceModel _service() => ServiceModel.fromJson({'id': 1, 'title': 'test'});

void main() {
  test('BookingModel reads payment_instructions from the API', () {
    final booking = BookingModel.fromJson({
      'id': 7,
      'payment_instructions': 'instructions from api',
    });
    expect(booking.paymentInstructions, 'instructions from api');
    expect(BookingModel.fromJson({'id': 7}).paymentInstructions, isNull);
  });

  testWidgets('no instructions: shows empty state, no placeholder numbers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PaymentScreen(service: _service(), depositAmount: 100, bookingId: '7'),
      ),
    );

    expect(
      find.text('ستظهر تفاصيل التحويل هنا بعد قبول مقدّم الخدمة لطلبك.'),
      findsOneWidget,
    );
    for (final fake in [
      '1654987',
      'PS00PALS00000000001234567',
      '0592467931',
      '0599123456',
    ]) {
      expect(find.text(fake), findsNothing);
    }

    final button = find.text('ارسال الاشعار');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    expect(
      find.text('لا يمكن إرسال إشعار التحويل قبل قبول مقدّم الخدمة لطلبك.'),
      findsOneWidget,
    );
  });

  testWidgets('with instructions: shows the provider text from the API', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PaymentScreen(
          service: _service(),
          depositAmount: 100,
          bookingId: '7',
          paymentInstructions: 'instructions from api',
        ),
      ),
    );

    expect(find.text('instructions from api'), findsOneWidget);
    expect(
      find.text('ستظهر تفاصيل التحويل هنا بعد قبول مقدّم الخدمة لطلبك.'),
      findsNothing,
    );
  });
}
