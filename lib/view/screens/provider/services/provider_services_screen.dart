import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/provider_services/provider_services_cubit.dart';
import '../../../../cubits/auth/auth_cubit.dart';
import '../../../../cubits/provider_services/provider_services_state.dart';
import '../../../../core/constants/app_routes.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  
  @override
  void initState() {
    super.initState();
    context.read<ProviderServicesCubit>().loadServices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('خدماتي', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text('ماذا تريد أن تضيف؟', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: primary.withValues(alpha: 0.1), child: Icon(Icons.design_services, color: primary)),
                    title: const Text('إضافة خدمة جديدة'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Navigator.pushNamed(context, AppRoutes.providerAddService);
                      if (context.mounted) {
                        context.read<ProviderServicesCubit>().loadServices();
                      }
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(backgroundColor: primary.withValues(alpha: 0.1), child: Icon(Icons.card_giftcard, color: primary)),
                    title: const Text('إضافة باقة جديدة'),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Navigator.pushNamed(context, AppRoutes.providerAddPackage);
                      if (context.mounted) {
                        context.read<ProviderServicesCubit>().loadServices();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<ProviderServicesCubit, ProviderServicesState>(
        builder: (context, state) {
          bool isLoading = state is ProviderServicesLoading;
          List<dynamic> allServices = [];
          if (state is ProviderServicesLoaded) {
            allServices = state.services;
          }
          
          final services = allServices.where((s) => s['service_type'] != 'package').toList();
          final packages = allServices.where((s) => s['service_type'] == 'package').toList();
          
          return CustomScrollView(
            slivers: [
              _buildCoverAndProfile(theme, primary, context),
              if (isLoading)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())))
              else if (allServices.isEmpty)
                const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text('لا يوجد خدمات حتى الآن.'))))
              else ...[
                if (services.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text('الخدمات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildServiceCard(context, services[index], primary, isPackage: false),
                        childCount: services.length,
                      ),
                    ),
                  ),
                ],
                if (packages.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('الباقات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildServiceCard(context, packages[index], primary, isPackage: true),
                        childCount: packages.length,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          );
        }
      ),
    );
  }

  Widget _buildCoverAndProfile(ThemeData theme, Color primary, BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userName = authState is AuthSuccess ? authState.user.name : 'اسم المتجر';
    final userRegion = authState is AuthSuccess ? authState.user.region : 'فلسطين';

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 280,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Dynamic Cover Image Placeholder
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                // In reality, you'd fetch cover image URL from provider profile
              ),
              child: Center(child: Icon(Icons.store, size: 50, color: Colors.grey.shade500)),
            ),
            
            // Profile Card
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Column(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userRegion,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: primary),
                          const SizedBox(width: 4),
                          Text('متاح للحجز', style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('105', 'حجوزات مكتملة'),
                        _buildStatItem('خلال ساعة', 'سرعة الرد'),
                        _buildStatItem('98%', 'نسبة الالتزام'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Dynamic Avatar
            Positioned(
              top: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 5,
                    )
                  ]
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic item, Color primary, {required bool isPackage}) {
    final title = item['title'] ?? 'بدون عنوان';
    final price = item['price']?.toString() ?? '0';
    final currency = item['currency'] ?? '₪';
    final isActive = item['is_available'] == true || item['is_available'] == 1 || item['is_available'] == '1';
    final duration = item['execution_duration'] ?? 'يبدأ من 1 أيام';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? primary.withValues(alpha: 0.3) : Colors.grey.shade300, width: isActive ? 1.5 : 1),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image, color: Colors.grey), // Fallback image
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Text('السعر $price $currency', style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 12)),
              ],
            ),
          ),
          // Actions and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: isActive ? Colors.green : Colors.grey),
                    const SizedBox(width: 4),
                    Text(isActive ? 'مفعل' : 'غير مفعل', style: TextStyle(color: isActive ? Colors.green : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  if (isPackage) {
                    await Navigator.pushNamed(context, AppRoutes.providerEditPackage, arguments: item);
                  } else {
                    await Navigator.pushNamed(context, AppRoutes.providerEditService, arguments: item);
                  }
                  if (context.mounted) {
                    context.read<ProviderServicesCubit>().loadServices();
                  }
                },
                child: const Icon(Icons.edit, size: 20, color: Colors.redAccent),
              ),
            ],
          )
        ],
      ),
    );
  }
}
