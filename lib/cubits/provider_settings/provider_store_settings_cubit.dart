import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderStoreSettingsState {
  /// `profile` block of GET /provider/onboarding.
  final Map<String, dynamic> profile;
  final List<dynamic> cities;
  // فرح: قائمة فئات الخدمة من السيرفر لحقل "فئة الخدمة".
  final List<dynamic> categories;
  final Map<String, dynamic> payoutAccount;
  final bool loading;
  final bool saving;
  final bool saved;
  final String? error;

  const ProviderStoreSettingsState({
    this.profile = const {},
    this.cities = const [],
    this.categories = const [],
    this.payoutAccount = const {},
    this.loading = true,
    this.saving = false,
    this.saved = false,
    this.error,
  });

  ProviderStoreSettingsState copyWith({
    Map<String, dynamic>? profile,
    List<dynamic>? cities,
    List<dynamic>? categories,
    Map<String, dynamic>? payoutAccount,
    bool? loading,
    bool? saving,
    bool? saved,
    String? error,
  }) {
    return ProviderStoreSettingsState(
      profile: profile ?? this.profile,
      cities: cities ?? this.cities,
      categories: categories ?? this.categories,
      payoutAccount: payoutAccount ?? this.payoutAccount,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      error: error,
    );
  }
}

/// "بيانات المتجر" and "حساب استلام الارباح" from the settings tab.
class ProviderStoreSettingsCubit extends Cubit<ProviderStoreSettingsState> {
  final ProviderRepository _repository;

  ProviderStoreSettingsCubit(this._repository)
    : super(const ProviderStoreSettingsState());

  Future<void> load() async {
    try {
      final results = await Future.wait([
        _repository.getOnboardingData(),
        _repository.getCities(),
        _repository.getDashboardData(),
        _repository.getCategories(),
      ]);
      if (isClosed) return;
      final onboarding = results[0] as Map<String, dynamic>;
      final provider = (results[2] as Map<String, dynamic>)['provider'];
      final payout = provider is Map ? provider['payout_account'] : null;
      emit(
        state.copyWith(
          loading: false,
          profile: onboarding['profile'] is Map
              ? Map<String, dynamic>.from(onboarding['profile'])
              : {},
          cities: results[1] as List<dynamic>,
          categories: results[3] as List<dynamic>,
          payoutAccount: payout is Map ? Map<String, dynamic>.from(payout) : {},
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: providerOrderError(e, 'تعذّر تحميل بيانات المتجر'),
        ),
      );
    }
  }

  Future<void> saveProfile(
    Map<String, dynamic> data,
    dynamic cover, {
    dynamic logo,
  }) => _save(() => _repository.updateStoreProfile(data, cover, logo: logo));

  Future<void> savePayout({
    required String bankName,
    required String accountNumber,
    String? iban,
  }) => _save(
    () => _repository.updatePayoutAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      iban: iban,
    ),
  );

  Future<void> _save(Future<void> Function() action) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      await action();
      if (isClosed) return;
      emit(state.copyWith(saving: false, saved: true));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          saving: false,
          error: providerOrderError(e, 'تعذّر الحفظ'),
        ),
      );
    }
  }
}
