import 'package:flutter/material.dart';

class ProviderHomeQuickManagementWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProviderHomeQuickManagementWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إدارة المتجر السريعة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCard(
                title: 'طلبات جديدة',
                count: (data['new_orders'] ?? 0).toString(),
                subtitle: 'سيظهر هنا\nالطلبات الجديدة',
                icon: Icons.receipt_long_outlined,
                primary: primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCard(
                title: 'الخدمات',
                count: (data['services_count'] ?? 0).toString(),
                subtitle: 'أضف الآن\nخدماتك',
                icon: Icons.business_center_outlined,
                primary: primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildCard(
                title: 'التقييمات',
                count: (data['rating'] ?? 0).toString(),
                subtitle: 'تقييم ممتاز\nمن عملائك',
                icon: Icons.star_border,
                primary: primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
