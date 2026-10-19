import 'package:farah/view/widgets/provider/orders/provider_order_card.dart';
import 'package:flutter/material.dart';

/// "احدث الطلبات" from the dashboard's latest_orders.
class ProviderHomeLatestOrdersWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onShowAll;
  final VoidCallback onAddService;
  final ValueChanged<int> onOpenOrder;

  const ProviderHomeLatestOrdersWidget({
    super.key,
    required this.data,
    required this.onShowAll,
    required this.onAddService,
    required this.onOpenOrder,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final orders = (data['latest_orders'] as List?) ?? const [];
    final hasServices =
        (((data['counts'] as Map?)?['services'] as num?) ?? 0) > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'احدث الطلبات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            InkWell(
              onTap: onShowAll,
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  color: primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          _empty(primary, hasServices)
        else
          for (final order in orders.whereType<Map>())
            ProviderOrderCard(
              order: Map<String, dynamic>.from(order),
              onTap: () => onOpenOrder(int.parse(order['id'].toString())),
            ),
      ],
    );
  }

  Widget _empty(Color primary, bool hasServices) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            size: 40,
            color: Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            hasServices
                ? 'ستظهر هنا أحدث طلبات الحجز'
                : 'ابدأ بإضافة خدماتك ليصلك أول طلب',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          if (!hasServices) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: 150,
              height: 34,
              child: ElevatedButton(
                onPressed: onAddService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'أضف الآن',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static final _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
    ],
  );
}
