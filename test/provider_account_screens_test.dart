import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/cubits/change_password/change_password_cubit.dart';
import 'package:farah/cubits/delete_account/delete_account_cubit.dart';
import 'package:farah/cubits/profile_edit/profile_edit_cubit.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/help_center/help_center_cubit.dart';
import 'package:farah/data/repositories/support_repository.dart';
import 'package:farah/cubits/provider_settings/provider_settings_cubit.dart';
import 'package:farah/cubits/provider_settings/provider_store_settings_cubit.dart';
import 'package:farah/cubits/provider_subscription/provider_current_subscription_cubit.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/view/screens/provider/settings/provider_change_password_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_current_subscription_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_delete_account_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_help_center_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_profile_edit_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_settings_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_store_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: اختبارات شاشات حساب المزود السبعة (الاشتراك الحالي، بيانات المتجر، الملف الشخصي،
// كلمة المرور، حذف الحساب، مركز المساعدة) بقيم من "الـ API" وليس من التصميم.

class _FakeProviderRepo implements ProviderRepository {
  final List<String> calls = [];
  Map<String, dynamic>? subscription = {
    'status': 'active',
    'is_active': true,
    'current_period_start': DateTime.now()
        .subtract(const Duration(days: 10))
        .toIso8601String(),
    'current_period_end': DateTime.now()
        .add(const Duration(days: 20, hours: 12))
        .toIso8601String(),
    'plan': {
      'name': 'api plan',
      'features': [
        {'name': 'api feature 1', 'included': true},
        {'name': 'api feature 2', 'included': true},
      ],
    },
  };
  Map<String, dynamic>? savedProfile;

  @override
  Future<Map<String, dynamic>?> getCurrentSubscription() async => subscription;

  @override
  Future<void> cancelSubscription() async {
    calls.add('cancel');
    subscription = {...subscription!, 'status': 'canceled', 'is_active': false};
  }

  @override
  Future<Map<String, dynamic>> getOnboardingData() async => {
    'profile': {
      'business_name': 'api store',
      'category': {'id': 7, 'name': 'api category'},
      'description': 'api description',
      'city': {'id': 3, 'name': 'api city'},
      'address': 'api address',
      'commercial_register_number': 'api register',
    },
  };

  @override
  Future<List<dynamic>> getCities() async => [
    {'id': 3, 'name': 'api city'},
  ];

  @override
  Future<List<dynamic>> getCategories() async => [
    {'id': 7, 'name': 'api category'},
    {'id': 8, 'name': 'api other category'},
  ];

  int dashboardLoads = 0;
  String businessName = 'api store';

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    dashboardLoads++;
    return {
      'provider': {'business_name': businessName, 'payout_account': {}},
      'subscription': {'is_active': true},
    };
  }

  @override
  Future<void> updateStoreProfile(
    Map<String, dynamic> data,
    dynamic coverImage, {
    dynamic logo,
  }) async {
    savedProfile = data;
  }

  @override
  Future<bool> getNotificationsEnabled() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSupportRepo implements SupportRepository {
  final List<String> audiences = [];
  Map<String, dynamic> contacts = {};

  @override
  Future<List<Map<String, dynamic>>> getFaqs({required String audience}) async {
    audiences.add(audience);
    return [
      {'id': 1, 'question': 'api question one', 'answer': 'api answer one'},
      {'id': 2, 'question': 'api question two', 'answer': 'api answer two'},
    ];
  }

  @override
  Future<Map<String, dynamic>> getSupportContacts() async => contacts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProfileRepo implements ProfileRepository {
  final List<String> calls = [];

  @override
  Future<UserModel> fetchUserProfile() async => const UserModel(
    uid: '1',
    name: 'api name',
    email: 'api@example.com',
    phone: 'api phone',
    region: 'api region',
  );

  @override
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? region,
    File? avatar,
  }) async {
    calls.add('$name|$phone|$region');
    return UserModel(uid: '1', name: name!, email: 'api@example.com');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthRepo implements AuthRepository {
  final List<String> calls = [];
  bool wrongCurrent = false;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (wrongCurrent) {
      final request = RequestOptions(path: '/change-password');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 403),
      );
    }
    calls.add('$currentPassword>$newPassword');
  }

  @override
  Future<void> deleteAccount({required String currentPassword}) async {
    if (wrongCurrent) {
      final request = RequestOptions(path: '/account');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 403),
      );
    }
    calls.add('delete:$currentPassword');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(412, 884);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(textDirection: TextDirection.rtl, child: child),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (_) => Scaffold(body: Text('route ${settings.name}')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('current subscription shows the plan and cancels it', (
    tester,
  ) async {
    final repo = _FakeProviderRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderCurrentSubscriptionCubit(repo),
        child: const ProviderCurrentSubscriptionScreen(),
      ),
    );

    expect(find.text('api plan'), findsOneWidget);
    expect(find.text('الاشتراك نشط'), findsOneWidget);
    expect(find.text('متبقي 21 يوم لإنهاء الاشتراك'), findsOneWidget);
    expect(find.text('api feature 1'), findsOneWidget);
    expect(find.text('api feature 2'), findsOneWidget);

    await tester.tap(find.text('الغاء الاشتراك'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الغاء الاشتراك').last);
    await tester.pumpAndSettle();
    expect(repo.calls, ['cancel']);
    expect(find.text('الاشتراك ملغي'), findsOneWidget);
    expect(find.text('الغاء الاشتراك'), findsNothing);
    ScaffoldMessenger.of(
      tester.element(find.text('ترقية الباقة')),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('ترقية الباقة'));
    await tester.pumpAndSettle();
    expect(find.text('route /provider/subscription-plans'), findsOneWidget);
  });

  testWidgets('no subscription offers to choose a plan', (tester) async {
    final repo = _FakeProviderRepo()..subscription = null;
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderCurrentSubscriptionCubit(repo),
        child: const ProviderCurrentSubscriptionScreen(),
      ),
    );
    expect(find.text('لا يوجد اشتراك حالياً'), findsOneWidget);
    expect(find.text('اختيار باقة'), findsOneWidget);
  });

  testWidgets('store data is prefilled and saves category and register', (
    tester,
  ) async {
    final repo = _FakeProviderRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProviderStoreSettingsCubit(repo),
        child: const ProviderStoreProfileScreen(),
      ),
    );

    expect(find.text('api store'), findsOneWidget);
    expect(find.text('api category'), findsOneWidget);
    expect(find.text('api description'), findsOneWidget);
    expect(find.text('api register'), findsOneWidget);
    // The design has no city field while the store already has one.
    expect(find.text('المدينة'), findsNothing);

    await tester.tap(find.text('api category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('api other category').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ التغيرات'));
    await tester.pumpAndSettle();

    expect(repo.savedProfile, {
      'business_name': 'api store',
      'category_id': '8',
      'description': 'api description',
      'city_id': '3',
      'address': 'api address',
      'commercial_register_number': 'api register',
    });
  });

  testWidgets('profile edit saves name, phone and address', (tester) async {
    final repo = _FakeProfileRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ProfileEditCubit(repo),
        child: const ProviderProfileEditScreen(),
      ),
    );

    expect(find.text('api name'), findsOneWidget);
    expect(find.text('api phone'), findsOneWidget);
    expect(find.text('api region'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'new address');
    await tester.tap(find.text('حفظ التغيرات'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['api name|api phone|new address']);
  });

  testWidgets('change password validates then saves', (tester) async {
    final repo = _FakeAuthRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => ChangePasswordCubit(repo),
        child: const ProviderChangePasswordScreen(),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'old-password');
    await tester.enterText(fields.at(1), 'new-password');
    await tester.enterText(fields.at(2), 'different');
    await tester.tap(find.text('حفظ التغيرات'));
    await tester.pumpAndSettle();
    expect(find.text('تأكيد كلمة المرور غير مطابق'), findsOneWidget);
    expect(repo.calls, isEmpty);

    repo.wrongCurrent = true;
    await tester.enterText(fields.at(2), 'new-password');
    await tester.tap(find.text('حفظ التغيرات'));
    await tester.pumpAndSettle();
    expect(find.text('كلمة المرور الحالية غير صحيحة'), findsOneWidget);

    repo.wrongCurrent = false;
    await tester.tap(find.text('حفظ التغيرات'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['old-password>new-password']);
  });

  // فرح: الحذف يرسل كلمة المرور، ويوضح الخطأ بدون ما يطلع المزود من التطبيق.
  testWidgets('delete account needs the password and shows server errors', (
    tester,
  ) async {
    final repo = _FakeAuthRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => DeleteAccountCubit(repo),
        child: const ProviderDeleteAccountScreen(),
      ),
    );
    expect(find.text('هل أنت متأكد ؟'), findsOneWidget);
    expect(find.text('إلغاء'), findsOneWidget);

    await tester.tap(find.text('تأكيد الحذف'));
    await tester.pumpAndSettle();
    expect(find.text('أدخل كلمة المرور الحالية'), findsOneWidget);
    expect(repo.calls, isEmpty);

    repo.wrongCurrent = true;
    await tester.enterText(find.byType(TextField), 'bad-password');
    await tester.tap(find.text('تأكيد الحذف'));
    await tester.pumpAndSettle();
    expect(find.text('كلمة المرور غير صحيحة'), findsOneWidget);
    expect(find.text('هل أنت متأكد ؟'), findsOneWidget);
  });

  testWidgets('help center lists API questions and filters them', (
    tester,
  ) async {
    final repo = _FakeSupportRepo();
    await _pump(
      tester,
      BlocProvider(
        create: (_) => HelpCenterCubit(repo, audience: 'provider'),
        child: const ProviderHelpCenterScreen(),
      ),
    );

    expect(find.text('api question one'), findsOneWidget);
    expect(find.text('api question two'), findsOneWidget);

    await tester.tap(find.text('api question one'));
    await tester.pumpAndSettle();
    expect(find.text('api answer one'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'two');
    await tester.pumpAndSettle();
    expect(find.text('api question one'), findsNothing);
    expect(find.text('api question two'), findsOneWidget);

    // No support phone or email set by the admin yet.
    await tester.tap(find.text('تواصل معنا'));
    await tester.pump();
    expect(find.text('هذه الميزة غير متاحة حالياً'), findsOneWidget);
    expect(repo.audiences, ['provider']);
  });

  testWidgets('settings open the current subscription and delete screens', (
    tester,
  ) async {
    final repo = _FakeProviderRepo();
    await _pump(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ProviderDashboardCubit(repo)..loadDashboard(),
          ),
          BlocProvider(create: (_) => ProviderSettingsCubit(repo)),
        ],
        child: const Scaffold(body: ProviderSettingsScreen()),
      ),
    );

    await tester.tap(find.text('الاشتراك  الحالي'));
    await tester.pumpAndSettle();
    expect(find.text('route /provider/subscription'), findsOneWidget);

    Navigator.of(
      tester.element(find.text('route /provider/subscription')),
    ).pop();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('حذف الحساب'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف الحساب'));
    await tester.pumpAndSettle();
    expect(find.text('route /provider/delete-account'), findsOneWidget);
  });

  // فرح: بعد حفظ بيانات المتجر ترجع الإعدادات بالاسم/الصورة الجديدة بدون إعادة فتح التطبيق.
  testWidgets('settings reload the store after saving store data', (
    tester,
  ) async {
    final repo = _FakeProviderRepo();
    tester.view.physicalSize = const Size(412, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ProviderDashboardCubit(repo)..loadDashboard(),
              ),
              BlocProvider(create: (_) => ProviderSettingsCubit(repo)),
            ],
            child: const Scaffold(body: ProviderSettingsScreen()),
          ),
        ),
        // Stands in for a settings screen that saved and popped with true.
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('saved'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('api store'), findsOneWidget);

    repo.businessName = 'api renamed store';
    await tester.scrollUntilVisible(
      find.text('بيانات المتجر'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('بيانات المتجر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('saved'));
    await tester.pumpAndSettle();

    expect(repo.dashboardLoads, 2);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('api renamed store'), findsOneWidget);
  });
}
