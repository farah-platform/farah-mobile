import 'package:dio/dio.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: رسالة خطأ إنشاء الحساب لازم تكون رسالة السيرفر الحقيقية، مش "حدث خطأ".
class _FailingAuthRepo implements AuthRepository {
  final Object error;
  _FailingAuthRepo(this.error);

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? userType,
    int? cityId,
  }) async => throw error;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<String> _signUpError(Object error) async {
  final cubit = AuthCubit(_FailingAuthRepo(error));
  await cubit.signUp(name: 'n', email: 'e', phone: 'p', password: 'x');
  final state = cubit.state;
  await cubit.close();
  return (state as AuthError).message;
}

void main() {
  test('sign up shows the server message', () async {
    expect(
      await _signUpError(Exception('هذا البريد الإلكتروني مستخدم بالفعل')),
      'هذا البريد الإلكتروني مستخدم بالفعل',
    );
  });

  test('no connection says so instead of a generic error', () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/register'),
      type: DioExceptionType.connectionError,
    );
    expect(await _signUpError(error), 'تحقق من اتصالك بالإنترنت');
  });

  test('raw English exceptions stay hidden', () async {
    expect(
      await _signUpError(Exception('No session token')),
      'حدث خطأ، يرجى المحاولة مجدداً',
    );
  });
}
