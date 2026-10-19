import 'package:farah/data/models/home/myBooking_model.dart';

abstract class MyBookingRepository {
  Future<List<MybookingModel>> getBookings();
}