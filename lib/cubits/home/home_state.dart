part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final List<ServiceModel> services;
  final List<ServiceModel> featured;
  HomeLoaded({required this.services, required this.featured});
}

final class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
