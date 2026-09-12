part of 'profile_edit_cubit.dart';

sealed class ProfileEditState {}

final class ProfileEditInitial extends ProfileEditState {}

final class ProfileEditLoading extends ProfileEditState {}

final class ProfileEditReady extends ProfileEditState {
  final UserModel user;
  final bool dirty;
  final Map<String, String> fieldErrors;

  ProfileEditReady({
    required this.user,
    this.dirty = false,
    this.fieldErrors = const {},
  });
}

final class ProfileEditSaving extends ProfileEditState {
  final UserModel user;
  ProfileEditSaving(this.user);
}

final class ProfileEditSuccess extends ProfileEditState {
  final UserModel user;
  ProfileEditSuccess(this.user);
}

final class ProfileEditError extends ProfileEditState {
  final String message;
  ProfileEditError(this.message);
}
