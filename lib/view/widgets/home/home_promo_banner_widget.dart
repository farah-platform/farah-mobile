import 'package:farah/data/models/home/banner_model.dart';
import 'package:flutter/material.dart';

class HomePromoBannerWidget extends StatelessWidget {
  final BannerModel banner;
  final VoidCallback? onTap;

  const HomePromoBannerWidget({super.key, required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 116,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.image != null && banner.image!.isNotEmpty)
              Image.network(
                banner.image!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(color: colors.primary.withOpacity(.08));
                },
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withOpacity(.5),
                    Colors.black.withOpacity(.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Badge
            Positioned(
              right: 12,
              top: 11,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.9),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  'عرض خاص',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Details
            Positioned(
              right: 12,
              bottom: 11,
              left: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${banner.price.toStringAsFixed(0)} ${banner.currency}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
