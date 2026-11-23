import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';

class DioClient {
  late final Dio _dio;
  final CacheDatasource _cache;

  DioClient(this._cache) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        // فرح: 15 ثانية للاتصال بدل 60 حتى ما يضل التطبيق يحمّل بدون نت.
        // الإرسال 60 لأن رفع الصور والإشعارات بياخد وقت.
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(_AuthInterceptor(_cache));
  }

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  final CacheDatasource _cache;
  _AuthInterceptor(this._cache);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _cache.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

