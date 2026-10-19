import 'package:flutter/material.dart';

/// Month grid from the provider designs: weeks start on Friday (rightmost),
/// with previous/next month arrows. Each day is drawn by [dayBuilder].
class ProviderMonthCalendar extends StatelessWidget {
  final DateTime month;
  final bool canGoBack;
  final bool loading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Widget Function(DateTime day) dayBuilder;

  const ProviderMonthCalendar({
    super.key,
    required this.month,
    required this.canGoBack,
    required this.onPrevious,
    required this.onNext,
    required this.dayBuilder,
    this.loading = false,
  });

  static const _weekdays = [
    'جمعة',
    'سبت',
    'أحد',
    'اثنين',
    'ثلاثاء',
    'اربعاء',
    'خميس',
  ];
  static const monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String monthKey(DateTime m) =>
      '${m.year}-${m.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset =
        (DateTime(month.year, month.month).weekday - DateTime.friday + 7) % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3DADD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'الشهر السابق',
                onPressed: canGoBack ? onPrevious : null,
                icon: const Icon(Icons.chevron_right),
              ),
              Expanded(
                child: Text(
                  '${monthNames[month.month - 1]} ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'الشهر التالي',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_left),
              ),
            ],
          ),
          const Divider(height: 8),
          Row(
            children: [
              for (final d in _weekdays)
                Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
              children: [
                for (var i = 0; i < offset; i++) const SizedBox(),
                for (var day = 1; day <= daysInMonth; day++)
                  dayBuilder(DateTime(month.year, month.month, day)),
              ],
            ),
        ],
      ),
    );
  }
}
