part of 'home_cubit.dart';

sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

final class HomeLoaded extends HomeState {
  final HomeResponseModel home;
  // فرح: true لما تكون البيانات من آخر مرة (بدون نت).
  final bool offline;

  HomeLoaded({required this.home, this.offline = false});
}

final class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}
