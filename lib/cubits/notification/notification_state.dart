part of 'notification_cubit.dart';

sealed class NotificationState {}

final class NotificationInitial extends NotificationState {}

final class NotificationLoading extends NotificationState {}

final class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  NotificationsLoaded(this.notifications)
    : unreadCount = notifications.where((n) => !n.isRead).length;
}

final class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}
