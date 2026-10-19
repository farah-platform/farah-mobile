import 'package:flutter/material.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;
  final bool showSeeAll;

  const SectionHeaderWidget({
    super.key,
    required this.title,
    this.onSeeAllTap,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          if (showSeeAll)
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                'عرض الكل',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
