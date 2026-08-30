import 'package:equatable/equatable.dart';
import 'package:farah/data/models/booking_model.dart';

class OrderModel extends Equatable {
  final String id;
  final String serviceName;
  final String providerName;
  final String category;
  final DateTime eventDate;
  final BookingStatus status;
  final double totalPrice;

  const OrderModel({
    required this.id,
    required this.serviceName,
    required this.providerName,
    required this.category,
    required this.eventDate,
    required this.status,
    required this.totalPrice,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
    id: map['id'] as String,
    serviceName: map['service_name'] as String,
    providerName: map['provider_name'] as String,
    category: map['category'] as String,
    eventDate: DateTime.parse(map['event_date'] as String),
    status: BookingStatus.values.byName(map['status'] as String),
    totalPrice: (map['total_price'] as num).toDouble(),
  );

  factory OrderModel.fromBooking(BookingModel booking) => OrderModel(
    id: booking.id,
    serviceName: booking.serviceName,
    providerName: booking.providerName,
    category: booking.category,
    eventDate: booking.eventDate,
    status: booking.status,
    totalPrice: booking.totalPrice,
  );

  @override
  List<Object?> get props => [id];
}
