abstract class ProviderServicesState {}

class ProviderServicesInitial extends ProviderServicesState {}

class ProviderServicesLoading extends ProviderServicesState {}

class ProviderServicesLoaded extends ProviderServicesState {
  final List<dynamic> services;
  ProviderServicesLoaded({required this.services});
}

class ProviderServicesError extends ProviderServicesState {
  final String message;
  ProviderServicesError({required this.message});
}

class ProviderServicesAdding extends ProviderServicesState {}

class ProviderServicesAddSuccess extends ProviderServicesState {}

class ProviderServicesAddError extends ProviderServicesState {
  final String message;
  ProviderServicesAddError({required this.message});
}
