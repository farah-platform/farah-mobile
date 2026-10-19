class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://farah-backend-production.up.railway.app/api',
  );

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String resendVerification = '/resend-verification-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';

  // Profile / account
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String deleteAccount = '/account';

  // Discovery (no auth required)
  static const String categories = '/categories';
  static const String cities = '/cities';
  static const String home = '/home';
  static const String services = '/services';

  // Provider Services
  static const String providerServices = '/provider/services';
  static const String providerBookings = '/provider/bookings';
}
