import 'package:farah/data/models/booking_model.dart';
import 'package:farah/data/models/booking_options_model.dart';
import 'package:farah/data/models/home/booking_request_model.dart';

abstract class BookingRepository {
  Future<BookingOptionsModel> fetchBookingOptions(int serviceId, String month);
  Future<BookingModel> createBooking(BookingRequestModel request);
  Future<List<BookingModel>> fetchUserBookings();
  Future<List<BookingModel>> fetchProviderBookings();
  Future<void> cancelBooking(String id);
}
