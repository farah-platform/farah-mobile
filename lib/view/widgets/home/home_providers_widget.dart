import 'package:dio/dio.dart';
import 'package:farah/cubits/vendor/vendor_details_cubit.dart';
import 'package:farah/data/models/home/provider_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/view/screens/user/vendor_details_screen.dart';

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
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final provider = providers[index];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => VendorDetailsCubit(
                        context
                            .read<
                              ServiceRepository
                            >(), // <-- يقرأ الـ Repository الحقيقي من المشروع
                      ),
                      child: VendorDetailsScreen(
                        vendorId: provider.id,
                        initialVendorName: provider.name,
                        initialVendorSpecialty: provider.specialty,
                        initialVendorAvatar: provider.avatar,
                        initialVendorRating: provider.rating,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
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
                            provider.avatar != null &&
                                provider.avatar!.isNotEmpty
                            ? Image.network(
                                provider.avatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
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
              ),
            ),
          );
        },
      ),
    );
  }
}
