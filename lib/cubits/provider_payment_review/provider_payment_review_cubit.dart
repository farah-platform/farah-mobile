import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/provider_repository.dart';

abstract class ProviderPaymentReviewState {}

class ProviderPaymentReviewInitial extends ProviderPaymentReviewState {}
class ProviderPaymentReviewLoading extends ProviderPaymentReviewState {}
class ProviderPaymentReviewLoaded extends ProviderPaymentReviewState {
  final Map<String, dynamic> bookingDetails;
  ProviderPaymentReviewLoaded(this.bookingDetails);
}
class ProviderPaymentReviewSuccess extends ProviderPaymentReviewState {
  final String decision;
  ProviderPaymentReviewSuccess(this.decision);
}
class ProviderPaymentReviewError extends ProviderPaymentReviewState {
  final String message;
  ProviderPaymentReviewError(this.message);
}

class ProviderPaymentReviewCubit extends Cubit<ProviderPaymentReviewState> {
  final ProviderRepository _repo;

  ProviderPaymentReviewCubit(this._repo) : super(ProviderPaymentReviewInitial());

  Future<void> loadPaymentDetails(int bookingId) async {
    emit(ProviderPaymentReviewLoading());
    try {
      final details = await _repo.getBookingDetails(bookingId);
      emit(ProviderPaymentReviewLoaded(details));
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال';
      emit(ProviderPaymentReviewError(msg));
    } catch (e) {
      emit(ProviderPaymentReviewError('حدث خطأ غير متوقع'));
    }
  }

  Future<void> reviewPayment(int bookingId, int paymentId, String decision, {String? reviewNote}) async {
    emit(ProviderPaymentReviewLoading());
    try {
      await _repo.reviewPaymentProof(bookingId, paymentId, decision, reviewNote: reviewNote);
      emit(ProviderPaymentReviewSuccess(decision));
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'حدث خطأ في الاتصال';
      emit(ProviderPaymentReviewError(msg));
    } catch (e) {
      emit(ProviderPaymentReviewError('حدث خطأ غير متوقع'));
    }
  }
}
