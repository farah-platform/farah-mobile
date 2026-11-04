import 'package:farah/data/datasources/local/offline_cache.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderDashboardState {}

class ProviderDashboardInitial extends ProviderDashboardState {}

class ProviderDashboardLoading extends ProviderDashboardState {}

class ProviderDashboardLoaded extends ProviderDashboardState {
  final Map<String, dynamic> data;
  // فرح: true لما تكون البيانات من آخر مرة (بدون نت).
  final bool offline;
  ProviderDashboardLoaded({required this.data, this.offline = false});
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
      // فرح: بدون نت نعرض آخر لوحة محفوظة.
      if (OfflineCache.isOffline(e)) {
        final cached = await OfflineCache.read(OfflineCache.providerDashboard);
        if (isClosed) return;
        if (cached is Map) {
          emit(
            ProviderDashboardLoaded(
              data: Map<String, dynamic>.from(cached),
              offline: true,
            ),
          );
          return;
        }
      }
      if (isClosed) return;
      // فرح: لو فشل التحديث الصامت نبقي البيانات الحالية بدل شاشة الخطأ.
      if (!silent) {
        emit(
          ProviderDashboardError(
            OfflineCache.isOffline(e)
                ? 'لا يوجد اتصال بالإنترنت'
                : 'حدث خطأ أثناء جلب بيانات لوحة التحكم',
          ),
        );
      }
    }
  }
}
