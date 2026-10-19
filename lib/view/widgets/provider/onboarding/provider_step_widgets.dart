import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Shared pieces of the provider sign-up steps (بيانات الحساب → التوثيق →
// الاشتراك → التفعيل), so every step matches the same Figma frame.

const kProviderStepBackground = Color(0xFFFDF6F7);
const kProviderNoteFill = Color(0xFFF8EAED);
const kProviderCardBorder = Color(0xFFE6D3D8);

PreferredSizeWidget providerStepAppBar(
  BuildContext context,
  String title, {
  bool showBack = true,
}) {
  final primary = Theme.of(context).colorScheme.primary;
  return AppBar(
    backgroundColor: kProviderStepBackground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: false,
    title: Text(
      title,
      style: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    // The design puts the back arrow on the left, pointing right.
    actions: [
      if (showBack && Navigator.canPop(context))
        IconButton(
          tooltip: 'رجوع',
          icon: const Icon(Icons.arrow_forward, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
    ],
  );
}

/// "الخطوة ...: ..." with the progress bar under it.
class ProviderStepHeader extends StatelessWidget {
  final String step;
  final double progress;
  final String? subtitle;

  const ProviderStepHeader({
    super.key,
    required this.step,
    required this.progress,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          step,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: theme.colorScheme.primary,
            backgroundColor: const Color(0xFFE8E2E4),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class ProviderPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const ProviderPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// "لديك حساب بالفعل؟ تسجيل دخول" — signs out and opens the login screen.
class ProviderLoginLink extends StatelessWidget {
  const ProviderLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: InkWell(
        onTap: () {
          final auth = context.read<AuthCubit>();
          // Leave the provider screens first so their guard does not redirect.
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          );
          auth.logout();
        },
        child: Text.rich(
          TextSpan(
            text: 'لديك حساب بالفعل؟ ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              fontSize: 12,
            ),
            children: [
              TextSpan(
                text: 'تسجيل دخول',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dashed rounded border around image upload areas.
class DashedBorderPainter extends CustomPainter {
  final Color color;

  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) => old.color != color;
}
