import 'package:farah/core/utils/arabic_date.dart';
import 'package:farah/cubits/provider_settings/provider_reviews_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "تقييماتي": what customers wrote about the provider's services.
class ProviderReviewsScreen extends StatefulWidget {
  const ProviderReviewsScreen({super.key});

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderReviewsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final gold = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'تقييماتي'),
      body: BlocBuilder<ProviderReviewsCubit, ProviderReviewsState>(
        builder: (context, state) {
          if (state is ProviderReviewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProviderReviewsError) {
            return Center(
              child: TextButton(
                onPressed: () => context.read<ProviderReviewsCubit>().load(),
                child: Text('${state.message} - إعادة المحاولة'),
              ),
            );
          }
          final reviews = (state as ProviderReviewsLoaded).reviews;
          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                'ستظهر هنا تقييمات عملائك',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            children: [
              for (final r in reviews)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE3DADD)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              (r['customer'] as Map?)?['name']?.toString() ??
                                  '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          for (var i = 1; i <= 5; i++)
                            Icon(
                              i <= ((r['rating'] as num?) ?? 0)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 18,
                              color: gold,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (r['service'] as Map?)?['title']?.toString() ?? '',
                        style: TextStyle(color: primary, fontSize: 12),
                      ),
                      if ((r['comment']?.toString() ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          r['comment'].toString(),
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        DateTime.tryParse(r['created_at']?.toString() ?? '') !=
                                null
                            ? formatArabicDate(
                                DateTime.parse(r['created_at']).toLocal(),
                              )
                            : '',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
