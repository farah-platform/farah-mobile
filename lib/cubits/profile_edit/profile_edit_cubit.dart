import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final ProfileRepository _repo;

  ProfileEditCubit(this._repo) : super(ProfileEditInitial());

  void reset() => emit(ProfileEditInitial());

  Future<void> load() async {
    emit(ProfileEditLoading());
    try {
      final user = await _repo.fetchUserProfile();
      emit(ProfileEditReady(user: user));
    } catch (_) {
      emit(ProfileEditError('تعذّر تحميل البيانات، يرجى المحاولة مجدداً'));
    }
  }

  Future<void> save({
    required String name,
    required String phone,
    required String region,
    File? avatar,
  }) async {
    final current = state;
    if (current is! ProfileEditReady) return;

    emit(ProfileEditSaving(current.user));
    try {
      final user = await _repo.updateUserProfile(
        name: name.trim(),
        phone: phone.trim(),
        region: region.trim(),
        avatar: avatar,
      );

      emit(ProfileEditSuccess(user));
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final rawErrors = e.response?.data?['errors'];
        final fieldErrors = _extractFieldErrors(rawErrors);
        emit(ProfileEditReady(
          user: current.user,
          dirty: true,
          fieldErrors: fieldErrors,
        ));
      } else {
        final message = e.response?.data?['title'] as String? ??
            'حدث خطأ أثناء الحفظ، يرجى المحاولة مجدداً';
        emit(ProfileEditError(message));
      }
    } catch (_) {
      emit(ProfileEditError('حدث خطأ أثناء الحفظ، يرجى المحاولة مجدداً'));
    }
  }

  Map<String, String> _extractFieldErrors(dynamic rawErrors) {
    if (rawErrors is! Map) return {};
    final result = <String, String>{};
    rawErrors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key.toString()] = value.first.toString();
      } else if (value is String) {
        result[key.toString()] = value;
      }
    });
    return result;
  }
}
