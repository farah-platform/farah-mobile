import 'package:farah/data/models/home/popular_service_model.dart';
import 'package:flutter/material.dart';

class HomeMostPopularWidget extends StatelessWidget {
  final List<PopularServiceModel> popularServices;

  const HomeMostPopularWidget({super.key, required this.popularServices});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (popularServices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'لا توجد خدمات الأكثر طلباً بعد',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(.5),
          ),
        ),
      );
    }

    return SizedBox(
      height: 230,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: popularServices.length,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final service = popularServices[index];

          return Container(
            width: 235,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colors.outline.withOpacity(.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 143,
                  width: double.infinity,
                  child: service.image != null && service.image!.isNotEmpty
                      ? Image.network(
                          service.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (service.provider != null)
                          Text(
                            service.provider!.name,
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
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              service.ratingAvg.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 8,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(${service.reviewsCount})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 7,
                                color: colors.onSurface.withOpacity(.4),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${service.price.toStringAsFixed(0)} ${service.currency}',
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

