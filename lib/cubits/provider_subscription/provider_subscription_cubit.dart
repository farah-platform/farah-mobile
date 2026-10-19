import 'package:dio/dio.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderSubscriptionState {}

class ProviderSubscriptionInitial extends ProviderSubscriptionState {}
class ProviderSubscriptionLoading extends ProviderSubscriptionState {}
class ProviderSubscriptionPlansLoaded extends ProviderSubscriptionState {
  final List<dynamic> plans;
  ProviderSubscriptionPlansLoaded({required this.plans});
}
class ProviderSubscriptionBankLoaded extends ProviderSubscriptionState {
  final Map<String, dynamic> bank;
  ProviderSubscriptionBankLoaded(this.bank);
}
class ProviderSubscriptionActivating extends ProviderSubscriptionState {}
class ProviderSubscriptionSuccess extends ProviderSubscriptionState {
  /// True when a transfer proof was sent and waits for the admin.
  final bool pendingReview;
  ProviderSubscriptionSuccess({this.pendingReview = false});
}
class ProviderSubscriptionError extends ProviderSubscriptionState {
  final String message;
  ProviderSubscriptionError(this.message);
}

class ProviderSubscriptionCubit extends Cubit<ProviderSubscriptionState> {
  final ProviderRepository _providerRepository;

  ProviderSubscriptionCubit(this._providerRepository) : super(ProviderSubscriptionInitial());

  Future<void> fetchPlans() async {
    emit(ProviderSubscriptionLoading());
    try {
      final plans = await _providerRepository.getSubscriptionPlans();
      if (isClosed) return;
      emit(ProviderSubscriptionPlansLoaded(plans: plans));
    } catch (e) {
      if (isClosed) return;
      emit(ProviderSubscriptionError('فشل في جلب باقات الاشتراك'));
    }
  }

  Future<void> fetchBankDetails() async {
    emit(ProviderSubscriptionLoading());
    try {
      final bank = await _providerRepository.getBankTransferDetails();
      if (isClosed) return;
      emit(ProviderSubscriptionBankLoaded(bank));
    } catch (e) {
      if (isClosed) return;
      emit(ProviderSubscriptionError(_mapError(e, 'تعذّر تحميل بيانات التحويل')));
    }
  }

  Future<void> activateSubscription({required String planSlug, dynamic proof}) async {
    emit(ProviderSubscriptionActivating());
    try {
      final data = await _providerRepository.activateSubscription(planSlug, proof: proof);
      if (isClosed) return;
      emit(ProviderSubscriptionSuccess(pendingReview: data['status'] == 'submitted'));
    } catch (e) {
      if (isClosed) return;
      emit(ProviderSubscriptionError(_mapError(e, 'حدث خطأ أثناء تفعيل الاشتراك')));
    }
  }

  String _mapError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final message = (data['title'] ?? data['message'])?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    return fallback;
  }
}
