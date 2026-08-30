import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Real backend implementation of [AuthRepository].
class ApiAuthRepository implements AuthRepository {
  static const _userKey = 'api_user_model';

  final Dio _dio;
  final CacheDatasource _cache;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  ApiAuthRepository({
    required DioClient dioClient,
    required CacheDatasource cache,
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
  }) : _dio = dioClient.dio,
       _cache = cache,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             serverClientId:
                 '800173223794-8kvbhprgpt0g8r0l9scab0br4c06jqsn.apps.googleusercontent.com',
           ),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );
    await _cache.saveToken(res.data['token'] as String);
    final user = UserModel.fromMap(res.data['user'] as Map<String, dynamic>);
    await _persistUser(user);
    return user;
  }

  // cityId is int? — the backend spec field is city_id (integer).
  // The sign-up screen currently passes null; it will be replaced with a
  // real city picker in Part B.
  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  }) async {
    await _dio.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email.trim(),
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        if (userType != null) 'user_type': userType,
        if (cityId != null) 'city_id': cityId,
      },
    );
    // Backend does not return a token on register — account needs email
    // verification first. Token/session will be saved after login success.
  }

  // ── Firebase / Google Sign-In ──────────────────────────────────────────────
  // Scope decision pending. The '/auth/google' path does not exist in the
  // current backend spec; the literal is kept here so this code continues to
  // compile unchanged. Do not remove without a backend endpoint to back it.
  // Google Sign-In is handled entirely via Firebase — there is no /auth/google
  // endpoint in the Railway backend spec.
  @override
  Future<UserModel> signInWithGoogle() async {
    final existing = await checkSession();
    if (existing != null) return existing;

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('تم إلغاء تسجيل الدخول');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCred.user!;
    final idToken = await firebaseUser.getIdToken();
    await _cache.saveToken(idToken ?? '');

    final user = UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'مستخدم جوجل',
      email: firebaseUser.email ?? '',
      phone: firebaseUser.phoneNumber ?? '',
      region: 'غزة',
    );
    await _persistUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email.trim()});
  }

  // Spec: POST /reset-password  body: token, email, password, password_confirmation
  // token and email come from the deep-link URL; the screen will supply them in
  // Part B. password_confirmation is added here; the rest will be wired in Step 4.
  @override
  Future<void> updatePassword({
    required String newPassword,
    String token = '',
    String email = '',
  }) async {
    await _dio.post(
      ApiEndpoints.resetPassword,
      data: {
        'token': token,
        'email': email,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore server errors during logout — we still clear local session
    }
    await _cache.clearToken();
    await _clearUser();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> checkSession() async {
    final token = await _cache.getToken();
    if (token == null || token.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromMap(json.decode(userJson) as Map<String, dynamic>);
  }

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toMap()));
  }

  Future<void> _clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
