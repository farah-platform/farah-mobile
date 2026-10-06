import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/home/myBooking_model.dart';
import 'package:farah/data/repositories/mybooking_repository.dart';

class ApiMyBookingRepository implements MyBookingRepository {
  final DioClient dioClient;

  ApiMyBookingRepository({required this.dioClient});

  @override
  Future<List<MybookingModel>> getBookings() async {
    try {
      final response = await dioClient.dio.get('/bookings');
      final data = response.data;

      if (data is List) {
        return data.map((e) => MybookingModel.fromJson(e)).toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => MybookingModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('====== سبب مشكلة الـ API ======');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('==============================');

      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('message')) {
        throw errorData['message'];
      }
      throw 'فشل الاتصال بسجل الحجوزات';
    } catch (_) {
      throw 'حدث خطأ أثناء تحميل الحجوزات';
    }
  }
}
