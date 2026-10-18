import 'package:equatable/equatable.dart';

enum NotificationType {
  bookingConfirmed,
  bookingCancelled,
  newBooking,
  bookingCompleted,
  // Types sent by the API (NotificationService in the backend).
  bookingAccepted,
  bookingRejected,
  paymentProofSubmitted,
  paymentConfirmed,
  paymentRejected,
  general;

  static NotificationType fromApi(String? raw) {
    if (raw == 'booking_requested') return NotificationType.newBooking;
    final camel = (raw ?? '').replaceAllMapped(
      RegExp(r'_([a-z])'),
      (m) => m.group(1)!.toUpperCase(),
    );
    return NotificationType.values.firstWhere(
      (t) => t.name == camel,
      orElse: () => NotificationType.general,
    );
  }
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final NotificationType type;
  final String? referenceId;
  final String? resourceType;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.type,
    this.referenceId,
    this.resourceType,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'].toString(),
        title: map['title']?.toString() ?? '',
        body: map['body']?.toString() ?? '',
        isRead: map['is_read'] as bool? ?? false,
        type: NotificationType.fromApi(map['type'] as String?),
        referenceId: (map['resource_id'] ?? map['reference_id'])?.toString(),
        resourceType: map['resource_type']?.toString(),
        createdAt:
            DateTime.tryParse(map['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    type: type,
    referenceId: referenceId,
    resourceType: resourceType,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, isRead];
}
