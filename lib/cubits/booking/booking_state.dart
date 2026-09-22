part of 'booking_cubit.dart';

sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoading extends BookingState {}

final class BookingCreated extends BookingState {
  final BookingModel booking;
  BookingCreated(this.booking);
}

final class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingsLoaded(this.bookings);
}

final class BookingCancelled extends BookingState {}

final class BookingConfirmed extends BookingState {}

final class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
