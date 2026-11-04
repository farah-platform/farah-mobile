import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/repositories/api_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// فرح: تسجيل الدخول بـ Google لازم يمر على السيرفر (/auth/google) ويحفظ توكن السيرفر.
class _Cache extends CacheDatasource {
  String? saved;

  @override
  Future<String?> getToken() async => saved;

  @override
  Future<void> saveToken(String token) async => saved = token;
}

class _Recorder extends Interceptor {
  final List<RequestOptions> requests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': {
            'token': 'server-token',
            'user': {
              'id': 3,
              'name': 'api name',
              'email': 'api@gmail.com',
              'role': 'provider',
            },
          },
        },
      ),
    );
  }
}

class _Auth extends Fake implements GoogleSignInAuthentication {
  @override
  String? get idToken => 'google-id-token';
}

class _Account extends Fake implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication async => _Auth();
}

class _Google extends Fake implements GoogleSignIn {
  bool cancel = false;

  @override
  Future<GoogleSignInAccount?> signIn() async => cancel ? null : _Account();

  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('sends the Google id token to the server and keeps its token', () async {
    final recorder = _Recorder();
    final cache = _Cache();
    final client = DioClient(cache)..dio.interceptors.add(recorder);
    final repo = ApiAuthRepository(
      dioClient: client,
      cache: cache,
      googleSignIn: _Google(),
    );

    final user = await repo.signInWithGoogle(userType: 'provider');

    final request = recorder.requests.single;
    expect(request.path, '/auth/google');
    expect(request.data, {'id_token': 'google-id-token', 'user_type': 'provider'});
    expect(cache.saved, 'server-token');
    expect(user.role, 'provider');
  });

  test('a cancelled Google sign-in says so', () async {
    final cache = _Cache();
    final repo = ApiAuthRepository(
      dioClient: DioClient(cache)..dio.interceptors.add(_Recorder()),
      cache: cache,
      googleSignIn: _Google()..cancel = true,
    );

    expect(
      () => repo.signInWithGoogle(),
      throwsA(predicate((e) => e.toString().contains('تم إلغاء تسجيل الدخول'))),
    );
  });
}
