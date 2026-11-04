import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// فرح: آخر بيانات وصلت من السيرفر للشاشات الرئيسية (رئيسية العميل، لوحة المزود، حالة التوثيق)،
// حتى يفتح التطبيق بدون نت ويعرضها بدل التحميل اللانهائي. تنمسح عند تسجيل الخروج أو دخول حساب جديد.
class OfflineCache {
  static const _prefix = 'offline_cache:';

  static const home = 'home';
  static const providerDashboard = 'provider_dashboard';
  static const providerVerification = 'provider_verification';

  static Future<void> save(String key, Object? json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', jsonEncode(json));
    } catch (_) {
      // Caching is best effort; never break the screen for it.
    }
  }

  static Future<dynamic> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      return raw == null ? null : jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().where((k) => k.startsWith(_prefix))) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  /// No answer from the server: no internet, timeout or server down.
  static bool isOffline(Object error) =>
      error is DioException &&
      (error.response == null ||
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout);
}
