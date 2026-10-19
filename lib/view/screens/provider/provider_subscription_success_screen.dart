import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';

class ProviderSubscriptionSuccessScreen extends StatelessWidget {
  /// True after a paid plan's transfer was sent: it still waits for the admin.
  final bool pendingReview;

  const ProviderSubscriptionSuccessScreen({
    super.key,
    this.pendingReview = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    pendingReview ? Icons.hourglass_top_rounded : Icons.check,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                pendingReview
                    ? 'تم إرسال إشعار التحويل!'
                    : 'تهانينا تم تفعيل حسابك بنجاح!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pendingReview
                    ? 'سيتم تفعيل اشتراكك بعد مراجعة الإدارة للإشعار،\nوسيصلك إشعار فور التفعيل.'
                    : 'صار عندك حساب موثّق على فرحتنا،\nجاهز تستقبل أول طلب حجز',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              ProviderPrimaryButton(
                label: 'الصفحة الرئيسية',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.providerHome,
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
