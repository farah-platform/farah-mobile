import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheDatasource {
  static const _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    // EncryptedSharedPreferences requires Android API 23+.
    // build.gradle.kts sets minSdk = 23 to enforce this.
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    await _migrateFromSharedPreferences();
    return _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // One-time migration: if a token was persisted in the old SharedPreferences
  // store, move it to secure storage and delete the plaintext copy.
  // After the first successful migration the key no longer exists in
  // SharedPreferences, so subsequent calls return immediately.
  Future<void> _migrateFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_tokenKey);
    if (legacy == null) return;
    await _storage.write(key: _tokenKey, value: legacy);
    await prefs.remove(_tokenKey);
  }
}
