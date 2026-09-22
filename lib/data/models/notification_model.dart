import 'package:equatable/equatable.dart';

enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  newBooking,
  bookingCompleted,
  general,
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final NotificationType type;
  final String? referenceId;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.type,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        isRead: map['is_read'] as bool? ?? false,
        type: NotificationType.values.byName(
          map['type'] as String? ?? 'general',
        ),
        referenceId: map['reference_id'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    type: type,
    referenceId: referenceId,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, isRead];
}
