part of 'settings_cubit.dart';

sealed class SettingsState {}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}

final class SettingsLoaded extends SettingsState {
  final UserModel user;
  final bool notificationsEnabled;

  SettingsLoaded({required this.user, required this.notificationsEnabled});
}

final class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
