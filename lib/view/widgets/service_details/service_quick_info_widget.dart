import 'package:flutter/material.dart';

class ServiceQuickInfoWidget extends StatelessWidget {
  final int availableSlotsCount;
  final double price;
  final String currency;

  const ServiceQuickInfoWidget({
    super.key,
    required this.availableSlotsCount,
    required this.price,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        // كرت المواعيد
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: colors.primary,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  'المواعيد المتاحة',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$availableSlotsCount موعد',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.55),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // كرت السعر
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outline.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Icon(Icons.payments_outlined, color: colors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  'السعر',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${price.toStringAsFixed(0)} $currency',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
