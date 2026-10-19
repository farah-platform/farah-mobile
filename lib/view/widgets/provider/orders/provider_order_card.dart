import 'package:farah/core/utils/arabic_date.dart';
import 'package:flutter/material.dart';

/// Label, text colour and fill for each booking workflow status.
const providerOrderStatuses = {
  'provider_pending': ('غير مؤكد', Color(0xFFB7791F), Color(0xFFFBEFE0)),
  'payment_awaiting': ('بانتظار الدفع', Color(0xFFB7791F), Color(0xFFFBEFE0)),
  'review_under_proof': ('مراجعة الدفع', Color(0xFF7B2146), Color(0xFFFBE3E8)),
  'confirmed': ('مؤكدة', Color(0xFF2E7D3A), Color(0xFFE6F4E8)),
  'completed': ('مكتملة', Color(0xFF2E7D3A), Color(0xFFE6F4E8)),
  'rejected': ('مرفوضة', Color(0xFFC62828), Color(0xFFFDECEC)),
  'cancelled': ('ملغاة', Color(0xFF757575), Color(0xFFF1F1F1)),
  'expired': ('منتهية', Color(0xFF757575), Color(0xFFF1F1F1)),
};

class ProviderOrderStatusChip extends StatelessWidget {
  final String? status;
  const ProviderOrderStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, fill) =
        providerOrderStatuses[status] ??
        ('—', const Color(0xFF757575), const Color(0xFFF1F1F1));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10)),
    );
  }
}

String formatOrderAmount(dynamic amount, dynamic currency) {
  final n = (amount as num?) ?? num.tryParse(amount?.toString() ?? '') ?? 0;
  final text = n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  return '$text${currency ?? ''}';
}

/// Booking card from the designs' "احدث الطلبات" list.
class ProviderOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onTap;

  const ProviderOrderCard({super.key, required this.order, this.onTap});

  static final decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final date = DateTime.tryParse(order['date']?.toString() ?? '');
    final pricing = order['pricing'] as Map?;
    final total = pricing?['total'] ?? order['total'];
    final currency = pricing?['currency'] ?? order['currency'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
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
                    ProviderOrderStatusChip(
                      status: order['status']?.toString(),
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
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        date != null ? formatArabicDate(date) : '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      formatOrderAmount(total, currency),
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
          ),
        ),
      ),
    );
  }
}
