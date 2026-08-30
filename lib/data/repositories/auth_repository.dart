import 'package:farah/data/models/user_model.dart';

/// Abstract interface for authentication operations.
///
/// Implemented by [ApiAuthRepository] (Railway backend + Firebase Google Sign-In).
abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> sendPasswordReset({required String email});

  Future<void> updatePassword({
    required String newPassword,
    String token = '',
    String email = '',
  });

  Future<void> logout();

  /// Returns the currently signed-in user, or null if no session.
  Future<UserModel?> checkSession();
}
