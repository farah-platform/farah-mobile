class BookingRequestModel {
  final int serviceId;
  final String bookingDate;
  final String period;
  final double depositPaid;
  final double totalAmount;
  final String? notes;

  BookingRequestModel({
    required this.serviceId,
    required this.bookingDate,
    required this.period,
    required this.depositPaid,
    required this.totalAmount,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'booking_date': bookingDate,
      'period': period,
      'deposit_paid': depositPaid,
      'total_amount': totalAmount,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
