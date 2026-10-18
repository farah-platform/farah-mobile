part of 'payment_cubit.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

// 1. جاري الإرسال
class PaymentLoading extends PaymentState {}

// 2. تم إرسال الإشعار وبانتظار المراجعة (24 ساعة)
class PaymentSubmittedUnderReview extends PaymentState {
  final String serviceTitle;
  final double amount;
  final String currency;
  final DateTime sentDate;

  PaymentSubmittedUnderReview({
    required this.serviceTitle,
    required this.amount,
    required this.currency,
    required this.sentDate,
  });
}

// 3. تم تأكيد الحجز بنجاح
class PaymentBookingConfirmed extends PaymentState {
  final String providerName;
  final String serviceTitle;
  final DateTime bookingDate;
  final double amountPaid;
  final String currency;

  PaymentBookingConfirmed({
    required this.providerName,
    required this.serviceTitle,
    required this.bookingDate,
    required this.amountPaid,
    required this.currency,
  });
}

// 4. خطأ في الاتصال / الشبكة
class PaymentConnectionError extends PaymentState {
  final String message;

  PaymentConnectionError({
    this.message = 'يرجى التحقق من اتصالك بالإنترنت\nوالمحاولة مرة أخرى',
  });
}

// 5. تم رفض إشعار الدفع من المزود
class PaymentRejected extends PaymentState {
  final String reason;

  PaymentRejected({required this.reason});
}
