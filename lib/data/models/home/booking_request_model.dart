class BookingRequestModel {
  final int serviceId;
  final String bookingDate;
  final String bookingTime;
  final String bookingSlot;
  final String? notes;

  BookingRequestModel({
    required this.serviceId,
    required this.bookingDate,
    required this.bookingTime,
    required this.bookingSlot,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      'booking_slot': bookingSlot,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes!.trim(),
    };
  }

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      serviceId: json['service_id'] ?? 0,
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
      bookingSlot: json['booking_slot'] ?? '',
      notes: json['notes'],
    );
  }
}
