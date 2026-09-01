import 'package:farah/cubits/profile_edit/profile_edit_cubit.dart';
import 'package:farah/cubits/change_password/change_password_cubit.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:farah/view/screens/auth/forgot_password.dart';
import 'package:farah/view/screens/auth/forgot_password_phone.dart';
import 'package:farah/view/screens/auth/login.dart';
import 'package:farah/view/screens/auth/new_password.dart';
import 'package:farah/view/screens/auth/sginup.dart';
import 'package:farah/view/screens/auth/splash.dart';
import 'package:farah/view/screens/auth/terms_and_conditions.dart';
import 'package:farah/view/screens/auth/verify_code.dart';
import 'package:farah/view/screens/provider/provider_home_screen.dart';
import 'package:farah/view/screens/service1/service_info_screen.dart';
import 'package:farah/view/screens/user/change_password_screen.dart';
import 'package:farah/view/screens/user/favorites_screen.dart';
import 'package:farah/view/screens/user/help_center_screen.dart';
import 'package:farah/view/screens/user/home_screen.dart';
import 'package:farah/view/screens/user/profile_edit_screen.dart';
import 'package:farah/view/screens/user/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String forgotPasswordPhone = '/forgot-password/phone';
  static const String verifyCode = '/verify-code';
  static const String newPassword = '/new-password';
  static const String terms = '/terms';
  static const String serviceInfo = '/service-info';
  static const String home = '/home';
  static const String search = '/search';
  static const String booking = '/booking';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String providerHome = '/provider/home';
  static const String providerOrders = '/provider/orders';
  static const String providerProfile = '/provider/profile';
  static const String notifications = '/notifications';
  static const String serviceDetail = '/service-detail';
  static const String settings = '/settings';
  static const String profileEdit = '/settings/profile-edit';
  static const String changePassword = '/settings/change-password';
  static const String helpCenter = '/settings/help';
  static const String favorites = '/settings/favorites';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignUpScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    forgotPasswordPhone: (_) => const ForgotPasswordPhoneScreen(),
    verifyCode: (_) => const VerifyCodeScreen(),
    newPassword: (_) => const NewPasswordScreen(),
    terms: (_) => const TermsAndConditionsScreen(),
    serviceInfo: (_) => const ServiceInfoScreen(),
    home: (_) => const UserHomeScreen(),
    providerHome: (_) => const ProviderHomeScreen(),
    settings: (_) => const SettingsScreen(),
    profileEdit: (ctx) => BlocProvider(
      create: (c) => ProfileEditCubit(c.read<ProfileRepository>()),
      child: const ProfileEditScreen(),
    ),
    changePassword: (ctx) => BlocProvider(
      create: (c) => ChangePasswordCubit(c.read<AuthRepository>()),
      child: const ChangePasswordScreen(),
    ),
    helpCenter: (_) => const HelpCenterScreen(),
    favorites: (_) => const FavoritesScreen(),
  };
}
