import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderHelpCenterState {
  /// `[{id, question, answer}]` managed by the admin.
  final List<Map<String, dynamic>> faqs;
  final String? supportPhone;
  final String? supportEmail;
  final bool loading;
  final String? error;

  const ProviderHelpCenterState({
    this.faqs = const [],
    this.supportPhone,
    this.supportEmail,
    this.loading = true,
    this.error,
  });
}

// فرح: "مركز المساعدة" للمزود: الأسئلة من السيرفر، و"تواصل معنا" من بيانات الدعم في إعدادات الأدمن.
class ProviderHelpCenterCubit extends Cubit<ProviderHelpCenterState> {
  final ProviderRepository _repository;

  ProviderHelpCenterCubit(this._repository)
    : super(const ProviderHelpCenterState());

  Future<void> load() async {
    emit(const ProviderHelpCenterState());
    try {
      final results = await Future.wait([
        _repository.getFaqs(),
        _repository.getSupportContacts(),
      ]);
      if (isClosed) return;
      final contacts = results[1] as Map<String, dynamic>;
      String? clean(Object? value) {
        final text = value?.toString().trim() ?? '';
        return text.isEmpty ? null : text;
      }

      emit(
        ProviderHelpCenterState(
          loading: false,
          faqs: [
            for (final faq in results[0] as List<dynamic>)
              if (faq is Map) Map<String, dynamic>.from(faq),
          ],
          supportPhone: clean(contacts['support_phone']),
          supportEmail: clean(contacts['support_email']),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderHelpCenterState(
          loading: false,
          error: providerOrderError(e, 'تعذّر تحميل الأسئلة الشائعة'),
        ),
      );
    }
  }
}
