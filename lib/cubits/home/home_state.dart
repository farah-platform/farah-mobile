part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final HomeResponseModel home;

  HomeLoaded({required this.home});
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
