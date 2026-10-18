import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  // Workflow states returned by the API (CUSTOMER_BOOKING_HANDOFF.md).
  providerPending,
  paymentAwaiting,
  reviewUnderProof,
  confirmed,
  completed,
  rejected,
  cancelled,
  expired,
}

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
  final double? depositAmount;
  final String? currency;
  final String? reference;
  final String? notes;
  final String? paymentInstructions;
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
    this.depositAmount,
    this.currency,
    this.reference,
    this.notes,
    this.paymentInstructions,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final service = map['service'] is Map ? map['service'] as Map : const {};
    final pricing = map['pricing'] is Map ? map['pricing'] as Map : const {};
    final rawDate = map['event_date'] ?? map['booking_date'] ?? map['date'];
    return BookingModel(
      id: map['id']?.toString() ?? '',
      userId: (map['user_id'] ?? map['userId'])?.toString() ?? '',
      serviceId:
          (map['service_id'] ?? map['serviceId'] ?? service['id'])
              ?.toString() ??
          '',
      serviceName:
          (map['service_name'] ??
                  map['serviceName'] ??
                  map['title'] ??
                  service['title'])
              ?.toString() ??
          '',
      providerId: (map['provider_id'] ?? map['providerId'])?.toString() ?? '',
      providerName:
          (map['provider_name'] ?? map['providerName'] ?? '')?.toString() ?? '',
      category:
          (map['category_name'] ?? map['category'] ?? '')?.toString() ?? '',
      eventDate: rawDate != null
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
          : DateTime.now(),
      status: _parseStatus(map['status']),
      totalPrice:
          (map['total_price'] as num?)?.toDouble() ??
          (map['total_amount'] as num?)?.toDouble() ??
          (pricing['total'] as num?)?.toDouble() ??
          0.0,
      depositAmount: (pricing['deposit'] as num?)?.toDouble(),
      currency: pricing['currency']?.toString(),
      reference: map['reference']?.toString(),
      notes: map['notes'] as String?,
      paymentInstructions: map['payment_instructions']?.toString(),
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
    'payment_instructions': paymentInstructions,
    'created_at': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toJson() => toMap();

  static BookingStatus _parseStatus(dynamic rawStatus) {
    if (rawStatus == null) return BookingStatus.pending;
    // API sends snake_case (provider_pending); enum names are camelCase.
    final clean = rawStatus.toString().trim().toLowerCase().replaceAll('_', '');
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == clean,
      orElse: () {
        assert(false, 'Unknown booking status from server: "$rawStatus"');
        return BookingStatus.pending;
      },
    );
  }

  @override
  List<Object?> get props => [id];
}
