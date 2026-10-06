import 'package:farah/data/models/home/myBooking_model.dart';

abstract class MybookingState {}

class MybookingInitial extends MybookingState {}

class MybookingLoading extends MybookingState {}

class MybookingLoaded extends MybookingState {
  final List<MybookingModel> allBookings;
  final List<MybookingModel> filteredBookings;
  final String selectedFilter;

  MybookingLoaded({
    required this.allBookings,
    required this.filteredBookings,
    this.selectedFilter = 'الكل',
  });
}

class MybookingError extends MybookingState {
  final String message;
  MybookingError(this.message);
}