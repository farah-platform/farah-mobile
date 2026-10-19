import 'package:flutter/material.dart';

/// "ادارة المتجر السريعة": new orders, services and reviews cards.
class ProviderHomeQuickManagementWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onServicesTap;
  final VoidCallback onOrdersTap;

  const ProviderHomeQuickManagementWidget({
    super.key,
    required this.data,
    required this.onServicesTap,
    required this.onOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final counts = (data['counts'] as Map?) ?? const {};
    final newOrders = (counts['new_orders'] as num?)?.toInt() ?? 0;
    final today = (counts['new_orders_today'] as num?)?.toInt() ?? 0;
    final services = (counts['services'] as num?)?.toInt() ?? 0;
    final reviews = ((data['rating'] as Map?)?['count'] as num?)?.toInt() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ادارة المتجر السريعة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _card(
                  onTap: onOrdersTap,
                  top: Text(
                    '$newOrders',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: 'طلبات جديدة',
                  bottom: today > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBEFE0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '+$today اليوم',
                            style: const TextStyle(
                              color: Color(0xFFB7791F),
                              fontSize: 10,
                            ),
                          ),
                        )
                      : _subtitle('ستظهر هنا\nالطلبات الجديدة'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _card(
                  onTap: onServicesTap,
                  top: _icon(Icons.storefront_outlined, primary),
                  title: 'الخدمات',
                  bottom: _subtitle(
                    services > 0 ? 'ادارة الباقات' : 'أضف اول\nخدماتك',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _card(
                  top: _icon(Icons.star_border_rounded, primary),
                  title: 'التقييمات',
                  bottom: _subtitle(
                    reviews > 0 ? 'تجارب العملاء' : 'ستظهر هنا\nتقييمات عملائك',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _icon(IconData icon, Color primary) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE3E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: primary, size: 20),
    );
  }

  Widget _subtitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.6),
    );
  }

  Widget _card({
    required Widget top,
    required String title,
    required Widget bottom,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
          child: Column(
            children: [
              top,
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              bottom,
            ],
          ),
        ),
      ),
    );
  }
}
