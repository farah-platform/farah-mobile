import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/support_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HelpCenterState {
  /// `[{id, question, answer}]` managed by the admin.
  final List<Map<String, dynamic>> faqs;
  final String? supportPhone;
  final String? supportEmail;
  final bool loading;
  final String? error;

  const HelpCenterState({
    this.faqs = const [],
    this.supportPhone,
    this.supportEmail,
    this.loading = true,
    this.error,
  });
}

// فرح: "مركز المساعدة" للعميل والمزود: الأسئلة من السيرفر حسب نوع الحساب (audience)،
// و"تواصل معنا" من بيانات الدعم في إعدادات الأدمن.
class HelpCenterCubit extends Cubit<HelpCenterState> {
  final SupportRepository _repository;

  /// `customer` or `provider`.
  final String audience;

  HelpCenterCubit(this._repository, {required this.audience})
    : super(const HelpCenterState());

  Future<void> load() async {
    emit(const HelpCenterState());
    try {
      final results = await Future.wait([
        _repository.getFaqs(audience: audience),
        _repository.getSupportContacts(),
      ]);
      if (isClosed) return;
      final contacts = results[1] as Map<String, dynamic>;
      String? clean(Object? value) {
        final text = value?.toString().trim() ?? '';
        return text.isEmpty ? null : text;
      }

      emit(
        HelpCenterState(
          loading: false,
          faqs: results[0] as List<Map<String, dynamic>>,
          supportPhone: clean(contacts['support_phone']),
          supportEmail: clean(contacts['support_email']),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        HelpCenterState(
          loading: false,
          error: providerOrderError(e, 'تعذّر تحميل الأسئلة الشائعة'),
        ),
      );
    }
  }
}
