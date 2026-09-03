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

    return PopScope(
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
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HomeError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 55,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(state.message, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<HomeCubit>().loadHome();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is HomeLoaded) {
                return _buildHomeContent(context, state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),

        bottomNavigationBar: _buildBottomNavigation(context),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<HomeCubit>().loadHome();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state.home.user),

            const SizedBox(height: 24),

            _buildSearchBar(context),

            const SizedBox(height: 28),
            _buildSectionTitle(context, title: 'الخدمات'),

            const SizedBox(height: 14),

            _buildServices(context, state.home.categories),

            const SizedBox(height: 30),

            _buildSectionTitle(context, title: 'باقات مميزة'),

            const SizedBox(height: 14),

            _buildPackages(context, state.home.featuredPackages),

            const SizedBox(height: 30),

            _buildSectionTitle(context, title: 'مزودو الخدمات'),

            const SizedBox(height: 14),

            _buildProviders(context, state.home.featuredProviders),

            const SizedBox(height: 30),

            _buildSectionTitle(context, title: 'الأكثر طلباً'),

            const SizedBox(height: 14),

            _buildMostPopular(context, state.home.mostPopular),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserHomeModel? user) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final name = user?.name.isNotEmpty == true ? user!.name : 'مستخدم';

    final location = user?.location.isNotEmpty == true ? user!.location : 'غزة';

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: colors.primary.withOpacity(0.1),
          backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
              ? NetworkImage(user.avatar!)
              : null,
          child: user?.avatar == null || user!.avatar!.isEmpty
              ? Icon(Icons.person_outline, color: colors.primary, size: 28)
              : null,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أهلا، $name',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(location, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),

        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notifications_none_rounded,
            color: colors.primary,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن خدمة...',
              prefixIcon: Icon(Icons.search_rounded, color: colors.primary),
            ),
          ),
        ),

        const SizedBox(width: 10),

        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.primary.withOpacity(0.2)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.tune_rounded, color: colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, {required String title}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        TextButton(
          onPressed: () {},
          child: Text(
            'عرض الكل',
            style: TextStyle(color: colors.primary, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildServices(BuildContext context, List categories) {
    final colors = Theme.of(context).colorScheme;

    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد خدمات بعد',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 14);
        },
        itemBuilder: (context, index) {
          final service = categories[index];

          return SizedBox(
            width: 85,
            child: Column(
              children: [
                Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primary.withOpacity(0.08),
                  ),
                  child: Icon(
                    Icons.miscellaneous_services_outlined,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPackages(BuildContext context, List featuredPackages) {
    final colors = Theme.of(context).colorScheme;

    if (featuredPackages.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد باقات مميزة بعد',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featuredPackages.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          final package = featuredPackages[index];

          return SizedBox(
            width: 285,
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 125,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child:
                              package.image != null && package.image!.isNotEmpty
                              ? Image.network(
                                  package.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: colors.primary.withOpacity(0.08),
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: colors.primary,
                                        size: 35,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: colors.primary.withOpacity(0.08),
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: colors.primary,
                                    size: 35,
                                  ),
                                ),
                        ),

                        // Discount badge
                        if (package.discountPercentage > 0)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                package.discountBadge.isNotEmpty
                                    ? package.discountBadge
                                    : '${package.discountPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 5),

                          if (package.provider != null)
                            Text(
                              package.provider!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),

                          const Spacer(),

                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 17,
                                color: colors.secondary,
                              ),

                              const SizedBox(width: 3),

                              Text(
                                package.ratingAvg.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                '(${package.reviewsCount})',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),

                              const Spacer(),

                              Text(
                                '${package.price.toStringAsFixed(0)} ${package.currency}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
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
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // PROVIDERS
  // =========================================================

  Widget _buildProviders(BuildContext context, List providers) {
    if (providers.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد مزودو خدمات بعد',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 215,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: providers.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          final provider = providers[index];

          return SizedBox(
            width: 155,
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: provider.image != null && provider.image!.isNotEmpty
                        ? Image.network(
                            provider.image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Center(
                                child: Icon(Icons.person_outline, size: 40),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Icons.person_outline, size: 40),
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          provider.specialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 17,
                              color: Theme.of(context).colorScheme.secondary,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              provider.rating.toString(),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMostPopular(BuildContext context, List popularServices) {
    final colors = Theme.of(context).colorScheme;
    if (popularServices.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد خدمات الأكثر طلباً بعد',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: popularServices.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          final service = popularServices[index];

          return SizedBox(
            width: 285,
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 135,
                    width: double.infinity,
                    child: service.image != null && service.image!.isNotEmpty
                        ? Image.network(
                            service.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: colors.primary.withOpacity(0.08),
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: colors.primary,
                                  size: 35,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: colors.primary.withOpacity(0.08),
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.primary,
                              size: 35,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          if (service.provider != null)
                            Text(
                              service.provider!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: colors.primary,
                              ),

                              const SizedBox(width: 3),

                              Expanded(
                                child: Text(
                                  service.location.isNotEmpty
                                      ? service.location
                                      : service.city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 17,
                                color: colors.secondary,
                              ),

                              const SizedBox(width: 3),

                              Text(
                                service.ratingAvg.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),

                              const SizedBox(width: 4),

                              Text(
                                '(${service.reviewsCount})',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),

                              const Spacer(),

                              Text(
                                '${service.price.toStringAsFixed(0)} ${service.currency}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      currentIndex: 3,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: colors.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) {},
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'حسابي',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: 'المفضلة',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'طلباتي',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
      ],
    );
  }
}
