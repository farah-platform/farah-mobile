import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/support_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final ProfileRepository _profileRepo;
  final SupportRepository _supportRepo;

  SettingsCubit(this._profileRepo, this._supportRepo)
    : super(SettingsInitial());

  Future<void> load() async {
    emit(SettingsLoading());
    try {
      final user = await _profileRepo.fetchUserProfile();
      // فرح: تفضيل الإشعارات من السيرفر (GET /notification-settings) بدل الجوال فقط.
      final notificationsEnabled = await _supportRepo
          .getNotificationsEnabled()
          .catchError((_) => true);
      if (isClosed) return;
      emit(
        SettingsLoaded(user: user, notificationsEnabled: notificationsEnabled),
      );
    } catch (_) {
      if (isClosed) return;
      emit(SettingsError('تعذّر تحميل الإعدادات، يرجى المحاولة مجدداً'));
    }
  }

  Future<void> toggleNotifications(bool value) async {
    final current = state;
    if (current is! SettingsLoaded) return;
    // Show the change right away and undo it if the server refuses.
    emit(SettingsLoaded(user: current.user, notificationsEnabled: value));
    try {
      await _supportRepo.setNotificationsEnabled(value);
    } catch (_) {
      if (isClosed) return;
      emit(
        SettingsLoaded(
          user: current.user,
          notificationsEnabled: current.notificationsEnabled,
        ),
      );
    }
  }
}
