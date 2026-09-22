import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:farah/data/models/home/payment_request_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/data/repositories/payment_repository.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository _repo;

  PaymentCubit(this._repo) : super(PaymentInitial());

  Future<void> sendReceipt({
    required PaymentRequestModel request,
    required String serviceTitle,
    required String currency,
  }) async {
    emit(PaymentLoading());
    try {
      await _repo.submitPaymentReceipt(request);

      emit(
        PaymentSubmittedUnderReview(
          serviceTitle: serviceTitle,
          amount: request.amount,
          currency: currency,
          sentDate: DateTime.now(),
        ),
      );
    } on DioException catch (e) {
      final msg =
          e.response?.data?['message']?.toString() ??
          'يرجى التحقق من اتصالك بالإنترنت\nوالمحاولة مرة أخرى';
      emit(
        PaymentConnectionError(
          message: msg,
          onRetry: () => sendReceipt(
            request: request,
            serviceTitle: serviceTitle,
            currency: currency,
          ),
        ),
      );
    } catch (_) {
      emit(
        PaymentConnectionError(
          message:
              'حدث خطأ غير متوقع أثناء إرسال الإشعار\nيرجى المحاولة مجدداً',
          onRetry: () => sendReceipt(
            request: request,
            serviceTitle: serviceTitle,
            currency: currency,
          ),
        ),
      );
    }
  }
}
