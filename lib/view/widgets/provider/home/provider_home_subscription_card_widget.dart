import 'package:farah/core/constants/app_routes.dart';
import 'package:flutter/material.dart';

/// Subscription status with the days left from the dashboard API.
class ProviderHomeSubscriptionCardWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProviderHomeSubscriptionCardWidget({super.key, required this.data});

  static const _cardColor = Color(0xFF953B55);

  @override
  Widget build(BuildContext context) {
    final subscription = (data['subscription'] as Map?) ?? const {};
    final active = subscription['is_active'] == true;
    final daysLeft = (subscription['days_remaining'] as num?)?.toInt() ?? 0;
    final start = DateTime.tryParse(subscription['starts_at']?.toString() ?? '');
    final end = DateTime.tryParse(subscription['ends_at']?.toString() ?? '');
    final totalDays = start != null && end != null
        ? end.difference(start).inDays
        : 0;
    final remaining = totalDays > 0
        ? (daysLeft / totalDays).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.providerSubscriptionPlans,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ترقية',
                    style: TextStyle(
                      color: _cardColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: Color(0xFF2E7D3A)),
                      SizedBox(width: 5),
                      Text(
                        'الاشتراك نشط',
                        style: TextStyle(
                          color: Color(0xFF2E7D3A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            active ? 'الاشتراك نشط' : 'لا يوجد اشتراك فعّال',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? 'متبقي $daysLeftيوم لإنهاء الاشتراك'
                : (subscription['message']?.toString() ?? ''),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (active) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: remaining,
                minHeight: 7,
                color: Colors.white,
                backgroundColor: const Color(0xFFE29AB0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
