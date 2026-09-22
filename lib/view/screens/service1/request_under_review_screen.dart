import 'dart:math';
import 'package:flutter/material.dart';

class RequestUnderReviewScreen extends StatelessWidget {
  const RequestUnderReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: _BurstSpinner(size: 70)),
              const SizedBox(height: 24),
              Text(
                'طلبك قيد المراجعة',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'حسابك قيد المراجعة من قبل الادارة وسنقوم بإشعارك فور اعتماده لتتمكن من الانطلاق',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'الخطوات القادمة',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, height: 1),
                    const SizedBox(height: 16),
                    _buildStepItem(
                      theme: theme,
                      primary: primary,
                      icon: Icons.fact_check_outlined,
                      title: 'مراجعة البيانات والمستندات',
                      description:
                          'يقوم فريق الجودة بمراجعة الهوية والسجل التجاري لضمان الموثوقية.',
                    ),
                    const SizedBox(height: 20),
                    _buildStepItem(
                      theme: theme,
                      primary: primary,
                      icon: Icons.notifications_active_outlined,
                      title: 'تفعيل الحساب واستقبال الطلبات',
                      description:
                          'سنرسل لك رسالة نصية وبريداً إلكترونياً فور الموافقة على طلبك.',
                    ),
                    const SizedBox(height: 20),
                    _buildStepItem(
                      theme: theme,
                      primary: primary,
                      icon: Icons.storefront_outlined,
                      title: 'تجهيز معرض الصور',
                      description:
                          'بعد التفعيل، يمكنك إضافة خدماتك وتحديد أسعارك مباشرة.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black87,
                          ),
                          children: [
                            const TextSpan(
                              text: 'مراجعة الطلب تستغرق عادة أقل من ',
                            ),
                            TextSpan(
                              text: '24',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  ' ساعة، في حالة لديك اي استفسار يرجى التواصل مع ',
                            ),
                            TextSpan(
                              text: 'الدعم الفني',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.info_outline, size: 18, color: primary),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // TODO: لازم توديها للـ Home الرسمية للمستخدم (بديل الـ pushNamedAndRemoveUntil)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('العودة للرئيسية'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required ThemeData theme,
    required Color primary,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withOpacity(0.3)),
          ),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 6),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _BurstSpinner extends StatefulWidget {
  final double size;
  const _BurstSpinner({required this.size});

  @override
  State<_BurstSpinner> createState() => _BurstSpinnerState();
}

class _BurstSpinnerState extends State<_BurstSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BurstSpinnerPainter(
              progress: _controller.value,
              color: primary,
            ),
          );
        },
      ),
    );
  }
}

class _BurstSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;
  static const int lineCount = 8;

  _BurstSpinnerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.45;
    final lineLength = outerRadius * 0.45;

    for (int i = 0; i < lineCount; i++) {
      final angle = (2 * pi / lineCount) * i;

      double distance = (i / lineCount) - progress;
      distance = distance - distance.floorToDouble();
      final opacity = (1 - distance).clamp(0.15, 1.0);

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..strokeWidth = size.width * 0.045
        ..strokeCap = StrokeCap.round;

      final start = center + Offset(cos(angle), sin(angle)) * innerRadius;
      final end =
          center + Offset(cos(angle), sin(angle)) * (innerRadius + lineLength);

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
