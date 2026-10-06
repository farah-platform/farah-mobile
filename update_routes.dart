import 'dart:io';

void main() {
  final file = File('lib/core/constants/app_routes.dart');
  var content = file.readAsStringSync();

  if (!content.contains('static const String notifications =')) {
    content = content.replaceFirst(
      'static const String providerAddService = \'/provider/add-service\';',
      'static const String providerAddService = \'/provider/add-service\';\n  static const String notifications = \'/notifications\';\n  static const String providerPaymentReview = \'/provider/payment-review\';'
    );
  }

  if (!content.contains('notifications: (context)')) {
    content = content.replaceFirst(
      'providerAddService: (context) => _ProviderGuard(',
      '''notifications: (context) => BlocProvider(
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
    providerAddService: (context) => _ProviderGuard('''
    );
    
    // Add imports
    content = content.replaceFirst(
      'import \'package:flutter_bloc/flutter_bloc.dart\';',
      'import \'package:flutter_bloc/flutter_bloc.dart\';\nimport \'../../cubits/notification/notification_cubit.dart\';\nimport \'../../data/repositories/notification_repository.dart\';\nimport \'../../view/screens/notifications/notifications_screen.dart\';\nimport \'../../cubits/provider_payment_review/provider_payment_review_cubit.dart\';\nimport \'../../view/screens/provider/bookings/provider_payment_review_screen.dart\';'
    );
  }

  file.writeAsStringSync(content);
}
