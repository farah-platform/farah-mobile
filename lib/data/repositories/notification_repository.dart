import 'package:farah/data/models/notification_model.dart';

/// Abstract interface for notification operations.
abstract class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
