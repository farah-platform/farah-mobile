part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class UserProfileLoaded extends ProfileState {
  final UserModel user;
  UserProfileLoaded(this.user);
}

final class ProviderProfileLoaded extends ProfileState {
  final ServiceProviderModel provider;
  ProviderProfileLoaded(this.provider);
}

final class ProfileUpdated extends ProfileState {}

final class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
