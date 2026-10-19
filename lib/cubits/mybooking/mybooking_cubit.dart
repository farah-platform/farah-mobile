import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/data/models/home/myBooking_model.dart';
import 'package:farah/data/repositories/mybooking_repository.dart';
import 'mybooking_state.dart';

class MybookingCubit extends Cubit<MybookingState> {
  final MyBookingRepository bookingRepository;

  MybookingCubit(this.bookingRepository) : super(MybookingInitial());

  Future<void> loadBookings() async {
    emit(MybookingLoading());
    try {
      final bookings = await bookingRepository.getBookings();
      emit(MybookingLoaded(
        allBookings: bookings,
        filteredBookings: bookings,
        selectedFilter: 'الكل',
      ));
    } catch (e) {
      emit(MybookingError(e.toString()));
    }
  }

  void filterByStatus(String filter) {
    if (state is! MybookingLoaded) return;
    final currentState = state as MybookingLoaded;

    if (filter == 'الكل') {
      emit(MybookingLoaded(
        allBookings: currentState.allBookings,
        filteredBookings: currentState.allBookings,
        selectedFilter: filter,
      ));
      return;
    }

    final filtered = currentState.allBookings.where((booking) {
      switch (filter) {
        case 'مؤكدة':
          return booking.status == BookingStatus.confirmed;
        case 'منتهية':
          return booking.status == BookingStatus.completed;
        case 'قيدالمراجعة':
          return booking.status == BookingStatus.pending;
        case 'مرفوضة':
          return booking.status == BookingStatus.cancelled;
        default:
          return true;
      }
    }).toList();

    emit(MybookingLoaded(
      allBookings: currentState.allBookings,
      filteredBookings: filtered,
      selectedFilter: filter,
    ));
  }
}