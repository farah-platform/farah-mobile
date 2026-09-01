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

// Emitted when the user's account has been successfully deleted.
final class AuthAccountDeleted extends AuthState {}

// Emitted when POST /register times out — the account may still have been
// created server-side (Railway processing takes ~60 s including email delivery).
final class AuthSignUpTimeout extends AuthState {}
