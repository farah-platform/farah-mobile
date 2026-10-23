enum BookingStatus { confirmed, pending, completed, cancelled }

class MybookingModel {
  final dynamic id;
  final String title;
  final String? imageUrl;
  final String date;
  final double price;
  final BookingStatus status;
  // فرح: حقول الدفع من GET /bookings، لفتح شاشة الدفع للحجز "بانتظار الدفع".
  final String rawStatus;
  final dynamic serviceId;
  final double deposit;
  final String currency;
  final String? paymentInstructions;

  MybookingModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.date,
    required this.price,
    required this.status,
    this.rawStatus = '',
    this.serviceId,
    this.deposit = 0,
    this.currency = 'ILS',
    this.paymentInstructions,
  });

  /// The provider accepted and set the deposit; the customer can pay now.
  bool get awaitingPayment => rawStatus == 'payment_awaiting';

  // Shape of GET /bookings (BookingController::bookingData): the title and
  // image sit under `service`, the price under `pricing`.
  factory MybookingModel.fromJson(Map<String, dynamic> json) {
    final service = json['service'] is Map ? json['service'] as Map : const {};
    final pricing = json['pricing'] is Map ? json['pricing'] as Map : const {};
    final price = pricing['total'] ?? json['price'];
    return MybookingModel(
      id: json['id'] ?? '',
      title:
          (service['title'] ?? json['service_name'] ?? json['title'])
              ?.toString() ??
          '',
      imageUrl: (service['image'] ?? json['image_url'] ?? json['image'])
          ?.toString(),
      date: (json['date'] ?? json['booking_date'])?.toString() ?? '',
      price: price != null ? double.tryParse(price.toString()) ?? 0.0 : 0.0,
      status: _parseStatus(json['status']?.toString()),
      rawStatus: json['status']?.toString() ?? '',
      serviceId: service['id'],
      deposit: double.tryParse(pricing['deposit']?.toString() ?? '') ?? 0,
      currency: pricing['currency']?.toString() ?? 'ILS',
      paymentInstructions: json['payment_instructions']?.toString(),
    );
  }

  static BookingStatus _parseStatus(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('confirm') || s.contains('مؤكد'))
      return BookingStatus.confirmed;
    // provider_pending, payment_awaiting and review_under_proof are all
    // still in progress for the customer.
    if (s.contains('pending') ||
        s.contains('awaiting') ||
        s.contains('review') ||
        s.contains('مراجعة'))
      return BookingStatus.pending;
    if (s.contains('complete') || s.contains('منتهي'))
      return BookingStatus.completed;
    return BookingStatus.cancelled;
  }
}
