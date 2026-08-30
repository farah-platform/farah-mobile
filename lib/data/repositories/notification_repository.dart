import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/notification_model.dart';

// TODO: paths below are not yet in the backend spec and will 404.
// Wire to real endpoints once they are documented.
class NotificationRepository {
  final Dio _dio;

  NotificationRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<List<NotificationModel>> fetchNotifications() async {
    final res = await _dio.get('/notifications');
    return (res.data['data'] as List)
        .map((e) => NotificationModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.put('/notifications/read-all');
  }
}
