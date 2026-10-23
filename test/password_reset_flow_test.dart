import 'package:dio/dio.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:farah/view/screens/auth/forgot_password.dart';
import 'package:farah/view/screens/auth/new_password.dart';
import 'package:farah/view/screens/auth/verify_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: نسيت كلمة المرور: الإيميل ← رمز من 4 أرقام ← كلمة مرور جديدة، كلها مع السيرفر.
class _ResetRepo implements AuthRepository {
  final List<String> calls = [];
  String validCode = '4821';

  @override
  Future<void> sendPasswordReset({required String email}) async {
    calls.add('send:$email');
  }

  @override
  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    calls.add('verify:$email:$code');
    if (code != validCode) {
      final request = RequestOptions(path: '/verify-reset-code');
      throw DioException(
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 422,
          data: {'message': 'رمز التحقق غير صحيح أو منتهي. اطلب رمزًا جديدًا.'},
        ),
      );
    }
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    required String token,
    required String email,
  }) async {
    calls.add('reset:$email:$token:$newPassword');
    // Stay on this screen (the login screen it opens is tested elsewhere).
    final request = RequestOptions(path: '/reset-password');
    throw DioException(
      requestOptions: request,
      response: Response(
        requestOptions: request,
        statusCode: 422,
        data: {'message': 'تجربة: تم استلام كلمة المرور'},
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  final boxes = find.byType(TextField);
  for (var i = 0; i < 4; i++) {
    await tester.enterText(boxes.at(i), code[i]);
  }
  await tester.pump();
}

void main() {
  testWidgets('email, code and new password go to the server in order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _ResetRepo();
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthCubit(repo),
        child: const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ForgotPasswordScreen(),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, ' me@test.com ');
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['send:me@test.com']);
    expect(find.byType(VerifyCodeScreen), findsOneWidget);

    // A wrong code shows the server message and stays on the code screen.
    await _enterCode(tester, '0000');
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();
    expect(
      find.text('رمز التحقق غير صحيح أو منتهي. اطلب رمزًا جديدًا.'),
      findsOneWidget,
    );
    expect(find.byType(NewPasswordScreen), findsNothing);

    // Resend asks the server for a new code.
    await tester.tap(find.text('إعادة الإرسال'));
    await tester.pumpAndSettle();
    expect(repo.calls.last, 'send:me@test.com');

    await _enterCode(tester, '4821');
    await tester.tap(find.text('تأكيد'));
    await tester.pumpAndSettle();
    expect(repo.calls.last, 'verify:me@test.com:4821');
    expect(find.byType(NewPasswordScreen), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'new-password-1');
    await tester.enterText(fields.at(1), 'new-password-1');
    final submit = find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.byType(Text),
    );
    await tester.ensureVisible(submit.last);
    await tester.tap(submit.last);
    await tester.pumpAndSettle();
    expect(repo.calls.last, 'reset:me@test.com:4821:new-password-1');
    expect(find.text('تجربة: تم استلام كلمة المرور'), findsOneWidget);
  });
}
