import 'package:dio/dio.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ServiceRepository _repo;

  HomeCubit(this._repo) : super(HomeInitial());

  Future<void> loadServices({String? category, String? region}) async {
    emit(HomeLoading());
    try {
      final services = await _repo.fetchServices(
        category: category,
        region: region,
      );
      final featured = services.where((s) => s.rating >= 4.5).toList();
      emit(HomeLoaded(services: services, featured: featured));
    } catch (e) {
      emit(HomeError(_mapError(e)));
    }
  }

  Future<void> searchServices(String query) async {
    if (query.trim().isEmpty) {
      loadServices();
      return;
    }
    emit(HomeLoading());
    try {
      final services = await _repo.fetchServices(query: query.trim());
      emit(HomeLoaded(services: services, featured: const []));
    } catch (e) {
      emit(HomeError(_mapError(e)));
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
