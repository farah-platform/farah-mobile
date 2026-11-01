import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:farah/cubits/booking_options/booking_options_cubit.dart';
import 'package:farah/data/models/booking_options_model.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/booking_repository.dart';
import 'package:farah/view/screens/user/booking_confirmation_screen.dart';

class BookingBottomSheetWidget extends StatefulWidget {
  final ServiceModel service;

  const BookingBottomSheetWidget({super.key, required this.service});

  static Future<void> show(BuildContext context, ServiceModel service) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => BookingOptionsCubit(
          context.read<BookingRepository>(),
          serviceId: service.id,
        )..loadMonth(DateTime.now()),
        child: BookingBottomSheetWidget(service: service),
      ),
    );
  }

  @override
  State<BookingBottomSheetWidget> createState() =>
      _BookingBottomSheetWidgetState();
}

class _BookingBottomSheetWidgetState extends State<BookingBottomSheetWidget> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  int? _selectedSlotIndex;
  final TextEditingController _notesController = TextEditingController();

  final Color _maroon = const Color(0xFF7B2146);
  final Color _lightGray = const Color(0xFFF1F2F4);
  final Color _selectedBg = const Color(0xFFF6ECEF);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _changeMonth(int increment) {
    setState(() {
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + increment,
      );
      _selectedDate = null;
      _selectedSlotIndex = null;
    });
    context.read<BookingOptionsCubit>().loadMonth(_currentMonth);
  }

  List<BookingOptionSlotModel> _slotsOf(BookingOptionsModel? options) {
    if (options == null || _selectedDate == null) return const [];
    return options.dayOf(_selectedDate!.day)?.slots ?? const [];
  }

  BookingOptionSlotModel? _selectedSlot(BookingOptionsModel? options) {
    final slots = _slotsOf(options);
    final i = _selectedSlotIndex;
    return i != null && i < slots.length ? slots[i] : null;
  }

  String _formatPrice(double price) =>
      price == price.roundToDouble() ? '${price.toInt()}' : '$price';

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    // The week row starts on Friday (جمعة), so offset from Friday.
    final firstDayOffset =
        (DateTime(_currentMonth.year, _currentMonth.month, 1).weekday -
            DateTime.friday) %
        7;
    final optionsState = context.watch<BookingOptionsCubit>().state;
    final options = optionsState is BookingOptionsLoaded
        ? optionsState.options
        : null;
    final slots = _slotsOf(options);
    final selectedSlot = _selectedSlot(options);
    final totalPrice =
        selectedSlot?.price ?? options?.price ?? widget.service.price;
    final currency = options?.currency.isNotEmpty == true
        ? options!.currency
        : widget.service.currency;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // المقبض العلوي
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'تفاصيل الحجز',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة الرزنامة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        // شريط التنقل بين الأشهر
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 22),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Text(
                              DateFormat(
                                'MMMM yyyy',
                                'ar',
                              ).format(_currentMonth),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 22),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // أسماء أيام الأسبوع
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            _DayLabel('جمعة'),
                            _DayLabel('سبت'),
                            _DayLabel('أحد'),
                            _DayLabel('اثنين'),
                            _DayLabel('ثلاثاء'),
                            _DayLabel('اربعاء'),
                            _DayLabel('خميس'),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // شبكة الأيام
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: daysInMonth + firstDayOffset,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            if (index < firstDayOffset) return const SizedBox();
                            final day = index - firstDayOffset + 1;
                            final dayInfo = options?.dayOf(day);
                            final isSelectable = dayInfo?.isAvailable == true;
                            final isBooked =
                                dayInfo != null &&
                                !dayInfo.isAvailable &&
                                !dayInfo.isPast;
                            final isSelected =
                                _selectedDate?.day == day &&
                                _selectedDate?.month == _currentMonth.month;

                            return InkWell(
                              onTap: !isSelectable
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedDate = DateTime(
                                          _currentMonth.year,
                                          _currentMonth.month,
                                          day,
                                        );
                                        _selectedSlotIndex = null;
                                      });
                                    },
                              customBorder: const CircleBorder(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isBooked
                                      ? _maroon
                                      : (isSelected
                                            ? _maroon.withOpacity(0.2)
                                            : _lightGray),
                                  border: isSelected
                                      ? Border.all(color: _maroon, width: 1.5)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isBooked
                                        ? Colors.white
                                        : (isSelectable
                                              ? Colors.black87
                                              : Colors.black26),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (optionsState is BookingOptionsLoading) ...[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(),
                        ],
                        if (optionsState is BookingOptionsError) ...[
                          const SizedBox(height: 10),
                          Text(
                            optionsState.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // دليل الألوان (Legend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendDot(_maroon, 'المواعيد المحجوزة'),
                      const SizedBox(width: 24),
                      _buildLegendDot(_lightGray, 'المواعيد المتاحة'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'الفترات المتاحة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),

                  // الفترات كما يعرّفها مقدّم الخدمة (من الـ API)
                  if (_selectedDate == null)
                    const Text(
                      'اختر تاريخاً لعرض الفترات المتاحة',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    )
                  else if (slots.isEmpty)
                    const Text(
                      'لا توجد فترات متاحة لهذا اليوم',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    )
                  else
                    for (var i = 0; i < slots.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _buildPeriodOption(
                        index: i,
                        title: slots[i].label ?? '',
                        time: slots[i].endTime == null
                            ? slots[i].startTime
                            : '${slots[i].startTime} - ${slots[i].endTime}',
                        enabled: slots[i].isAvailable,
                      ),
                    ],

                  const SizedBox(height: 14),

                  // خانة إضافة ملاحظات
                  Container(
                    height: 85,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'اضافة ملاحظات',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black38,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // شريط المبلغ الإجمالي
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_formatPrice(totalPrice)} $currency',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _maroon,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'المبلغ الاجمالي',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // زر المواصلة للحجز
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _maroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى اختيار تاريخ الحجز أولاً'),
                            ),
                          );
                          return;
                        }
                        if (selectedSlot == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى اختيار الفترة أولاً'),
                            ),
                          );
                          return;
                        }

                        final notes = _notesController.text.trim();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmationScreen(
                              service: widget.service,
                              selectedDateTime: _selectedDate!,
                              slot: selectedSlot,
                              currency: currency,
                              notes: notes.isEmpty ? null : notes,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'المواصلة للحجز',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'سيتم إشعارك فور موافقة مزود الخدمة',
                      style: TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPeriodOption({
    required int index,
    required String title,
    required String time,
    bool enabled = true,
  }) {
    final isSelected = _selectedSlotIndex == index;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled
            ? () => setState(() => _selectedSlotIndex = index)
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? _selectedBg : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _maroon.withOpacity(0.4) : Colors.black12,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? _maroon : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? _maroon : Colors.black26,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? _maroon : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, color: Colors.black54),
    );
  }
}
