enum BookingStatus { confirmed, pending, completed, cancelled }

class MybookingModel {
  final dynamic id;
  final String title;
  final String? imageUrl;
  final String date;
  final double price;
  final BookingStatus status;

  MybookingModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.date,
    required this.price,
    required this.status,
  });

  factory MybookingModel.fromJson(Map<String, dynamic> json) {
    return MybookingModel(
      id: json['id'] ?? '',
      title: json['service_name'] ?? json['title'] ?? 'حجز خدمة',
      imageUrl: json['image_url'] ?? json['image'],
      date: json['booking_date'] ?? json['date'] ?? '2026-09-25',
      price: (json['price'] != null)
          ? double.tryParse(json['price'].toString()) ?? 0.0
          : 0.0,
      status: _parseStatus(json['status']?.toString()),
    );
  }

  static BookingStatus _parseStatus(String? status) {
    final s = status?.toLowerCase() ?? '';
    if (s.contains('confirm') || s.contains('مؤكد'))
      return BookingStatus.confirmed;
    if (s.contains('pending') || s.contains('مراجعة'))
      return BookingStatus.pending;
    if (s.contains('complete') || s.contains('منتهي'))
      return BookingStatus.completed;
    return BookingStatus.cancelled;
  }
}
