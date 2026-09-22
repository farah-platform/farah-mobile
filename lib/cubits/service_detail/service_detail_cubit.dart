import 'package:dio/dio.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_detail_state.dart';

class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  final ServiceRepository _repo;

  ServiceDetailCubit(this._repo) : super(ServiceDetailInitial());

  Future<void> load(String serviceId) async {
    emit(ServiceDetailLoading());

    try {
      final service = await _repo.fetchServiceById(serviceId);
      emit(ServiceDetailLoaded(service: service));
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً';
      }
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
