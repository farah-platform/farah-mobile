part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserModel user;
  AuthSuccess(this.user);
}

final class AuthAwaitingEmailVerification extends AuthState {}

final class AuthPasswordResetSent extends AuthState {}

final class AuthPasswordUpdated extends AuthState {}

final class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
