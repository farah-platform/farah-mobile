import 'package:dio/dio.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;

  AuthCubit(this._repo) : super(AuthInitial());

  Future<void> login({required String email, required String password}) async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      final user = await _repo.login(email: email, password: password);
      if (isClosed) return;
      emit(AuthSuccess(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      final user = await _repo.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
        cityId: cityId,
      );
      if (isClosed) return;
      emit(AuthSuccess(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> signInWithGoogle() async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      final user = await _repo.signInWithGoogle();
      if (isClosed) return;
      emit(AuthSuccess(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      await _repo.sendPasswordReset(email: email);
      if (isClosed) return;
      emit(AuthPasswordResetSent());
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> updatePassword({
    required String newPassword,
    required String token,
    required String email,
  }) async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      await _repo.updatePassword(
        newPassword: newPassword,
        token: token,
        email: email,
      );
      if (isClosed) return;
      emit(AuthPasswordUpdated());
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> logout() async {
    if (isClosed) return;
    try {
      await _repo.logout();
    } catch (_) {}
    if (isClosed) return;
    emit(AuthInitial());
  }

  Future<void> checkSession() async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      final user = await _repo.checkSession();
      if (isClosed) return;
      if (user != null) {
        if (user.role == 'guest') {
          emit(AuthGuest());
        } else {
          emit(AuthSuccess(user));
        }
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      if (isClosed) return;
      emit(AuthInitial());
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      final title = e.response?.data?['title'] as String?;
      if (title != null && title.isNotEmpty) return title;
      switch (e.response?.statusCode) {
        case 401: return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        case 403: return 'الحساب غير مفعّل، يرجى التواصل مع الدعم';
        case 404: return 'البريد الإلكتروني غير مسجل';
        case 409: return 'البريد الإلكتروني مستخدم بالفعل';
        case 422: return 'البيانات المدخلة غير صحيحة';
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found': return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        case 'email-already-in-use': return 'البريد الإلكتروني مستخدم بالفعل';
        case 'weak-password': return 'كلمة المرور ضعيفة جداً، يجب أن تكون 6 أحرف على الأقل';
        case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة';
        case 'too-many-requests': return 'تم تجاوز عدد المحاولات، يرجى المحاولة لاحقاً';
        case 'requires-recent-login': return 'يرجى إعادة تسجيل الدخول لتغيير كلمة المرور';
        case 'network-request-failed': return 'تحقق من اتصالك بالإنترنت';
      }
    }
    if (e is Exception && e.toString().contains('تم إلغاء')) {
      return 'تم إلغاء تسجيل الدخول';
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }

  void loginAsGuest() {
    if (isClosed) return;
    emit(AuthGuest());
  }

  Future<void> deleteAccount() async {
    if (isClosed) return;
    emit(AuthLoading());
    try {
      await _repo.deleteAccount();
      if (isClosed) return;
      emit(AuthAccountDeleted());
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapError(e)));
    }
  }
}
