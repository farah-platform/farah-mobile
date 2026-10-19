import 'package:farah/core/utils/arabic_date.dart';
import 'package:flutter/material.dart';

/// "احدث الطلبات" from the dashboard's latest_orders.
class ProviderHomeLatestOrdersWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onShowAll;
  final VoidCallback onAddService;

  const ProviderHomeLatestOrdersWidget({
    super.key,
    required this.data,
    required this.onShowAll,
    required this.onAddService,
  });

  // Label and colour for each booking workflow status.
  static const _statuses = {
    'provider_pending': ('غير مؤكد', Color(0xFFB7791F), Color(0xFFFBEFE0)),
    'payment_awaiting': ('بانتظار الدفع', Color(0xFFB7791F), Color(0xFFFBEFE0)),
    'review_under_proof': ('مراجعة الدفع', Color(0xFFB7791F), Color(0xFFFBEFE0)),
    'confirmed': ('مؤكدة', Color(0xFF2E7D3A), Color(0xFFE6F4E8)),
    'completed': ('مكتملة', Color(0xFF2E7D3A), Color(0xFFE6F4E8)),
    'rejected': ('مرفوضة', Color(0xFFC62828), Color(0xFFFDECEC)),
    'cancelled': ('ملغاة', Color(0xFF757575), Color(0xFFF1F1F1)),
    'expired': ('منتهية', Color(0xFF757575), Color(0xFFF1F1F1)),
  };

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
          for (final order in orders)
            _orderCard(Map<String, dynamic>.from(order as Map), primary),
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

  Widget _orderCard(Map<String, dynamic> order, Color primary) {
    final (label, color, fill) =
        _statuses[order['status']] ??
        ('—', const Color(0xFF757575), const Color(0xFFF1F1F1));
    final date = DateTime.tryParse(order['date']?.toString() ?? '');
    final total = (order['total'] as num?) ?? 0;
    final price = total == total.roundToDouble()
        ? total.toInt().toString()
        : total.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  (order['customer'] as Map?)?['name']?.toString() ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Text(label, style: TextStyle(color: color, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (order['service'] as Map?)?['title']?.toString() ?? '',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const Divider(height: 22, color: Color(0xFFEDE6E8)),
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 14, color: primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  date != null ? formatArabicDate(date) : '',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                '$price${order['currency'] ?? ''}',
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
