import 'package:farah/data/models/booking_model.dart';

/// Abstract interface for booking operations.
abstract class BookingRepository {
  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime eventDate,
    String? notes,
  });

  Future<List<BookingModel>> fetchUserBookings();

  Future<List<BookingModel>> fetchProviderBookings();

  Future<void> cancelBooking(String id);

  Future<void> confirmBooking(String id);
}
