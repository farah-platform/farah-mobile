import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/data/models/service_provider_model.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileCubit(this._repo) : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    emit(ProfileLoading());
    try {
      final user = await _repo.fetchUserProfile();
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_mapError(e)));
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? region,
  }) async {
    emit(ProfileLoading());
    try {
      final user = await _repo.updateUserProfile(
        name: name,
        phone: phone,
        region: region,
      );
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_mapError(e)));
    }
  }

  Future<void> uploadAvatar(File image) async {
    emit(ProfileLoading());
    try {
      final user = await _repo.uploadAvatar(image);
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(ProfileError(_mapError(e)));
    }
  }

  Future<void> loadProviderProfile() async {
    emit(ProfileLoading());
    try {
      final provider = await _repo.fetchProviderProfile();
      emit(ProviderProfileLoaded(provider));
    } catch (e) {
      emit(ProfileError(_mapError(e)));
    }
  }

  Future<void> updateProviderProfile({
    String? name,
    String? phone,
    String? region,
    String? description,
    List<String>? categories,
  }) async {
    emit(ProfileLoading());
    try {
      final provider = await _repo.updateProviderProfile(
        name: name,
        phone: phone,
        region: region,
        description: description,
        categories: categories,
      );
      emit(ProviderProfileLoaded(provider));
    } catch (e) {
      emit(ProfileError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final message = e.response?.data?['message'] as String?;
      if (message != null && message.isNotEmpty) return message;
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
