import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/models/auth/city_model.dart';
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
  GoogleSignIn? _googleSignInOverride;
  FirebaseAuth? _firebaseAuthOverride;

  GoogleSignIn get _googleSignIn => _googleSignInOverride ??= GoogleSignIn(
    serverClientId:
        '800173223794-8kvbhprgpt0g8r0l9scab0br4c06jqsn.apps.googleusercontent.com',
  );

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ??= FirebaseAuth.instance;

  ApiAuthRepository({
    required DioClient dioClient,
    required CacheDatasource cache,
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
  }) : _dio = dioClient.dio,
       _cache = cache,
       _googleSignInOverride = googleSignIn,
       _firebaseAuthOverride = firebaseAuth;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> requestData = {
      'email': email.trim(),
      'password': password,
    };

    try {
      print('📤 [LOGIN SENDING]: $requestData');

      final res = await _dio.post(ApiEndpoints.login, data: requestData);

      print('✅ [LOGIN STATUS]: ${res.statusCode}');
      print('✅ [LOGIN RESPONSE]: ${res.data}');

      final payload = res.data['data'] as Map<String, dynamic>;
      await _cache.saveToken(payload['token'] as String);
      final user = UserModel.fromMap(payload['user'] as Map<String, dynamic>);
      await _persistUser(user);
      return user;
    } on DioException catch (e) {
      print('🛑 [LOGIN STATUS]: ${e.response?.statusCode}');
      print('🛑 [LOGIN ERROR RESPONSE]: ${e.response?.data}');

      final serverMsg =
          e.response?.data?['message'] ??
          e.response?.data?['error'] ??
          'فشل تسجيل الدخول';
      throw Exception(serverMsg);
    } catch (e) {
      print('❌ [LOGIN PARSING ERROR]: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  }) async {
    final Map<String, dynamic> requestData = {
      'name': name,
      'email': email.trim(),
      'phone': phone,
      'password': password,
      'password_confirmation': password,
      if (userType != null) 'user_type': userType,
      if (cityId != null) 'city_id': cityId,
    };

    try {
      print('📤 [REGISTER SENDING]: ${json.encode(requestData)}');

      final res = await _dio.post(ApiEndpoints.register, data: requestData);

      print('✅ [REGISTER STATUS]: ${res.statusCode}');
      print('✅ [REGISTER RESPONSE]: ${res.data}');

      final payload = res.data['data'] as Map<String, dynamic>;
      await _cache.saveToken(payload['token'] as String);
      final user = UserModel.fromMap(payload['user'] as Map<String, dynamic>);
      await _persistUser(user);
      return user;
    } on DioException catch (e) {
      print('🛑 [REGISTER STATUS]: ${e.response?.statusCode}');
      print('🛑 [REGISTER ERROR RESPONSE]: ${e.response?.data}');

      final serverMsg =
          e.response?.data?['message'] ??
          e.response?.data?['errors']?.toString() ??
          'البيانات المدخلة غير صحيحة';
      throw Exception(serverMsg);
    } catch (e) {
      print('❌ [REGISTER PARSING ERROR]: $e');
      rethrow;
    }
  }

  @override
  Future<List<CityModel>> getCities() async {
    final res = await _dio.get(ApiEndpoints.cities);
    if (res.data != null && res.data['data'] != null) {
      final List list = res.data['data'] as List;
      return list
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

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
    );
    await _persistUser(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await _dio.post(ApiEndpoints.forgotPassword, data: {'email': email.trim()});
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    required String token,
    required String email,
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
      // تجاهل أخطاء السيرفر عند تسجيل الخروج
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
