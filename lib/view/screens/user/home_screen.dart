import 'package:farah/core/constants/app_colors.dart';
import 'package:farah/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  static const List<Widget> _bodies = [
    Center(child: Text('الصفحة الرئيسية')),
    Center(child: Text('البحث')),
    Center(child: Text('حجوزاتي')),
  ];

  static const List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: 'البحث',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'حجوزاتي',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'حسابي',
    ),
  ];

  void _onTabTapped(int index) {
    if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.settings);
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
        body: IndexedStack(
          index: _currentIndex,
          children: _bodies,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLightGrey,
          showUnselectedLabels: true,
          items: _items,
        ),
      ),
    );
  }
}
