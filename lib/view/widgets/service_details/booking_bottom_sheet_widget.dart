import 'package:flutter/material.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/view/screens/user/booking_confirmation_screen.dart';

class BookingBottomSheetWidget extends StatefulWidget {
  final ServiceModel service;

  const BookingBottomSheetWidget({super.key, required this.service});

  static Future<void> show(BuildContext context, ServiceModel service) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingBottomSheetWidget(service: service),
    );
  }

  @override
  State<BookingBottomSheetWidget> createState() =>
      _BookingBottomSheetWidgetState();
}

class _BookingBottomSheetWidgetState extends State<BookingBottomSheetWidget> {
  late DateTime _currentMonth;
  late DateTime _today;
  int? _selectedDay;
  int _selectedSlotIndex = 1;
  final TextEditingController _notesController = TextEditingController();

  final Set<int> _bookedDays = {3, 7, 12, 18, 22, 27};

  final List<String> _arabicMonths = [
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
  }

  int get _daysInMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  int get _firstDayOffset {
    final weekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    return (weekday - DateTime.friday + 7) % 7;
  }

  bool _isPastDay(int day) {
    final date = DateTime(_currentMonth.year, _currentMonth.month, day);
    return date.isBefore(_today);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primaryColor = colors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'تفاصيل الحجز',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarCard(primaryColor, colors, theme),
                    const SizedBox(height: 10),
                    _buildLegend(primaryColor, colors, theme),
                    const SizedBox(height: 18),
                    Text(
                      'الفترات المتاحة',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSlotTile(
                      index: 0,
                      title: 'الفترة الصباحية',
                      time: '10:00 ص _ 3:00 م',
                      primaryColor: primaryColor,
                      colors: colors,
                      theme: theme,
                    ),
                    const SizedBox(height: 10),
                    _buildSlotTile(
                      index: 1,
                      title: 'الفترة المسائية',
                      time: '5:00 م _ 10:00 م',
                      primaryColor: primaryColor,
                      colors: colors,
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.outline.withOpacity(0.15),
                        ),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'إضافة ملاحظات...',
                          hintStyle: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.35),
                            fontSize: 11,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ الإجمالي',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: colors.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${widget.service.price.toInt()} ${widget.service.currency}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _selectedDay == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                final monthName =
                                    _arabicMonths[_currentMonth.month - 1];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingConfirmationScreen(
                                      service: widget.service,
                                      selectedDate:
                                          '$_selectedDay $monthName ${_currentMonth.year}',
                                      selectedTime: _selectedSlotIndex == 0
                                          ? '10:00 ص _ 3:00 م'
                                          : '5:00 م _ 10:00 م',
                                    ),
                                  ),
                                );
                              },
                        child: const Text(
                          'المواصلة للحجز',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'سيتم إشعارك فور موافقة مزود الخدمة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9.5,
                          color: colors.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(
    Color primaryColor,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final daysOfWeek = [
      'جمعة',
      'سبت',
      'أحد',
      'اثنين',
      'ثلاثاء',
      'اربعاء',
      'خميس',
    ];
    final currentMonthName = _arabicMonths[_currentMonth.month - 1];
    final totalCells = _daysInMonth + _firstDayOffset;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                      1,
                    );
                    _selectedDay = null;
                  });
                },
              ),
              Text(
                '$currentMonthName ${_currentMonth.year}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                      1,
                    );
                    _selectedDay = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index < _firstDayOffset) {
                return const SizedBox.shrink();
              }

              final day = index - _firstDayOffset + 1;
              final isPast = _isPastDay(day);
              final isBooked = _bookedDays.contains(day) || isPast;
              final isSelected = _selectedDay == day;

              return GestureDetector(
                onTap: isBooked
                    ? null
                    : () {
                        setState(() => _selectedDay = day);
                      },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBooked
                        ? (isPast
                            ? colors.outline.withOpacity(0.04)
                            : primaryColor)
                        : (isSelected
                            ? primaryColor.withOpacity(0.15)
                            : colors.outline.withOpacity(0.08)),
                    border: isSelected && !isBooked
                        ? Border.all(color: primaryColor, width: 1.6)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPast
                            ? colors.onSurface.withOpacity(0.2)
                            : (isBooked
                                ? Colors.white
                                : (isSelected
                                    ? primaryColor
                                    : colors.onSurface)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    Color primaryColor,
    ColorScheme colors,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'المواعيد المحجوزة',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 9.5),
        ),
        const SizedBox(width: 18),
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.outline.withOpacity(0.15),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'المواعيد المتاحة',
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 9.5),
        ),
      ],
    );
  }

  Widget _buildSlotTile({
    required int index,
    required String title,
    required String time,
    required Color primaryColor,
    required ColorScheme colors,
    required ThemeData theme,
  }) {
    final isSelected = _selectedSlotIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedSlotIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.06) : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor.withOpacity(0.4)
                : colors.outline.withOpacity(0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? primaryColor
                  : colors.outline.withOpacity(0.5),
              size: 20,
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: isSelected ? primaryColor : colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: colors.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}