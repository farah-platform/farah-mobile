import 'package:farah/data/models/home/package_model.dart';
import 'package:flutter/material.dart';

class HomePackagesWidget extends StatelessWidget {
  final List<PackageModel> packages;

  const HomePackagesWidget({super.key, required this.packages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (packages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'لا توجد باقات مميزة بعد',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(.5),
          ),
        ),
      );
    }

    return SizedBox(
      height: 188,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final package = packages[index];

          return Container(
            width: 170,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outline.withOpacity(.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 106,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child:
                            package.image != null && package.image!.isNotEmpty
                            ? Image.network(
                                package.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: colors.primary.withOpacity(.08),
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: colors.primary,
                                  ),
                                ),
                              )
                            : Container(
                                color: colors.primary.withOpacity(.08),
                                child: Icon(
                                  Icons.image_outlined,
                                  color: colors.primary,
                                ),
                              ),
                      ),
                      if (package.discountPercentage > 0)
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              (package.discountBadge != null &&
                                      package.discountBadge!.isNotEmpty)
                                  ? package.discountBadge!
                                  : '${package.discountPercentage.toStringAsFixed(0)}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (package.provider != null)
                          Text(
                            package.provider!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 7.5,
                              color: colors.onSurface.withOpacity(.5),
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: colors.secondary,
                              size: 13,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              package.ratingAvg.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 8,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${package.price.toStringAsFixed(0)} ${package.currency}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
