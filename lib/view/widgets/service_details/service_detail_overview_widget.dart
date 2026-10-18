import 'package:flutter/material.dart';

class ServiceDetailOverviewWidget extends StatelessWidget {
  final String title;
  final double ratingAvg;
  final int reviewsCount;
  final String description;

  const ServiceDetailOverviewWidget({
    super.key,
    required this.title,
    required this.ratingAvg,
    required this.reviewsCount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والتقييم
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: colors.secondary),
                    const SizedBox(width: 3),
                    Text(
                      '${ratingAvg.toStringAsFixed(1)} ($reviewsCount تقييماً)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // نبذة عن الصالة / الخدمة
          Text(
            'نبذة عن الخدمة',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description.isNotEmpty ? description : 'لا يوجد وصف متوفر للخدمة.',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.6,
              color: colors.onSurface.withOpacity(0.7),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
