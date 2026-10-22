import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceBottomActionBarWidget extends StatelessWidget {
  final VoidCallback onBookNowTap;
  final String serviceTitle; // اسم الخدمة ليظهر في رسالة الواتساب والمشاركة
  final String? providerPhone; // رقم هاتف المزود (اختياري)

  const ServiceBottomActionBarWidget({
    super.key,
    required this.onBookNowTap,
    required this.serviceTitle,
    this.providerPhone,
    required Null Function() onWhatsAppTap,
    required Null Function() onShareTap,
  });

  // دالة فتح الواتساب
  Future<void> _openWhatsApp(BuildContext context) async {
    // إذا لم تقومي بتمرير رقم، سيستخدم هذا الرقم الافتراضي
    final String phone = providerPhone ?? "970599000000";
    final String message = "مرحباً، أود الاستفسار عن خدمة ( $serviceTitle )";

    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح تطبيق الواتساب، تأكد من تثبيته.'),
          ),
        );
      }
    }
  }

  // دالة المشاركة
  void _shareService() {
    final String shareText =
        "شاهد خدمة ( $serviceTitle ) الرائعة على منصة فرح!\n\nحمل التطبيق الآن واكتشف المزيد.";
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // زر المشاركة
            _buildIconButton(
              onTap: _shareService,
              icon: Icons.share_outlined,
              colors: colors,
            ),
            const SizedBox(width: 8),

            // زر الواتساب
            _buildIconButton(
              onTap: () => _openWhatsApp(context),
              icon: Icons.chat_bubble_outline_rounded,
              colors: colors,
            ),
            const SizedBox(width: 10),

            // زر المواصلة للحجز
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: onBookNowTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'المواصلة للحجز',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onTap,
    required IconData icon,
    required ColorScheme colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 19, color: colors.primary),
      ),
    );
  }
}
