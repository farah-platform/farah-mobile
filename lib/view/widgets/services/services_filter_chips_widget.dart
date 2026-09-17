import 'package:flutter/material.dart';

class ServicesFilterChipsWidget extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const ServicesFilterChipsWidget({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filterOptions = [
      {'title': 'الكل', 'value': 'all'},
      {'title': 'الأقل سعرًا', 'value': 'price_low'},
      {'title': 'الأعلى سعرًا', 'value': 'price_high'},
      {'title': 'الأعلى تقييمًا', 'value': 'rating'},
      {'title': 'الأقرب لموقعك', 'value': 'nearest'},
    ];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          final option = filterOptions[index];
          final isSelected = selectedSort == option['value'];

          return _buildChip(
            context,
            title: option['title']!,
            isSelected: isSelected,
            onTap: () => onSortChanged(option['value']!),
          );
        },
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? colors.onPrimary : colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
