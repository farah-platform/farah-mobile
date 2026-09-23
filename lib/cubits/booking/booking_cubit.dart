import 'package:dio/dio.dart';
import 'package:farah/data/models/booking_model.dart';
import 'package:farah/data/models/home/booking_request_model.dart';
import 'package:farah/data/repositories/booking_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _repo;

  BookingCubit(this._repo) : super(BookingInitial());

  Future<void> createBooking(BookingRequestModel request) async {
    emit(BookingLoading());
    try {
      final booking = await _repo.createBooking(request);
      emit(BookingCreated(booking));
    } catch (e) {
      emit(BookingError(_mapError(e)));
    }
  }

  Future<void> loadUserBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await _repo.fetchUserBookings();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(_mapError(e)));
    }
  }

  Future<void> loadProviderBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await _repo.fetchProviderBookings();
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(_mapError(e)));
    }
  }

  Future<void> cancelBooking(String id) async {
    emit(BookingLoading());
    try {
      await _repo.cancelBooking(id);
      emit(BookingCancelled());
    } catch (e) {
      emit(BookingError(_mapError(e)));
    }
  }

  Future<void> confirmBooking(String id) async {
    emit(BookingLoading());
    try {
      await _repo.confirmBooking(id);
      emit(BookingConfirmed());
    } catch (e) {
      emit(BookingError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final message = e.response?.data?['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً';
      }
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
