import 'package:farah/data/models/home/category_model.dart';
import 'package:farah/view/screens/user/services_screen.dart';
import 'package:farah/view/widgets/home/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:farah/data/models/home/service_category_model.dart';

class HomeCategoriesWidget extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final VoidCallback? onSeeAllTap;

  const HomeCategoriesWidget({
    super.key,
    required this.categories,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'لا توجد خدمات بعد',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(.5),
          ),
        ),
      );
    }

    return Column(
      children: [
        SectionHeaderWidget(title: 'الخدمات', onSeeAllTap: onSeeAllTap),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (context, index) {
              final service = categories[index];

              return SizedBox(
                width: 58,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServicesScreen(
                          categoryId: service.id,
                          categorySlug: service.slug,
                          categoryName: service.name,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary.withOpacity(.07),
                        ),
                        child: Icon(
                          _serviceIcon(index),
                          color: colors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        service.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8.5,
                          color: colors.onSurface.withOpacity(.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _serviceIcon(int index) {
    const icons = [
      Icons.church_outlined,
      Icons.local_florist_outlined,
      Icons.face_retouching_natural_outlined,
      Icons.camera_alt_outlined,
      Icons.storefront_outlined,
      Icons.music_note_outlined,
      Icons.restaurant_outlined,
    ];

    return icons[index % icons.length];
  }
}
