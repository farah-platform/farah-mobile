import 'package:dio/dio.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _repo;

  ChangePasswordCubit(this._repo) : super(ChangePasswordInitial());

  void reset() => emit(ChangePasswordInitial());

  Future<void> change({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ChangePasswordLoading());
    try {
      await _repo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(ChangePasswordSuccess());
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        emit(ChangePasswordCurrentPasswordWrong());
      } else {
        final message = e.response?.data?['title'] as String? ??
            'حدث خطأ أثناء تغيير كلمة المرور، يرجى المحاولة مجدداً';
        emit(ChangePasswordError(message));
      }
    } catch (_) {
      emit(ChangePasswordError('حدث خطأ أثناء تغيير كلمة المرور، يرجى المحاولة مجدداً'));
    }
  }
}
