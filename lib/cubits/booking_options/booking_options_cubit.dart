import 'package:dio/dio.dart';
import 'package:farah/data/models/booking_options_model.dart';
import 'package:farah/data/repositories/booking_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BookingOptionsState {}

class BookingOptionsLoading extends BookingOptionsState {}

class BookingOptionsLoaded extends BookingOptionsState {
  final BookingOptionsModel options;
  BookingOptionsLoaded(this.options);
}

class BookingOptionsError extends BookingOptionsState {
  final String message;
  BookingOptionsError(this.message);
}

class BookingOptionsCubit extends Cubit<BookingOptionsState> {
  final BookingRepository _repo;
  final int serviceId;

  BookingOptionsCubit(this._repo, {required this.serviceId})
    : super(BookingOptionsLoading());

  Future<void> loadMonth(DateTime month) async {
    emit(BookingOptionsLoading());
    final key =
        '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';
    try {
      emit(
        BookingOptionsLoaded(await _repo.fetchBookingOptions(serviceId, key)),
      );
    } catch (e) {
      emit(BookingOptionsError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final message = (data['title'] ?? data['message'])?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    return 'تعذر جلب المواعيد المتاحة، يرجى المحاولة مجدداً';
  }
}
