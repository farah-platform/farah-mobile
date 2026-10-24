import 'package:flutter/material.dart';

class HomeSearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const HomeSearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        readOnly: false, // تم تفعيل الكتابة
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search, // إظهار زر "بحث" في الكيبورد
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ابحث عن خدمة...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.primary, // لون الأيقونة
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: colors.outline.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: colors.primary),
          ),
        ),
      ),
    );
  }
}
