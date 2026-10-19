import 'package:flutter/material.dart';

class FarahBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FarahBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Color(0xFFF8E8EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. الرئيسية (أقصى اليمين)
          _buildItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'الرئيسية',
            index: 0,
          ),
          // 2. طلباتي
          _buildItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment,
            label: 'طلباتي',
            index: 1,
          ),
          // 3. المفضلة
          _buildItem(
            icon: Icons.favorite_border,
            activeIcon: Icons.favorite,
            label: 'المفضلة',
            index: 2,
          ),
          // 4. حسابي (أقصى اليسار)
          _buildItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'حسابي',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 25,
              color: const Color(0xFF7B2146),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
