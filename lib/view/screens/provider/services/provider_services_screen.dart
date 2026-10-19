import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_state.dart';
import 'package:farah/data/models/provider/provider_service_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "خدماتي": the store header with real stats, then services and packages.
class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  static const _coverHeight = 270.0;

  @override
  void initState() {
    super.initState();
    context.read<ProviderServicesCubit>().loadServices();
  }

  Future<void> _edit(ProviderServiceModel service) async {
    await Navigator.pushNamed(
      context,
      service.isPackage
          ? AppRoutes.providerEditPackage
          : AppRoutes.providerEditService,
      arguments: service.raw,
    );
    if (mounted) context.read<ProviderServicesCubit>().loadServices();
  }

  Future<void> _activate(ProviderServiceModel service) async {
    await context.read<ProviderServicesCubit>().toggleVisibility(
      service.id,
      true,
    );
    if (mounted) context.read<ProviderDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<ProviderDashboardCubit>().state;
    final data = dashboard is ProviderDashboardLoaded
        ? dashboard.data
        : const <String, dynamic>{};

    return BlocConsumer<ProviderServicesCubit, ProviderServicesState>(
      listener: (context, state) {
        if (state is ProviderServicesError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final items = state is ProviderServicesLoaded
            ? state.services
                  .whereType<Map>()
                  .map(
                    (s) => ProviderServiceModel.fromJson(
                      Map<String, dynamic>.from(s),
                    ),
                  )
                  .toList()
            : <ProviderServiceModel>[];
        final services = items.where((s) => !s.isPackage).toList();
        final packages = items.where((s) => s.isPackage).toList();

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProviderDashboardCubit>().loadDashboard();
            await context.read<ProviderServicesCubit>().loadServices();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(context, data),
              if (state is ProviderServicesLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'لم تضف أي خدمة بعد',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                )
              else ...[
                if (services.isNotEmpty) ..._section('الخدمات', services),
                if (packages.isNotEmpty) ..._section('الباقات', packages),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _section(String title, List<ProviderServiceModel> items) {
    final primary = Theme.of(context).colorScheme.primary;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
        child: Text(
          title,
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      for (final item in items) _ServiceCard(
        service: item,
        onEdit: () => _edit(item),
        onActivate: () => _activate(item),
      ),
    ];
  }

  Widget _header(BuildContext context, Map<String, dynamic> data) {
    final primary = Theme.of(context).colorScheme.primary;
    final provider = (data['provider'] as Map?) ?? const {};
    final stats = (data['store_stats'] as Map?) ?? const {};
    final cover = provider['cover_image']?.toString();
    final avatar = provider['avatar']?.toString();

    return Stack(
      children: [
        SizedBox(
          height: _coverHeight,
          width: double.infinity,
          child: cover != null && cover.isNotEmpty
              ? Image.network(
                  cover,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _coverFallback(primary),
                )
              : _coverFallback(primary),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, _coverHeight - 95, 28, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider['business_name']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (provider['category'] as Map?)?['name']?.toString() ??
                          '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    if (provider['is_bookable'] == true) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 7, color: primary),
                            const SizedBox(width: 6),
                            Text(
                              'متاح للحجز',
                              style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _stat(
                            'الحجوزات المكتملة',
                            '${stats['completed_bookings'] ?? 0}',
                            primary,
                          ),
                          const VerticalDivider(color: Color(0xFFDDD5D8)),
                          _stat(
                            'سرعة الرد',
                            _responseLabel(stats['avg_response_minutes']),
                            primary,
                          ),
                          const VerticalDivider(color: Color(0xFFDDD5D8)),
                          _stat(
                            'نسبة الالتزام',
                            stats['commitment_rate'] == null
                                ? '—'
                                : '${stats['commitment_rate']}%',
                            primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                top: -28,
                end: 16,
                child: CircleAvatar(
                  radius: 29,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: primary.withValues(alpha: 0.15),
                    backgroundImage: avatar != null && avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar == null || avatar.isEmpty
                        ? Icon(Icons.storefront_outlined, color: primary)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _coverFallback(Color primary) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color primary) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Average answer time from the API, in words.
  static String _responseLabel(dynamic minutes) {
    final value = (minutes as num?)?.toInt();
    if (value == null) return '—';
    if (value < 60) return 'خلال ${value < 1 ? 1 : value} دقيقة';
    if (value < 24 * 60) return 'خلال ${(value / 60).ceil()} ساعة';
    return 'خلال ${(value / (24 * 60)).ceil()} يوم';
  }
}

class _ServiceCard extends StatelessWidget {
  final ProviderServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onActivate;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onActivate,
  });

  static const _green = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final published = service.isPublished;

    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 28, 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDED)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: service.coverImage != null
                  ? Image.network(
                      service.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imageFallback(),
                    )
                  : _imageFallback(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _statusChip(primary),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'السعر: ${service.priceLabel}',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const Divider(height: 16, color: Color(0xFFEDEDED)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        published
                            ? (service.executionDuration ?? '')
                            : 'يمكن تفعيلها لإظهارها في البحث',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (published)
                      IconButton(
                        tooltip: 'تعديل',
                        onPressed: onEdit,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        icon: Icon(Icons.edit, color: primary, size: 18),
                      )
                    else
                      InkWell(
                        onTap: onActivate,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF8F0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _green.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: _green,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'تفعيل',
                                style: TextStyle(color: _green, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(Color primary) {
    final published = service.isPublished;
    final label = published ? 'نشط' : (service.isDraft ? 'مسودة' : 'موقوفة');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: published ? const Color(0xFFEFF8F0) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(20),
        border: published
            ? Border.all(color: _green.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: published ? _green.withValues(alpha: 0.5) : primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: published ? _green.withValues(alpha: 0.7) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFEFE7EA),
    child: const Icon(Icons.image_outlined, color: Colors.black26),
  );
}
