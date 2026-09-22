import 'dart:io';

class PaymentRequestModel {
  final String bookingId;
  final String paymentMethod;
  final double amount;
  final File receiptImage;

  PaymentRequestModel({
    required this.bookingId,
    required this.paymentMethod,
    required this.amount,
    required this.receiptImage,
  });
}
