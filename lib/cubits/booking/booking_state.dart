part of 'booking_cubit.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreated extends BookingState {
  final BookingModel booking;
  BookingCreated(this.booking);
}

class BookingsLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingsLoaded(this.bookings);
}

class BookingCancelled extends BookingState {}

class BookingConfirmed extends BookingState {}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}
