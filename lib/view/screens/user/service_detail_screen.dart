import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/cubits/service_detail/service_detail_cubit.dart';
import 'package:farah/view/widgets/service_details/service_features_list_widget.dart';
import 'package:farah/view/widgets/service_details/booking_bottom_sheet_widget.dart';
import 'package:farah/view/widgets/service_details/service_bottom_action_bar_widget.dart';
import 'package:farah/view/widgets/service_details/service_detail_header_widget.dart';
import 'package:farah/view/widgets/service_details/service_detail_overview_widget.dart';
import 'package:farah/view/widgets/service_details/service_quick_info_widget.dart';
import 'package:farah/view/widgets/service_details/service_reviews_widget.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int? serviceId;
  final ServiceModel? service;

  const ServiceDetailsScreen({super.key, this.serviceId, this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.service?.isFavorited ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // 1. إذا تم تمرير الكائن مباشرة من الشاشة السابقة
    if (widget.service != null) {
      return _buildContent(context, widget.service!);
    }

    // 2. إذا تم الفتح عبر serviceId من الكيوبت والباك إند
    return BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
      builder: (context, state) {
        if (state is ServiceDetailLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: colors.primary),
            ),
          );
        }

        if (state is ServiceDetailLoaded) {
          return _buildContent(context, state.service);
        }

        if (state is ServiceDetailError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: colors.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: colors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (widget.serviceId != null) {
                          context.read<ServiceDetailCubit>().load(
                            widget.serviceId.toString(),
                          );
                        }
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ServiceModel service) {
    final theme = Theme.of(context);

    final allImages = <String>[];
    if (service.image != null && service.image!.isNotEmpty) {
      allImages.add(service.image!);
    }
    for (var img in service.images) {
      if (!allImages.contains(img)) allImages.add(img);
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              ServiceDetailHeaderWidget(
                images: allImages,
                isFavorited: _isFavorited,
                onBackTap: () => Navigator.pop(context),
                onFavoriteTap: () {
                  setState(() => _isFavorited = !_isFavorited);
                },
              ),
              Transform.translate(
                offset: const Offset(0, -25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ServiceDetailOverviewWidget(
                        title: service.title,
                        ratingAvg: service.ratingAvg,
                        reviewsCount: service.reviewsCount,
                        description: service.description,
                      ),
                      const SizedBox(height: 14),
                      ServiceQuickInfoWidget(
                        availableSlotsCount: service.bookingSlots.length,
                        price: service.price,
                        currency: service.currency,
                      ),
                      const SizedBox(height: 18),
                      ServiceFeaturesListWidget(features: service.features),
                      const SizedBox(height: 18),
                      ServiceReviewsWidget(
                        reviews: service.reviews,
                        onSeeAllTap: () {},
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ServiceBottomActionBarWidget(
          onBookNowTap: () {
            BookingBottomSheetWidget.show(context, service);
          },
          onWhatsAppTap: () {},
          onShareTap: () {},
        ),
      ),
    );
  }
}

