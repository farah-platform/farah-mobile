/// Availability returned by GET /services/{id}/booking-options for one month.
class BookingOptionsModel {
  final String month;
  final double price;
  final String currency;
  final List<BookingDayModel> days;

  const BookingOptionsModel({
    required this.month,
    required this.price,
    required this.currency,
    required this.days,
  });

  factory BookingOptionsModel.fromJson(Map<String, dynamic> json) {
    return BookingOptionsModel(
      month: json['month']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? '',
      days:
          (json['days'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(BookingDayModel.fromJson)
              .toList() ??
          [],
    );
  }

  BookingDayModel? dayOf(int day) {
    for (final d in days) {
      if (d.day == day) return d;
    }
    return null;
  }
}

class BookingDayModel {
  final String date;
  final int day;
  final bool isPast;
  final bool isAvailable;
  final List<BookingOptionSlotModel> slots;

  const BookingDayModel({
    required this.date,
    required this.day,
    required this.isPast,
    required this.isAvailable,
    required this.slots,
  });

  factory BookingDayModel.fromJson(Map<String, dynamic> json) {
    return BookingDayModel(
      date: json['date']?.toString() ?? '',
      day: (json['day'] as num?)?.toInt() ?? 0,
      isPast: json['is_past'] == true,
      isAvailable: json['is_available'] == true,
      slots:
          (json['slots'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(BookingOptionSlotModel.fromJson)
              .toList() ??
          [],
    );
  }
}

class BookingOptionSlotModel {
  final String? label;
  final String startTime;
  final String? endTime;
  final double price;
  final bool isAvailable;

  const BookingOptionSlotModel({
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isAvailable,
  });

  factory BookingOptionSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingOptionSlotModel(
      label: json['label']?.toString(),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isAvailable: json['is_available'] == true,
    );
  }
}
