import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ProfileRepository _profileRepo;

  static const _notificationsKey = 'settings_notifications_enabled';

  SettingsCubit(this._profileRepo) : super(SettingsInitial());

  Future<void> load() async {
    emit(SettingsLoading());
    try {
      final user = await _profileRepo.fetchUserProfile();
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      emit(SettingsLoaded(user: user, notificationsEnabled: notificationsEnabled));
    } catch (_) {
      emit(SettingsError('تعذّر تحميل الإعدادات، يرجى المحاولة مجدداً'));
    }
  }

  // TODO: wire toggleNotifications to a backend preference endpoint once available.
  Future<void> toggleNotifications(bool value) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    emit(SettingsLoaded(user: current.user, notificationsEnabled: value));
  }
}
