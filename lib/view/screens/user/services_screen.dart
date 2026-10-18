import 'package:farah/view/screens/user/service_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/cubits/service/service_cubit.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/view/widgets/bottom_nav_bar.dart';
import 'package:farah/view/widgets/common/custom_search_bar_widget.dart';
import 'package:farah/view/widgets/services/service_card_widget.dart';
import 'package:farah/view/widgets/services/services_filter_chips_widget.dart';
import 'package:farah/view/widgets/services/service_card_widget.dart';

class ServicesScreen extends StatefulWidget {
  final int? categoryId;
  final String? categorySlug;
  final String? categoryName;

  const ServicesScreen({
    super.key,
    this.categoryId,
    this.categorySlug,
    this.categoryName,
  });

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadServices() {
    context.read<ServiceCubit>().loadServices(
      categoryId: widget.categoryId,
      categorySlug: widget.categorySlug,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      sortBy: _selectedSort,
      perPage: 20,
      page: 1,
    );
  }

  void _search(String value) {
    context.read<ServiceCubit>().loadServices(
      categoryId: widget.categoryId,
      categorySlug: widget.categorySlug,
      search: value.trim().isEmpty ? null : value.trim(),
      sortBy: _selectedSort,
      perPage: 20,
      page: 1,
    );
  }

  void _changeSort(String sort) {
    setState(() {
      _selectedSort = sort;
    });
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text(
            widget.categoryName ?? 'الخدمات',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
          ),
        ),
        body: Column(
          children: [
            // شريط البحث الموحد
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBarWidget(
                controller: _searchController,
                hintText: widget.categoryName != null
                    ? 'ابحث ضمن ${widget.categoryName}...'
                    : 'ابحث ضمن الخدمات...',
                onSubmitted: _search,
                onFilterTap: () => _showFilterDialog(context),
              ),
            ),

            const SizedBox(height: 12),

            // أزرار الترتيب
            ServicesFilterChipsWidget(
              selectedSort: _selectedSort,
              onSortChanged: _changeSort,
            ),

            const SizedBox(height: 12),

            // قائمة الخدمات
            Expanded(
              child: BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ServiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ServiceError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is ServiceLoaded) {
                    if (state.services.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadServices();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          final service = state.services[index];

                          return ServiceCardWidget(
                            service: service,
                            onTap: () {
                              void _openServiceDetails(ServiceModel service) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ServiceDetailsScreen(service: service),
                                  ),
                                );
                              }
                            },
                            onFavoriteTap: () {
                              // المفضلة لاحقاً
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: FarahBottomNavBar(
          currentIndex: 3,
          onTap: (index) {
            _handleBottomNavigation(index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 65,
              color: colors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد خدمات',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نجد خدمات مطابقة لبحثك',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 60, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ترتيب الخدمات',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption(context, 'الأقل سعرًا', 'price_low'),
              _buildFilterOption(context, 'الأعلى سعرًا', 'price_high'),
              _buildFilterOption(context, 'الأعلى تقييمًا', 'rating'),
              _buildFilterOption(context, 'الأقرب لموقعك', 'nearest'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String title, String value) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        _changeSort(value);
      },
      title: Text(title),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedSort,
        onChanged: (value) {
          if (value == null) return;
          Navigator.pop(context);
          _changeSort(value);
        },
      ),
    );
  }

  void _openServiceDetails(ServiceModel service) {
    // سنربطها بشاشة تفاصيل الخدمة
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // حسابي
        break;
      case 1:
        // المفضلة
        break;
      case 2:
        // طلباتي
        break;
      case 3:
        Navigator.pop(context);
        break;
    }
  }
}
