import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/data/repositories/notification_repository.dart';

/// Real backend implementation of [NotificationRepository].
class ApiNotificationRepository implements NotificationRepository {
  final Dio _dio;

  ApiNotificationRepository({required DioClient dioClient})
    : _dio = dioClient.dio;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    final res = await _dio.get('/notifications');
    return (res.data['data'] as List)
        .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.put('/notifications/read-all');
  }
}
