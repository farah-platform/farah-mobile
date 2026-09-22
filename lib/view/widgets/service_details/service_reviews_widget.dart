import 'package:farah/data/models/service_model.dart';
import 'package:flutter/material.dart';

class ServiceReviewsWidget extends StatelessWidget {
  final List<ServiceReviewModel> reviews;
  final VoidCallback? onSeeAllTap;

  const ServiceReviewsWidget({
    super.key,
    required this.reviews,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'آراء العملاء',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: colors.onSurface,
              ),
            ),
            const Spacer(),
            if (reviews.isNotEmpty)
              GestureDetector(
                onTap: onSeeAllTap,
                child: Text(
                  'عرض الكل',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontSize: 9,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'لا توجد تقييمات بعد لهذه الخدمة',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.5),
                fontSize: 9.5,
              ),
            ),
          )
        else
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final review = reviews[index];

                return Container(
                  width: 175,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: colors.outline.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  review.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex < review.rating.round()
                                          ? Icons.star_rounded
                                          : Icons.star_border_rounded,
                                      size: 10,
                                      color: colors.secondary,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: colors.primary.withOpacity(0.1),
                            child: Text(
                              review.userName.isNotEmpty
                                  ? review.userName[0].toUpperCase()
                                  : 'U',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        review.comment,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 8,
                          color: colors.onSurface.withOpacity(0.7),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
