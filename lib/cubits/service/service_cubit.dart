import 'package:dio/dio.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository _repo;

  ServiceCubit(this._repo) : super(ServiceInitial());

  Future<void> loadServices({
    int? categoryId,
    String? categorySlug,
    String? search,
    String? sortBy,
    int? cityId,
    double? latitude,
    double? longitude,
    int? perPage,
    int? page,
  }) async {
    emit(ServiceLoading());

    try {
      final services = await _repo.fetchServices(
        categoryId: categoryId,
        categorySlug: categorySlug,
        search: search,
        sortBy: sortBy,
        cityId: cityId,
        latitude: latitude,
        longitude: longitude,
        perPage: perPage,
        page: page,
      );

      emit(ServiceLoaded(services));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(ServiceLoaded([]));
      } else {
        emit(ServiceError(_mapError(e)));
      }
    } catch (e) {
      emit(ServiceError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
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
