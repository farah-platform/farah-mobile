class NotificationModel {
  final String id;
  final String title;
  final String time;
  final bool isRead;

  // Getter لتسهيل الفحص في الشاشة سواء استخدمتِ isRead أو isUnread
  bool get isUnread => !isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.time,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['data']?['message'] ?? '',
      time: json['created_at']?.toString() ?? 'منذ قليل',
      isRead: json['read_at'] != null || json['is_read'] == true,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? time,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}