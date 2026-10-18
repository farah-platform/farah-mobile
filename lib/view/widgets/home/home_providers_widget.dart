import 'package:farah/data/models/home/provider_model.dart';
import 'package:flutter/material.dart';

class HomeProvidersWidget extends StatelessWidget {
  final List<ProviderModel> providers;

  const HomeProvidersWidget({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (providers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'لا يوجد مزودو خدمات بعد',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(.5),
          ),
        ),
      );
    }

    return SizedBox(
      height: 148,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: providers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final provider = providers[index];

          return Container(
            width: 112,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outline.withOpacity(.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child:
                        provider.avatar != null && provider.avatar!.isNotEmpty
                        ? Image.network(
                            provider.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.person_outline,
                              color: colors.primary,
                              size: 30,
                            ),
                          )
                        : Icon(
                            Icons.person_outline,
                            color: colors.primary,
                            size: 30,
                          ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    provider.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    provider.specialty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 7.5,
                      color: colors.onSurface.withOpacity(.5),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: colors.secondary,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        provider.rating.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

