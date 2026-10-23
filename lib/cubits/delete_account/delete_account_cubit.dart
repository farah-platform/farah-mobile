import 'package:dio/dio.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAccountState {
  final bool loading;
  final bool deleted;
  final String? error;

  const DeleteAccountState({
    this.loading = false,
    this.deleted = false,
    this.error,
  });
}

// فرح: حذف الحساب (للعميل والمزود). يرسل كلمة المرور الحالية لأن السيرفر بيطلبها،
// ولما ينجح بيتحرر الإيميل ويقدر صاحبه يسجّل فيه من جديد.
class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  final AuthRepository _repo;

  DeleteAccountCubit(this._repo) : super(const DeleteAccountState());

  Future<void> delete(String currentPassword) async {
    if (state.loading) return;
    if (currentPassword.isEmpty) {
      emit(const DeleteAccountState(error: 'أدخل كلمة المرور الحالية'));
      return;
    }
    emit(const DeleteAccountState(loading: true));
    try {
      await _repo.deleteAccount(currentPassword: currentPassword);
      if (isClosed) return;
      emit(const DeleteAccountState(deleted: true));
    } catch (e) {
      if (isClosed) return;
      emit(DeleteAccountState(error: _message(e)));
    }
  }

  String _message(Object e) {
    if (e is DioException) {
      if (e.response == null) return 'تحقق من اتصالك بالإنترنت';
      // 403: wrong password; 409: active bookings; 422: validation.
      if (e.response?.statusCode == 403) return 'كلمة المرور غير صحيحة';
      final data = e.response?.data;
      if (data is Map) {
        final message = (data['message'] ?? data['title'])?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
    }
    return 'تعذّر حذف الحساب، يرجى المحاولة مجدداً';
  }
}
