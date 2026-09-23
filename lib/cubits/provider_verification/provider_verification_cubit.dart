import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderVerificationState {}

class ProviderVerificationInitial extends ProviderVerificationState {}
class ProviderVerificationLoading extends ProviderVerificationState {}
class ProviderVerificationLoaded extends ProviderVerificationState {
  final String status;
  final String message;
  ProviderVerificationLoaded({required this.status, required this.message});
}
class ProviderVerificationError extends ProviderVerificationState {
  final String message;
  ProviderVerificationError(this.message);
}

class ProviderVerificationCubit extends Cubit<ProviderVerificationState> {
  final ProviderRepository _providerRepository;

  ProviderVerificationCubit(this._providerRepository) : super(ProviderVerificationInitial());

  Future<void> checkStatus() async {
    emit(ProviderVerificationLoading());
    try {
      final data = await _providerRepository.getVerificationStatus();
      final status = data['status'] ?? 'pending';
      final message = data['message'] ?? 'جارِ التحقق من بياناتك. تستغرق مراجعة وتدقيق المستندات من قبل فريق المنصة مدة أقصاها 24 ساعة.';
      
      emit(ProviderVerificationLoaded(status: status, message: message));
    } catch (e) {
      emit(ProviderVerificationError('حدث خطأ أثناء جلب حالة التحقق'));
    }
  }
}
