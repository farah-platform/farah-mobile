import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/booking_model.dart';
import 'package:farah/data/models/home/booking_request_model.dart';
import 'package:farah/data/repositories/booking_repository.dart';

class ApiBookingRepository implements BookingRepository {
  final DioClient _dioClient;

  ApiBookingRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Dio get _dio => _dioClient.dio;

  @override
  Future<BookingModel> createBooking(BookingRequestModel request) async {
    final res = await _dio.post('/bookings', data: request.toJson());

    final rawData = res.data is Map<String, dynamic>
        ? (res.data['data'] ?? res.data)
        : res.data;

    return BookingModel.fromJson(rawData as Map<String, dynamic>);
  }

  @override
  Future<List<BookingModel>> fetchUserBookings() async {
    final res = await _dio.get('/bookings');
    final list = res.data is Map<String, dynamic>
        ? (res.data['data'] as List? ?? [])
        : (res.data as List? ?? []);

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => BookingModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<BookingModel>> fetchProviderBookings() async {
    final res = await _dio.get('/provider/bookings');
    final list = res.data is Map<String, dynamic>
        ? (res.data['data'] as List? ?? [])
        : (res.data as List? ?? []);

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => BookingModel.fromJson(e))
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
