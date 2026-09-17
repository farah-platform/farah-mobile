import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class BookingModel extends Equatable {
  final String id;
  final String userId;
  final String serviceId;
  final String serviceName;
  final String providerId;
  final String providerName;
  final String category;
  final DateTime eventDate;
  final BookingStatus status;
  final double totalPrice;
  final String? notes;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.providerId,
    required this.providerName,
    required this.category,
    required this.eventDate,
    required this.status,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id']?.toString() ?? '',
      userId: (map['user_id'] ?? map['userId'])?.toString() ?? '',
      serviceId: (map['service_id'] ?? map['serviceId'])?.toString() ?? '',
      serviceName:
          (map['service_name'] ?? map['serviceName'] ?? map['title'])
              ?.toString() ??
          '',
      providerId: (map['provider_id'] ?? map['providerId'])?.toString() ?? '',
      providerName:
          (map['provider_name'] ?? map['providerName'] ?? '')?.toString() ?? '',
      category:
          (map['category_name'] ?? map['category'] ?? '')?.toString() ?? '',
      eventDate: map['event_date'] != null
          ? DateTime.tryParse(map['event_date'].toString()) ?? DateTime.now()
          : (map['booking_date'] != null
                ? DateTime.tryParse(map['booking_date'].toString()) ??
                      DateTime.now()
                : DateTime.now()),
      status: _parseStatus(map['status']),
      totalPrice:
          (map['total_price'] as num?)?.toDouble() ??
          (map['total_amount'] as num?)?.toDouble() ??
          0.0,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      BookingModel.fromMap(json);

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'service_id': serviceId,
    'service_name': serviceName,
    'provider_id': providerId,
    'provider_name': providerName,
    'category': category,
    'event_date': eventDate.toIso8601String(),
    'status': status.name,
    'total_price': totalPrice,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toJson() => toMap();

  static BookingStatus _parseStatus(dynamic rawStatus) {
    if (rawStatus == null) return BookingStatus.pending;
    final clean = rawStatus.toString().trim().toLowerCase();
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == clean,
      orElse: () => BookingStatus.pending,
    );
  }

  @override
  List<Object?> get props => [id];
}
