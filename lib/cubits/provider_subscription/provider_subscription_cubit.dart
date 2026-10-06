import 'dart:io';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderSubscriptionState {}

class ProviderSubscriptionInitial extends ProviderSubscriptionState {}
class ProviderSubscriptionLoading extends ProviderSubscriptionState {}
class ProviderSubscriptionPlansLoaded extends ProviderSubscriptionState {
  final List<dynamic> plans;
  ProviderSubscriptionPlansLoaded({required this.plans});
}
class ProviderSubscriptionActivating extends ProviderSubscriptionState {}
class ProviderSubscriptionSuccess extends ProviderSubscriptionState {}
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
      emit(ProviderSubscriptionPlansLoaded(plans: plans));
    } catch (e) {
      emit(ProviderSubscriptionError('فشل في جلب باقات الاشتراك'));
    }
  }

  Future<void> activateSubscription({
    required String planId,
    required String bankName,
    required String accountNumber,
    required File receiptImage,
  }) async {
    emit(ProviderSubscriptionActivating());
    try {
      await _providerRepository.activateSubscription(planId, bankName, accountNumber, receiptImage);
      emit(ProviderSubscriptionSuccess());
    } catch (e) {
      emit(ProviderSubscriptionError('حدث خطأ أثناء تفعيل الاشتراك'));
    }
  }
}
