import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/data/models/home/userhome_model.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0; // 0=home, 1=favorites, 2=orders
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

          body: IndexedStack(
            index: _currentIndex,
            children: [
              // Tab 0 — الرئيسية
              SafeArea(
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
              // Tab 1 — المفضلة (placeholder)
              const Center(child: Text('المفضلة')),
              // Tab 2 — طلباتي (placeholder)
              const Center(child: Text('طلباتي')),
            ],
          ),

          bottomNavigationBar: _buildBottomNavigation(context),
        ),
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

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

  // =========================================================
  // HOME CONTENT
  // =========================================================

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
              child: _buildHeader(context, state.home.user),
            ),

            const SizedBox(height: 14),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar(context),
            ),

            const SizedBox(height: 20),

            // Services
            _buildServices(context, state.home.categories),

            const SizedBox(height: 18),

            // Banner
            if (state.home.featuredPackages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPromoBanner(
                  context,
                  state.home.featuredPackages.first,
                ),
              ),

            if (state.home.featuredPackages.isNotEmpty)
              const SizedBox(height: 20),

            // Providers
            _buildSectionTitle(context, title: 'مزودين مقترحين لك'),

            const SizedBox(height: 8),

            _buildProviders(context, state.home.featuredProviders),

            const SizedBox(height: 20),

            // Packages
            _buildSectionTitle(context, title: 'باقات مميزة'),

            const SizedBox(height: 8),

            _buildPackages(context, state.home.featuredPackages),

            const SizedBox(height: 20),

            // Most popular
            _buildSectionTitle(context, title: 'الأكثر طلباً'),

            const SizedBox(height: 8),

            _buildMostPopular(context, state.home.mostPopular),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context, UserHomeModel? user) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name = user?.name.isNotEmpty == true ? user!.name : 'مستخدم';

    final location = user?.location.isNotEmpty == true ? user!.location : 'غزة';

    return SizedBox(
      height: 54,
      child: Row(
        children: [
          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withOpacity(.07),
            ),
            child: CircleAvatar(
              backgroundColor: colors.primary.withOpacity(.07),

              backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                  ? NetworkImage(user.avatar!)
                  : null,

              child: user?.avatar == null || user!.avatar!.isEmpty
                  ? Icon(
                      Icons.person_outline_rounded,
                      color: colors.primary,
                      size: 25,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلا، $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: colors.onSurface.withOpacity(.45),
                    ),

                    const SizedBox(width: 2),

                    Text(
                      location,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurface.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notification
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
              border: Border.all(color: colors.outline.withOpacity(.15)),
            ),
            child: Stack(
              children: [
                Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: colors.primary,
                      size: 21,
                    ),
                  ),
                ),

                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,

              style: Theme.of(context).textTheme.bodyMedium,

              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة...',

                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(.4),
                ),

                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.primary,
                  size: 20,
                ),

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.outline.withOpacity(.15)),
          ),
          child: Icon(Icons.tune_rounded, color: colors.primary, size: 20),
        ),
      ],
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _buildSectionTitle(BuildContext context, {required String title}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () {},
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
    );
  }

  // =========================================================
  // SERVICES
  // =========================================================

  Widget _buildServices(BuildContext context, List categories) {
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
        _buildSectionTitle(context, title: 'الخدمات'),

        const SizedBox(height: 10),

        SizedBox(
          height: 80,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            scrollDirection: Axis.horizontal,

            itemCount: categories.length,

            separatorBuilder: (_, _) => const SizedBox(width: 13),

            itemBuilder: (context, index) {
              final service = categories[index];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.services,
                    arguments: {
                      'categoryId': int.tryParse(service.id.toString()),
                      'categorySlug': service.slug,
                      'categoryName': service.name,
                    },
                  );
                },
                child: SizedBox(
                  width: 58,
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
              ));
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

  Widget _buildPromoBanner(BuildContext context, dynamic package) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
          if (package.image != null && package.image!.isNotEmpty)
            Image.network(
              package.image!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(color: colors.primary.withOpacity(.08));
              },
            ),

          // Overlay
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
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 11,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: themeText(
                    context,
                    color: Colors.white,
                    size: 13,
                    weight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${package.price.toStringAsFixed(0)} ${package.currency}',
                  style: themeText(
                    context,
                    color: Colors.white,
                    size: 11,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviders(BuildContext context, List providers) {
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

                    child: provider.avatar != null && provider.avatar!.isNotEmpty
                        ? Image.network(
                            provider.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) {
                              return Icon(
                                Icons.person_outline,
                                color: colors.primary,
                                size: 30,
                              );
                            },
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

  Widget _buildPackages(BuildContext context, List featuredPackages) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (featuredPackages.isEmpty) {
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

        itemCount: featuredPackages.length,

        separatorBuilder: (_, _) => const SizedBox(width: 10),

        itemBuilder: (context, index) {
          final package = featuredPackages[index];

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
                                errorBuilder: (_, _, _) {
                                  return Container(
                                    color: colors.primary.withOpacity(.08),
                                    child: Icon(
                                      Icons.image_outlined,
                                      color: colors.primary,
                                    ),
                                  );
                                },
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
                              package.discountBadge.isNotEmpty
                                  ? package.discountBadge
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

  Widget _buildMostPopular(BuildContext context, List popularServices) {
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

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.serviceDetail,
                arguments: int.tryParse(service.id.toString()),
              );
            },
            child: Container(
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
                          errorBuilder: (_, _, _) {
                            return Container(
                              color: colors.primary.withOpacity(.08),
                              child: Icon(
                                Icons.image_outlined,
                                color: colors.primary,
                              ),
                            );
                          },
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
          ));
        },
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outline.withOpacity(.12))),
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 62,

          child: Row(
            children: [
              _bottomItem(
                context,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'حسابي',
                active: false,
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),

              _bottomItem(
                context,
                icon: Icons.favorite_border_rounded,
                activeIcon: Icons.favorite_rounded,
                label: 'المفضلة',
                active: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),

              _bottomItem(
                context,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'طلباتي',
                active: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),

              _bottomItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'الرئيسية',
                active: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colors = theme.colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,

        splashColor: colors.primary.withOpacity(.05),

        highlightColor: Colors.transparent,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              active ? activeIcon : icon,

              size: 21,

              color: active
                  ? colors.primary
                  : colors.onSurface.withOpacity(.45),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 8.5,
                color: active
                    ? colors.primary
                    : colors.onSurface.withOpacity(.45),
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle themeText(
    BuildContext context, {
    Color? color,
    double? size,
    FontWeight? weight,
  }) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: color,
          fontSize: size,
          fontWeight: weight,
        ) ??
        TextStyle(color: color, fontSize: size, fontWeight: weight);
  }
}

