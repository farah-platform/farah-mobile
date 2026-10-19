import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'provider_services_state.dart';

class ProviderServicesCubit extends Cubit<ProviderServicesState> {
  final ProviderRepository _repository;

  ProviderServicesCubit(this._repository) : super(ProviderServicesInitial());

  Future<void> loadServices() async {
    if (isClosed) return;
    emit(ProviderServicesLoading());
    try {
      final services = await _repository.getProviderServices();
      if (isClosed) return;
      emit(ProviderServicesLoaded(services: services));
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesError(message: _mapError(e)));
    }
  }

  Future<void> loadFormData() async {
    if (isClosed) return;
    emit(ProviderServicesLoading());
    try {
      final categories = await _repository.getCategories();
      if (isClosed) return;
      emit(ProviderServicesFormReady(categories: categories));
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesError(message: _mapError(e, 'تعذّر تحميل الفئات')));
    }
  }

  Future<void> addService(
    Map<String, dynamic> data,
    List<dynamic> images,
  ) async {
    if (isClosed) return;
    emit(ProviderServicesAdding());
    try {
      final files = images.whereType<File>().toList();
      await _repository.addProviderService(data, files);
      if (isClosed) return;
      emit(ProviderServicesAddSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderServicesAddError(
          message: _mapError(e, 'حدث خطأ أثناء إضافة الخدمة'),
        ),
      );
    }
  }

  Future<void> updateService(
    int id,
    Map<String, dynamic> data,
    List<dynamic> newImages,
  ) async {
    if (isClosed) return;
    emit(ProviderServicesAdding());
    try {
      final files = newImages.whereType<File>().toList();
      await _repository.updateProviderService(id, data, files);
      if (isClosed) return;
      emit(ProviderServicesAddSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderServicesAddError(
          message: _mapError(e, 'حدث خطأ أثناء التعديل'),
        ),
      );
    }
  }

  Future<void> deleteService(int id) async {
    if (isClosed) return;
    try {
      await _repository.deleteProviderService(id);
      loadServices();
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesError(message: _mapError(e)));
    }
  }

  Future<void> toggleVisibility(int id, bool isAvailable) async {
    if (isClosed) return;
    try {
      await _repository.toggleServiceVisibility(id, isAvailable);
      loadServices();
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesError(message: _mapError(e)));
    }
  }

  String _mapError(
    Object e, [
    String fallback = 'حدث خطأ، يرجى المحاولة مجدداً',
  ]) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final message = (data['title'] ?? data['message'])?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    return fallback;
  }
}
