import 'package:dio/dio.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_detail_state.dart';

/// Provide this cubit at the service-detail route level, not at app root.
/// Example:
///   BlocProvider(
///     create: (_) => ServiceDetailCubit(repo)..load(serviceId),
///     child: ServiceDetailScreen(),
///   )
class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  final ServiceRepository _repo;

  ServiceDetailCubit(this._repo) : super(ServiceDetailInitial());

  Future<void> load(String serviceId) async {
    emit(ServiceDetailLoading());

    try {
      final service = await _repo.fetchServiceById(serviceId);

      final provider = service.provider;

      if (provider == null) {
        emit(ServiceDetailError('بيانات مزود الخدمة غير متوفرة'));
        return;
      }

      emit(ServiceDetailLoaded(service: service, provider: provider));
    } catch (e) {
      emit(ServiceDetailError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 404) return 'الخدمة غير موجودة';
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
