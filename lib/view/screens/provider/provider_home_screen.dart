import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:farah/cubits/provider_orders/provider_orders_cubit.dart';
import 'package:farah/cubits/provider_services/provider_services_cubit.dart';
import 'package:farah/view/screens/provider/orders/provider_orders_screen.dart';
import 'package:farah/view/screens/provider/settings/provider_settings_screen.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/provider/home/provider_home_header_widget.dart';
import '../../widgets/provider/home/provider_home_latest_orders_widget.dart';
import '../../widgets/provider/home/provider_home_quick_management_widget.dart';
import '../../widgets/provider/home/provider_home_subscription_card_widget.dart';
import 'services/provider_services_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  static const _ordersTab = 1;
  static const _servicesTab = 2;

  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    context.read<ProviderDashboardCubit>().loadDashboard();
  }

  Future<void> _openAddService() async {
    await Navigator.pushNamed(context, AppRoutes.providerAddService);
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    context.read<ProviderDashboardCubit>().loadDashboard();
    context.read<ProviderServicesCubit>().loadServices();
  }

  Future<void> _openOrder(int id) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.providerOrderDetails,
      arguments: id,
    );
    if (changed == true) {
      _refresh();
      if (mounted) context.read<ProviderOrdersCubit>().refresh();
    }
  }

  // The services card is where providers add services and packages.
  void _showServicesActions() {
    final primary = Theme.of(context).colorScheme.primary;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.add_business_outlined, color: primary),
              title: const Text('إضافة خدمة جديدة'),
              onTap: () {
                Navigator.pop(sheet);
                _openAddService();
              },
            ),
            ListTile(
              leading: Icon(Icons.card_giftcard_outlined, color: primary),
              title: const Text('إضافة باقة جديدة'),
              onTap: () async {
                Navigator.pop(sheet);
                await Navigator.pushNamed(
                  context,
                  AppRoutes.providerAddPackage,
                );
                _refresh();
              },
            ),
            ListTile(
              leading: Icon(Icons.storefront_outlined, color: primary),
              title: const Text('عرض خدماتي'),
              onTap: () {
                Navigator.pop(sheet);
                setState(() => _currentIndex = _servicesTab);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
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
        backgroundColor: kProviderStepBackground,
        body: SafeArea(bottom: false, child: _buildBody(context)),
        bottomNavigationBar: _ProviderBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case _ordersTab:
        return ProviderOrdersScreen(onChanged: _refresh);
      case _servicesTab:
        return const ProviderServicesScreen();
      case 3:
        return const ProviderSettingsScreen();
      default:
        return _buildHomeContent(context);
    }
  }

  Widget _buildHomeContent(BuildContext context) {
    return BlocBuilder<ProviderDashboardCubit, ProviderDashboardState>(
      builder: (context, state) {
        if (state is ProviderDashboardLoading ||
            state is ProviderDashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProviderDashboardError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                TextButton(
                  onPressed: () =>
                      context.read<ProviderDashboardCubit>().loadDashboard(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final data = (state as ProviderDashboardLoaded).data;

        return RefreshIndicator(
          onRefresh: () =>
              context.read<ProviderDashboardCubit>().loadDashboard(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            children: [
              ProviderHomeHeaderWidget(data: data),
              const SizedBox(height: 24),
              ProviderHomeSubscriptionCardWidget(data: data),
              const SizedBox(height: 22),
              ProviderHomeQuickManagementWidget(
                data: data,
                onServicesTap: _showServicesActions,
                onOrdersTap: () => setState(() => _currentIndex = _ordersTab),
              ),
              const SizedBox(height: 26),
              ProviderHomeLatestOrdersWidget(
                data: data,
                onShowAll: () => setState(() => _currentIndex = _ordersTab),
                onAddService: _openAddService,
                onOpenOrder: _openOrder,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Pink rounded bottom bar from the provider designs.
class _ProviderBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ProviderBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.assignment_turned_in_outlined, 'الطلبات'),
    (Icons.storefront_outlined, 'خدماتي'),
    (Icons.person_outline_rounded, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5E4E6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _items[i].$1,
                          color: i == currentIndex ? primary : Colors.black54,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].$2,
                          style: TextStyle(
                            fontSize: 13,
                            color: i == currentIndex
                                ? Colors.black87
                                : Colors.black54,
                            fontWeight: i == currentIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
