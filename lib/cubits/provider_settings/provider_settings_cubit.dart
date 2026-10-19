import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderSettingsState {
  /// Null until loaded from /notification-settings.
  final bool? notificationsEnabled;
  final String? error;
  const ProviderSettingsState({this.notificationsEnabled, this.error});
}

/// "الاعدادات" tab: the notifications switch saved on the server.
class ProviderSettingsCubit extends Cubit<ProviderSettingsState> {
  final ProviderRepository _repository;

  ProviderSettingsCubit(this._repository)
    : super(const ProviderSettingsState());

  Future<void> load() async {
    try {
      final enabled = await _repository.getNotificationsEnabled();
      if (isClosed) return;
      emit(ProviderSettingsState(notificationsEnabled: enabled));
    } catch (_) {
      if (isClosed) return;
      emit(const ProviderSettingsState(notificationsEnabled: true));
    }
  }

  Future<void> setNotifications(bool enabled) async {
    final previous = state.notificationsEnabled;
    emit(ProviderSettingsState(notificationsEnabled: enabled));
    try {
      await _repository.setNotificationsEnabled(enabled);
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderSettingsState(
          notificationsEnabled: previous,
          error: providerOrderError(e, 'تعذّر حفظ الإعداد'),
        ),
      );
    }
  }
}
