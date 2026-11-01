import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/repositories/support_repository.dart';

class ApiSupportRepository implements SupportRepository {
  final Dio _dio;

  ApiSupportRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<Map<String, dynamic>>> getFaqs({required String audience}) async {
    final res = await _dio.get(
      '/faqs',
      queryParameters: {'audience': audience},
    );
    final data = res.data['data'];
    return [
      if (data is List)
        for (final faq in data)
          if (faq is Map) Map<String, dynamic>.from(faq),
    ];
  }

  @override
  Future<Map<String, dynamic>> getSupportContacts() async {
    final res = await _dio.get(ApiEndpoints.settings);
    final data = res.data['data'];
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    final res = await _dio.get('/notification-settings');
    return res.data['data']?['enabled'] != false;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _dio.put('/notification-settings', data: {'enabled': enabled});
  }
}
