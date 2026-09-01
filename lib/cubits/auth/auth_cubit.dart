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
    emit(AuthLoading());
    try {
      final user = await _repo.login(email: email, password: password);
      emit(AuthSuccess(user));
    } catch (e) {
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
      emit(AuthSuccess(user));
    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout)) {
        emit(AuthSignUpTimeout());
      } else {
        emit(AuthError(_mapError(e)));
      }
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _repo.signInWithGoogle();
      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    emit(AuthLoading());
    try {
      await _repo.sendPasswordReset(email: email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  // token and email come from the password-reset deep link.
  // Deep-link wiring is pending; screens currently pass empty strings.
  Future<void> updatePassword({
    required String newPassword,
    required String token,
    required String email,
  }) async {
    emit(AuthLoading());
    try {
      await _repo.updatePassword(
        newPassword: newPassword,
        token: token,
        email: email,
      );
      emit(AuthPasswordUpdated());
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    emit(AuthInitial());
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await _repo.deleteAccount();
      emit(AuthAccountDeleted());
    } catch (e) {
      // TODO: BR-10/FR-24 — extract blocking booking ID from error response when backend enforces it.
      if (e is DioException) {
        final title = e.response?.data?['title'] as String?;
        if (title != null && title.isNotEmpty) {
          emit(AuthError(title));
          return;
        }
      }
      emit(AuthError('حدث خطأ أثناء حذف الحساب، يرجى المحاولة مجدداً'));
    }
  }

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      final user = await _repo.checkSession();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      emit(AuthInitial());
    }
  }

  String _mapError(Object e) {
    if (e is DioException) {
      // Backend error shape: { "icon": "error", "title": "...", "errors": {} }
      final title = e.response?.data?['title'] as String?;
      if (title != null && title.isNotEmpty) return title;
      switch (e.response?.statusCode) {
        case 401:
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        case 403:
          return 'الحساب غير مفعّل، يرجى التواصل مع الدعم';
        case 404:
          return 'البريد الإلكتروني غير مسجل';
        case 409:
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 422:
          return 'البيانات المدخلة غير صحيحة';
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
        case 'user-not-found':
          return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً، يجب أن تكون 6 أحرف على الأقل';
        case 'invalid-email':
          return 'صيغة البريد الإلكتروني غير صحيحة';
        case 'too-many-requests':
          return 'تم تجاوز عدد المحاولات، يرجى المحاولة لاحقاً';
        case 'requires-recent-login':
          return 'يرجى إعادة تسجيل الدخول لتغيير كلمة المرور';
        case 'network-request-failed':
          return 'تحقق من اتصالك بالإنترنت';
      }
    }
    if (e is Exception && e.toString().contains('تم إلغاء')) {
      return 'تم إلغاء تسجيل الدخول';
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
