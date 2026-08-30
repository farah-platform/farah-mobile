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

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'] as String,
    userId: map['user_id'] as String,
    serviceId: map['service_id'] as String,
    serviceName: map['service_name'] as String,
    providerId: map['provider_id'] as String,
    providerName: map['provider_name'] as String,
    category: map['category'] as String,
    eventDate: DateTime.parse(map['event_date'] as String),
    status: BookingStatus.values.byName(map['status'] as String),
    totalPrice: (map['total_price'] as num).toDouble(),
    notes: map['notes'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

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

  @override
  List<Object?> get props => [id];
}
