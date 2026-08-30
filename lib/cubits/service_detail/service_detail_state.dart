part of 'service_detail_cubit.dart';

sealed class ServiceDetailState {}

final class ServiceDetailInitial extends ServiceDetailState {}

final class ServiceDetailLoading extends ServiceDetailState {}

final class ServiceDetailLoaded extends ServiceDetailState {
  final ServiceModel service;
  final ServiceProviderModel provider;
  ServiceDetailLoaded({required this.service, required this.provider});
}

final class ServiceDetailError extends ServiceDetailState {
  final String message;
  ServiceDetailError(this.message);
}
