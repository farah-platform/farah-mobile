import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderDashboardState {}

class ProviderDashboardInitial extends ProviderDashboardState {}
class ProviderDashboardLoading extends ProviderDashboardState {}
class ProviderDashboardLoaded extends ProviderDashboardState {
  final Map<String, dynamic> data;
  ProviderDashboardLoaded({required this.data});
}
class ProviderDashboardError extends ProviderDashboardState {
  final String message;
  ProviderDashboardError(this.message);
}

class ProviderDashboardCubit extends Cubit<ProviderDashboardState> {
  final ProviderRepository _providerRepository;

  ProviderDashboardCubit(this._providerRepository) : super(ProviderDashboardInitial());

  Future<void> loadDashboard() async {
    emit(ProviderDashboardLoading());
    try {
      final data = await _providerRepository.getDashboardData();
      emit(ProviderDashboardLoaded(data: data));
    } catch (e) {
      emit(ProviderDashboardError('حدث خطأ أثناء جلب بيانات لوحة التحكم'));
    }
  }
}
