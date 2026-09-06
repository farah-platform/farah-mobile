import 'package:farah/data/models/user_model.dart';

/// Abstract interface for authentication operations.
///
/// Implemented by [ApiAuthRepository] (Railway backend + Firebase Google Sign-In).
abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> sendPasswordReset({required String email});

  /// Change password via the email-reset flow.
  ///
  /// [token] and [email] come from the reset-link deep link.
  Future<void> updatePassword({
    required String newPassword,
    required String token,
    required String email,
  });

  Future<void> logout();

  /// Returns the currently signed-in user, or null if no session exists.
  Future<UserModel?> checkSession();

  /// Change the authenticated user's password.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Permanently delete the authenticated user's account.
  Future<void> deleteAccount();

  /// Persist a guest session flag (no server call, no token).
  Future<void> loginAsGuest();
}
