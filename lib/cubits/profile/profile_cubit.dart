import 'dart:io';

import 'package:dio/dio.dart';
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

  String _mapError(Object e) {
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
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
