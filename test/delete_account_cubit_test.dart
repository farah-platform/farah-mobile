import 'package:dio/dio.dart';
import 'package:farah/cubits/delete_account/delete_account_cubit.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: حذف الحساب يرسل كلمة المرور ويعرض رسالة السيرفر (مثل الحجوزات القائمة).
class _Repo implements AuthRepository {
  Object? error;
  String? sentPassword;

  @override
  Future<void> deleteAccount({required String currentPassword}) async {
    sentPassword = currentPassword;
    if (error != null) throw error!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DioException _http(int status, [Map<String, dynamic>? data]) {
  final request = RequestOptions(path: '/account');
  return DioException(
    requestOptions: request,
    response: Response(requestOptions: request, statusCode: status, data: data),
  );
}

void main() {
  test('sends the password and reports success', () async {
    final repo = _Repo();
    final cubit = DeleteAccountCubit(repo);
    await cubit.delete('secret123');
    expect(repo.sentPassword, 'secret123');
    expect(cubit.state.deleted, isTrue);
  });

  test('shows the server reason for active bookings', () async {
    final repo = _Repo()
      ..error = _http(409, {
        'message': 'لا يمكن حذف الحساب لوجود حجوزات قائمة.',
      });
    final cubit = DeleteAccountCubit(repo);
    await cubit.delete('secret123');
    expect(cubit.state.deleted, isFalse);
    expect(cubit.state.error, 'لا يمكن حذف الحساب لوجود حجوزات قائمة.');
  });

  test('wrong password and no connection read clearly', () async {
    final repo = _Repo()..error = _http(403);
    final cubit = DeleteAccountCubit(repo);
    await cubit.delete('bad');
    expect(cubit.state.error, 'كلمة المرور غير صحيحة');

    repo.error = DioException(requestOptions: RequestOptions(path: '/account'));
    await cubit.delete('bad');
    expect(cubit.state.error, 'تحقق من اتصالك بالإنترنت');
  });
}
