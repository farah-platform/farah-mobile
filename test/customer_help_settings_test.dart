import 'package:farah/cubits/help_center/help_center_cubit.dart';
import 'package:farah/cubits/settings/settings_cubit.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/support_repository.dart';
import 'package:farah/view/screens/user/help_center_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: مركز مساعدة العميل من السيرفر (بدون رقم واتساب ثابت)، وتفضيل الإشعارات محفوظ بالسيرفر.

class _Support implements SupportRepository {
  final List<String> calls = [];
  bool enabled = true;
  bool failSave = false;
  Map<String, dynamic> contacts = {};

  @override
  Future<List<Map<String, dynamic>>> getFaqs({required String audience}) async {
    calls.add('faqs:$audience');
    return [
      {'id': 1, 'question': 'api customer question', 'answer': 'api answer'},
    ];
  }

  @override
  Future<Map<String, dynamic>> getSupportContacts() async => contacts;

  @override
  Future<bool> getNotificationsEnabled() async => enabled;

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    if (failSave) throw Exception('offline');
    calls.add('notifications:$value');
    enabled = value;
  }
}

class _Profile implements ProfileRepository {
  @override
  Future<UserModel> fetchUserProfile() async =>
      const UserModel(uid: '1', name: 'api name', email: 'api@test.com');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('customer help center shows customer questions from the API', (
    tester,
  ) async {
    final support = _Support();
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocProvider(
            create: (_) => HelpCenterCubit(support, audience: 'customer'),
            child: const HelpCenterScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(support.calls, ['faqs:customer']);
    expect(find.text('api customer question'), findsOneWidget);

    // No support phone/email from the admin: no hardcoded number is opened.
    await tester.tap(find.text('تواصل معنا'));
    await tester.pump();
    expect(find.text('هذه الميزة غير متاحة حالياً'), findsOneWidget);
  });

  test(
    'notifications preference is read from and saved to the server',
    () async {
      final support = _Support()..enabled = false;
      final cubit = SettingsCubit(_Profile(), support);
      await cubit.load();
      expect((cubit.state as SettingsLoaded).notificationsEnabled, isFalse);

      await cubit.toggleNotifications(true);
      expect(support.calls, ['notifications:true']);
      expect((cubit.state as SettingsLoaded).notificationsEnabled, isTrue);

      // A failed save puts the switch back.
      support.failSave = true;
      await cubit.toggleNotifications(false);
      expect((cubit.state as SettingsLoaded).notificationsEnabled, isTrue);
      await cubit.close();
    },
  );
}
