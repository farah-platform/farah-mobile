import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/booking_model.dart';
import 'package:farah/data/repositories/booking_repository.dart';

/// Real backend implementation of [BookingRepository].
class ApiBookingRepository implements BookingRepository {
  final Dio _dio;

  ApiBookingRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
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

  @override
  Future<List<BookingModel>> fetchUserBookings() async {
    final res = await _dio.get('/bookings');
    return (res.data['data'] as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BookingModel>> fetchProviderBookings() async {
    final res = await _dio.get('/provider/bookings');
    return (res.data['data'] as List)
        .map((e) => BookingModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cancelBooking(String id) async {
    await _dio.put('/bookings/$id/cancel');
  }

  @override
  Future<void> confirmBooking(String id) async {
    await _dio.put('/bookings/$id/confirm');
  }
}
