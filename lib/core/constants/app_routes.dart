import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/cubits/change_password/change_password_cubit.dart';
import 'package:farah/cubits/profile_edit/profile_edit_cubit.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_onboarding/provider_onboarding_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_cubit.dart';
import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';
import 'package:farah/cubits/service_detail/service_detail_cubit.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:farah/view/screens/auth/forgot_password.dart';
import 'package:farah/view/screens/auth/forgot_password_phone.dart';
import 'package:farah/view/screens/auth/login.dart';
import 'package:farah/view/screens/auth/new_password.dart';
import 'package:farah/view/screens/auth/sginup.dart';
import 'package:farah/view/screens/auth/splash.dart';
import 'package:farah/view/screens/auth/terms_and_conditions.dart';
import 'package:farah/view/screens/auth/verify_code.dart';
import 'package:farah/view/screens/provider/provider_activate_subscription_screen.dart';
import 'package:farah/view/screens/provider/provider_home_screen.dart';
import 'package:farah/view/screens/provider/provider_onboarding_screen.dart';
import 'package:farah/view/screens/provider/provider_subscription_plans_screen.dart';
import 'package:farah/view/screens/provider/provider_subscription_success_screen.dart';
import 'package:farah/view/screens/provider/provider_verification_screen.dart';
import 'package:farah/view/screens/provider/provider_router_screen.dart';
import 'package:farah/view/screens/provider/services/provider_add_package_screen.dart';
import 'package:farah/view/screens/provider/services/provider_add_service_screen.dart';
import 'package:farah/view/screens/provider/services/provider_edit_package_screen.dart';
import 'package:farah/view/screens/service1/service_info_screen.dart';
import 'package:farah/view/screens/user/change_password_screen.dart';
import 'package:farah/view/screens/user/favorites_screen.dart';
import 'package:farah/view/screens/user/help_center_screen.dart';
import 'package:farah/view/screens/user/home_screen.dart';
import 'package:farah/view/screens/user/profile_edit_screen.dart';
import 'package:farah/view/screens/user/service_detail_screen.dart';
import 'package:farah/view/screens/user/services_screen.dart';
import 'package:farah/cubits/service/service_cubit.dart';
import 'package:farah/view/screens/user/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/notification/notification_cubit.dart';
import '../../data/repositories/notification_repository.dart';
import '../../view/screens/notifications/notifications_screen.dart';
import '../../cubits/provider_payment_review/provider_payment_review_cubit.dart';
import '../../view/screens/provider/bookings/provider_payment_review_screen.dart';

// Dead route constants removed (screens not yet built):
//   search, booking, orders, profile,
//   providerOrders, providerProfile, notifications, serviceDetail

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
  static const String providerRouter = '/provider/router';
  static const String providerHome = '/provider/home';
  static const String settings = '/settings';
  static const String profileEdit = '/settings/profile-edit';
  static const String changePassword = '/settings/change-password';
  static const String helpCenter = '/settings/help';
  static const String favorites = '/settings/favorites';

  static const String serviceDetail = '/service-detail';
  static const String services = '/services';

  static const String providerOnboarding = '/provider/onboarding';
  static const String providerVerification = '/provider/verification';
  static const String providerSubscriptionPlans = '/provider/subscription-plans';
  static const String providerActivateSubscription = '/provider/activate-subscription';
  static const String providerSubscriptionSuccess = '/provider/subscription-success';
  static const String providerAddService = '/provider/add-service';
  static const String notifications = '/notifications';
  static const String providerPaymentReview = '/provider/payment-review';
  static const String providerEditService = '/provider/edit-service';
  static const String providerAddPackage = '/provider/add-package';
  static const String providerEditPackage = '/provider/edit-package';

  /// Returns the correct home route for the given server role string.
  static String homeForRole(String? role) {
    return role == 'provider' ? providerRouter : home;
  }

  /// Shows a dialog telling the guest they must log in, then optionally
  /// navigates to the login screen.
  static Future<void> showGuestLoginDialog(BuildContext context) async {
    final nav = Navigator.of(context);
    final goLogin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سجّل الدخول للمتابعة'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
    if (goLogin == true && context.mounted) {
      nav.pushNamedAndRemoveUntil(login, (_) => false);
    }
  }

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
    // Customer + guest routes — providers are redirected to providerHome.
    home: (_) => const _CustomerGuard(child: HomeScreen()),
    settings: (_) => const _CustomerGuard(child: SettingsScreen()),
    profileEdit: (ctx) => _CustomerGuard(
      child: BlocProvider(
        create: (c) => ProfileEditCubit(c.read<ProfileRepository>()),
        child: const ProfileEditScreen(),
      ),
    ),
    changePassword: (ctx) => _CustomerGuard(
      child: BlocProvider(
        create: (c) => ChangePasswordCubit(c.read<AuthRepository>()),
        child: const ChangePasswordScreen(),
      ),
    ),
    helpCenter: (_) => const _CustomerGuard(child: HelpCenterScreen()),
    favorites: (_) => const _CustomerGuard(child: FavoritesScreen()),
    serviceDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final ServiceModel? service = args is ServiceModel ? args : null;
      final int? serviceId = args is int
          ? args
          : (service != null ? int.tryParse(service.id.toString()) : null);

      return _CustomerGuard(
        child: BlocProvider(
          create: (c) => ServiceDetailCubit(c.read<ServiceRepository>()),
          child: ServiceDetailsScreen(serviceId: serviceId, service: service),
        ),
      );
    },
    services: (context) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return _CustomerGuard(
        child: BlocProvider(
          create: (c) => ServiceCubit(c.read<ServiceRepository>()),
          child: ServicesScreen(
            categoryId: args?['categoryId'] as int?,
            categorySlug: args?['categorySlug'] as String?,
            categoryName: args?['categoryName'] as String?,
          ),
        ),
      );
    },
    
    // Provider-only routes — customers/guests are redirected to home.
    providerRouter: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderVerificationCubit(c.read<ProviderRepository>()),
        child: const ProviderRouterScreen(),
      ),
    ),
    providerHome: (context) => _ProviderGuard(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => ProviderDashboardCubit(c.read<ProviderRepository>())),
          BlocProvider(create: (c) => ProviderServicesCubit(c.read<ProviderRepository>())..loadServices()),
        ],
        child: const ProviderHomeScreen(),
      ),
    ),
    providerOnboarding: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderOnboardingCubit(c.read<ProviderRepository>()),
        child: const ProviderOnboardingScreen(),
      ),
    ),
    providerVerification: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderVerificationCubit(c.read<ProviderRepository>()),
        child: const ProviderVerificationScreen(),
      ),
    ),
    providerSubscriptionPlans: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderSubscriptionCubit(c.read<ProviderRepository>()),
        child: const ProviderSubscriptionPlansScreen(),
      ),
    ),
    providerActivateSubscription: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      return _ProviderGuard(
        child: BlocProvider(
          create: (c) =>
              ProviderSubscriptionCubit(c.read<ProviderRepository>()),
          child: ProviderActivateSubscriptionScreen(
            plan: args is Map ? Map<String, dynamic>.from(args) : const {},
          ),
        ),
      );
    },
    providerSubscriptionSuccess: (context) => _ProviderGuard(
      child: ProviderSubscriptionSuccessScreen(
        pendingReview: ModalRoute.of(context)?.settings.arguments == true,
      ),
    ),
    providerEditService: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return _ProviderGuard(
        child: BlocProvider(
          create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
          child: ProviderAddServiceScreen(service: args),
        ),
      );
    },
    providerAddPackage: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
        child: const ProviderAddPackageScreen(),
      ),
    ),
    providerEditPackage: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return _ProviderGuard(
        child: BlocProvider(
          create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
          child: ProviderEditPackageScreen(packageData: args),
        ),
      );
    },
    notifications: (context) => BlocProvider(
      create: (c) => NotificationCubit(c.read<NotificationRepository>()),
      child: const NotificationsScreen(),
    ),
    providerPaymentReview: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return _ProviderGuard(
        child: BlocProvider(
          create: (c) => ProviderPaymentReviewCubit(c.read<ProviderRepository>()),
          child: ProviderPaymentReviewScreen(bookingId: args['bookingId'], paymentId: args['paymentId']),
        ),
      );
    },
    providerAddService: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
        child: const ProviderAddServiceScreen(),
      ),
    ),
  };
}

/// Redirects providers away from customer-only screens.
class _CustomerGuard extends StatelessWidget {
  final Widget child;
  const _CustomerGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccess && state.user.role == 'provider') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.providerHome,
                (_) => false,
              );
            }
          });
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}

/// Redirects non-providers away from provider-only screens.
class _ProviderGuard extends StatelessWidget {
  final Widget child;
  const _ProviderGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthSuccess || state.user.role != 'provider') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (_) => false,
              );
            }
          });
          return const SizedBox.shrink();
        }
        return child;
      },
    );
  }
}
