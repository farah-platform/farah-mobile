import 'package:flutter/material.dart';

class CustomSearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onTap;
  final bool readOnly;
  final String hintText;
  final bool showFilterButton;
  final TextInputAction textInputAction;

  const CustomSearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onTap,
    this.readOnly = false,
    this.hintText = 'ابحث عن خدمة...',
    this.showFilterButton = true,
    this.textInputAction = TextInputAction.search,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: textInputAction,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(.4),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.primary,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
        if (showFilterButton) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: colors.outline.withOpacity(.15)),
              ),
              child: Icon(Icons.tune_rounded, color: colors.primary, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}
