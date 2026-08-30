import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final Dio _dio;
  final CacheDatasource _cache;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  AuthRepository({
    required DioClient dioClient,
    required CacheDatasource cache,
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
  })  : _dio = dioClient.dio,
        _cache = cache,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );
    await _cache.saveToken(res.data['token'] as String);
    return UserModel.fromMap(res.data['user'] as Map<String, dynamic>);
  }

  // cityId is int? — the backend spec field is city_id (integer).
  // The sign-up screen currently passes null; it will be replaced with a
  // real city picker in Part B.
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  }) async {
    final res = await _dio.post(
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
    await _cache.saveToken(res.data['token'] as String);
    return UserModel.fromMap(res.data['user'] as Map<String, dynamic>);
  }

  // ── Firebase / Google Sign-In ──────────────────────────────────────────────
  // Scope decision pending. The '/auth/google' path does not exist in the
  // current backend spec; the literal is kept here so this code continues to
  // compile unchanged. Do not remove without a backend endpoint to back it.
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('تم إلغاء تسجيل الدخول');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    final idToken = await _firebaseAuth.currentUser!.getIdToken();

    final res = await _dio.post(
      '/auth/google', // pending backend spec — see scope decision
      data: {'idToken': idToken},
    );
    await _cache.saveToken(res.data['token'] as String);
    return UserModel.fromMap(res.data['user'] as Map<String, dynamic>);
  }
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> sendPasswordReset({required String email}) async {
    await _dio.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email.trim()},
    );
  }

  // Spec: POST /reset-password  body: token, email, password, password_confirmation
  // token and email come from the deep-link URL; the screen will supply them in
  // Part B. password_confirmation is added here; the rest will be wired in Step 4.
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

  Future<void> logout() async {
    await _cache.clearToken();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
