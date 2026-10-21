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

  ProviderDashboardCubit(this._providerRepository)
    : super(ProviderDashboardInitial());

  /// [refresh] keeps the current data on screen while it reloads.
  Future<void> loadDashboard({bool refresh = false}) async {
    final silent = refresh && state is ProviderDashboardLoaded;
    if (!silent) emit(ProviderDashboardLoading());
    try {
      final data = await _providerRepository.getDashboardData();
      if (isClosed) return;
      emit(ProviderDashboardLoaded(data: data));
    } catch (e) {
      if (isClosed) return;
      // فرح: لو فشل التحديث الصامت نبقي البيانات الحالية بدل شاشة الخطأ.
      if (!silent) {
        emit(ProviderDashboardError('حدث خطأ أثناء جلب بيانات لوحة التحكم'));
      }
    }
  }
}
