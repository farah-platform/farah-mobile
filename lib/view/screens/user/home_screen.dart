import 'package:farah/cubits/home/home_cubit.dart';
import 'package:farah/view/widgets/bottom_nav_bar.dart';
import 'package:farah/view/widgets/home/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/view/widgets/home/home_header_widget.dart';
import 'package:farah/view/widgets/common/custom_search_bar_widget.dart';
import 'package:farah/view/widgets/home/home_categories_widget.dart';
import 'package:farah/view/widgets/home/home_promo_banner_widget.dart';
import 'package:farah/view/widgets/home/home_providers_widget.dart';
import 'package:farah/view/widgets/home/home_packages_widget.dart';
import 'package:farah/view/widgets/home/home_most_popular_widget.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;

          final now = DateTime.now();

          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
            _lastBackPressed = now;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اضغط مرة أخرى للخروج'),
                duration: Duration(seconds: 2),
              ),
            );

            return;
          }

          await SystemNavigator.pop();
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,

          body: SafeArea(
            bottom: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  );
                }

                if (state is HomeError) {
                  return _buildError(context, state.message);
                }

                if (state is HomeLoaded) {
                  return _buildHomeContent(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          bottomNavigationBar: FarahBottomNavBar(
            currentIndex: 3,
            onTap: (index) {
              if (index == 0) {
                // حسابي
              }

              if (index == 1) {
                // المفضلة
              }

              if (index == 2) {
                // طلباتي
              }

              if (index == 3) {
                // الرئيسيةا
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 55, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  context.read<HomeCubit>().loadHome();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        await context.read<HomeCubit>().loadHome();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HomeHeaderWidget(
                user: state.home.user,
                onNotificationTap: () {
                  // كود الانتقال لشاشة الإشعارات
                },
              ),
            ),

            const SizedBox(height: 14),

            // Search
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBarWidget(
                readOnly: true,
                onTap: () {
                  // فتح شاشة البحث المخصصة لاحقاً
                },
                onFilterTap: () {
                  // فتح الفلتر لاحقاً
                },
              ),
            ),
            const SizedBox(height: 20),

            // Services
            HomeCategoriesWidget(
              categories: state.home.categories,
              onSeeAllTap: () {},
            ),
            const SizedBox(height: 18),

            // Banner
            if (state.home.banners.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: HomePromoBannerWidget(banner: state.home.banners.first),
              ),
            if (state.home.banners.isNotEmpty) const SizedBox(height: 20),

            // Providers
            SectionHeaderWidget(title: 'مزودين مقترحين لك', onSeeAllTap: () {}),
            const SizedBox(height: 8),
            HomeProvidersWidget(providers: state.home.suggestedProviders),

            const SizedBox(height: 20),

            // Packages
            SectionHeaderWidget(title: 'باقات مميزة', onSeeAllTap: () {}),
            const SizedBox(height: 8),
            HomePackagesWidget(packages: state.home.featuredPackages),

            const SizedBox(height: 20),

            // Most Popular
            SectionHeaderWidget(title: 'الأكثر طلباً', onSeeAllTap: () {}),
            const SizedBox(height: 8),
            HomeMostPopularWidget(popularServices: state.home.mostPopular),
          ],
        ),
      ),
    );
  }
}
