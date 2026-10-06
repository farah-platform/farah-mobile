import 'package:farah/cubits/provider_dashboard/provider_dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/provider/home/provider_home_header_widget.dart';
import '../../widgets/provider/home/provider_home_subscription_card_widget.dart';
import '../../widgets/provider/home/provider_home_quick_management_widget.dart';
import 'services/provider_services_screen.dart';
import '../../widgets/provider/home/provider_home_latest_orders_widget.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    context.read<ProviderDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

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
        body: SafeArea(child: _buildBody(context)),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'الطلبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center),
              label: 'خدماتي',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent(context);
      case 1:
        return const Center(child: Text('الطلبات (قريباً)'));
      case 2:
        return const ProviderServicesScreen();
      case 3:
        return const Center(child: Text('حسابي (قريباً)'));
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
          return Center(child: Text(state.message));
        }

        final data = (state as ProviderDashboardLoaded).data;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProviderHomeHeaderWidget(data: data),
              const SizedBox(height: 24),
              ProviderHomeSubscriptionCardWidget(data: data),
              const SizedBox(height: 24),
              ProviderHomeQuickManagementWidget(data: data),
              const SizedBox(height: 24),
              ProviderHomeLatestOrdersWidget(data: data),
            ],
          ),
        );
      },
    );
  }
}
