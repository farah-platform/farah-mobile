import 'package:farah/core/constants/app_routes.dart';
import 'package:flutter/material.dart';

/// "اهلا بك ..." with the store logo, category and notifications bell.
class ProviderHomeHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProviderHomeHeaderWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final provider = (data['provider'] as Map?) ?? const {};
    final avatar = provider['avatar']?.toString();
    final category = (provider['category'] as Map?)?['name']?.toString();
    final unread = (data['unread_notifications'] as num?) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: primary.withValues(alpha: 0.12),
              backgroundImage: avatar != null && avatar.isNotEmpty
                  ? NetworkImage(avatar)
                  : null,
              child: avatar == null || avatar.isEmpty
                  ? Icon(Icons.storefront_outlined, color: primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اهلا بك ${provider['business_name'] ?? ''}',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (category != null)
                    Text(
                      category,
                      style: TextStyle(
                        color: primary.withValues(alpha: 0.85),
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              icon: Badge(
                isLabelVisible: unread > 0,
                smallSize: 8,
                backgroundColor: primary,
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 28,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        if (provider['is_bookable'] == true) ...[
          const SizedBox(height: 12),
          const ProviderBookableChip(),
        ],
      ],
    );
  }
}

/// Green "متاح للحجز" chip.
class ProviderBookableChip extends StatelessWidget {
  const ProviderBookableChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA9D8B0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: Color(0xFF2E7D3A)),
          SizedBox(width: 5),
          Text(
            'متاح للحجز',
            style: TextStyle(
              color: Color(0xFF2E7D3A),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
