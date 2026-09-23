import 'package:farah/core/constants/app_routes.dart';
import 'package:flutter/material.dart';

class ProviderSubscriptionSuccessScreen extends StatelessWidget {
  const ProviderSubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.check_circle, color: primary, size: 100),
              const SizedBox(height: 24),
              Text(
                'تهانينا تم تفعيل حسابك بنجاح!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'صار عندك حساب موثق على فرحتك.\nجاهز لتستقبل أول طلب حجز.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.providerHome,
                    (route) => false,
                  );
                },
                child: const Text('الصفحة الرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
