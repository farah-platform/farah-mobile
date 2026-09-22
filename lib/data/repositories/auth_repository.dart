import 'package:farah/data/models/auth/city_model.dart';
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

  /// Fetches the list of available cities from the backend.
  Future<List<CityModel>> getCities();

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
}
