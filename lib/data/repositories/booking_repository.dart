import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/booking_model.dart';

// TODO: paths below are not yet in the backend spec and will 404.
// Wire to real endpoints once they are documented.
class BookingRepository {
  final Dio _dio;

  BookingRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<BookingModel> createBooking({
    required String serviceId,
    required DateTime eventDate,
    String? notes,
  }) async {
    final res = await _dio.post(
      '/bookings',
      data: {
        'service_id': serviceId,
        'event_date': eventDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
    return BookingModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<BookingModel>> fetchUserBookings() async {
    final res = await _dio.get('/bookings');
    return (res.data['data'] as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookingModel>> fetchProviderBookings() async {
    final res = await _dio.get('/provider/bookings');
    return (res.data['data'] as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelBooking(String id) async {
    await _dio.put('/bookings/$id/cancel');
  }

  Future<void> confirmBooking(String id) async {
    await _dio.put('/bookings/$id/confirm');
  }
}
