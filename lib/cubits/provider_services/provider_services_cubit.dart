import 'dart:io';
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
      emit(ProviderServicesError(message: e.toString()));
    }
  }

  Future<void> addService(Map<String, dynamic> data, List<dynamic> images) async {
    if (isClosed) return;
    emit(ProviderServicesAdding());
    try {
      final files = images.whereType<File>().toList();
      await _repository.addProviderService(data, files);
      if (isClosed) return;
      emit(ProviderServicesAddSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesAddError(message: 'حدث خطأ أثناء إضافة الخدمة'));
    }
  }

  Future<void> updateService(int id, Map<String, dynamic> data, List<dynamic> newImages) async {
    if (isClosed) return;
    emit(ProviderServicesAdding());
    try {
      final files = newImages.whereType<File>().toList();
      await _repository.updateProviderService(id, data, files);
      if (isClosed) return;
      emit(ProviderServicesAddSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesAddError(message: 'حدث خطأ أثناء التعديل'));
    }
  }

  Future<void> deleteService(int id) async {
    if (isClosed) return;
    try {
      await _repository.deleteProviderService(id);
      loadServices();
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesError(message: e.toString()));
    }
  }

  Future<void> toggleVisibility(int id) async {
    if (isClosed) return;
    try {
      await _repository.toggleServiceVisibility(id);
      loadServices();
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServicesError(message: e.toString()));
    }
  }
}
