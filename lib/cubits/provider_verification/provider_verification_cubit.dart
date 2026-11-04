import 'package:farah/data/datasources/local/offline_cache.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderVerificationState {}

class ProviderVerificationInitial extends ProviderVerificationState {}

class ProviderVerificationLoading extends ProviderVerificationState {}

class ProviderVerificationLoaded extends ProviderVerificationState {
  final String status;
  final String title;
  final String message;
  final String nextStep;
  final String? decisionReason;
  ProviderVerificationLoaded({
    required this.status,
    required this.message,
    this.title = '',
    this.nextStep = '',
    this.decisionReason,
  });
}

class ProviderVerificationError extends ProviderVerificationState {
  final String message;
  // فرح: true لما الخطأ سببه انقطاع النت (مش إن الحساب ما كمّل التسجيل).
  final bool offline;
  ProviderVerificationError(this.message, {this.offline = false});
}

class ProviderVerificationCubit extends Cubit<ProviderVerificationState> {
  final ProviderRepository _providerRepository;

  ProviderVerificationCubit(this._providerRepository)
    : super(ProviderVerificationInitial());

  Future<void> checkStatus() async {
    if (isClosed) return;
    emit(ProviderVerificationLoading());
    try {
      _emitStatus(await _providerRepository.getVerificationStatus());
    } catch (e) {
      if (isClosed) return;
      // فرح: بدون نت نعتمد على آخر حالة محفوظة، وإلا نوضّح إنه ما في نت
      // (قبل كان أي خطأ يودّي المزود على شاشة التسجيل من جديد).
      if (OfflineCache.isOffline(e)) {
        final cached = await OfflineCache.read(
          OfflineCache.providerVerification,
        );
        if (isClosed) return;
        if (cached is Map && cached['status'] != null) {
          _emitStatus(Map<String, dynamic>.from(cached));
          return;
        }
        emit(
          ProviderVerificationError('لا يوجد اتصال بالإنترنت', offline: true),
        );
        return;
      }
      emit(ProviderVerificationError('حدث خطأ أثناء جلب حالة التحقق'));
    }
  }

  void _emitStatus(Map<String, dynamic> data) {
    if (isClosed) return;
    emit(
      ProviderVerificationLoaded(
        status: data['status']?.toString() ?? 'pending',
        title: data['title']?.toString() ?? '',
        message:
            data['message']?.toString() ??
            'جاري التحقق من بياناتك. تستغرق مراجعة وتدقيق المستندات من قبل فريق المنصة مدة أقصاها 24 ساعة.',
        nextStep: data['next_step']?.toString() ?? '',
        decisionReason: data['decision_reason']?.toString(),
      ),
    );
  }
}
