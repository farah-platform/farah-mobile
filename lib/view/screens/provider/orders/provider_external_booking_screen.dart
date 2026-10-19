import 'package:farah/cubits/provider_external_booking/provider_external_booking_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/provider_month_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "إضافة حجز خارجي": records a booking made outside the app and blocks
/// its date on the chosen service.
class ProviderExternalBookingScreen extends StatefulWidget {
  const ProviderExternalBookingScreen({super.key});

  @override
  State<ProviderExternalBookingScreen> createState() =>
      _ProviderExternalBookingScreenState();
}

class _ProviderExternalBookingScreenState
    extends State<ProviderExternalBookingScreen> {
  static const _fieldBorder = Color(0xFFDADADA);
  static const _paymentMethods = [
    'نقدا',
    'بنك فلسطين',
    'محفظة بال باي',
    'محفظة جوال باي',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _totalController = TextEditingController();
  final _depositController = TextEditingController();
  final _notesController = TextEditingController();

  int? _serviceId;
  String? _paymentMethod;
  DateTime? _date;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _totalController.addListener(() => setState(() {}));
    _depositController.addListener(() => setState(() {}));
    context.read<ProviderExternalBookingCubit>().load();
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _phoneController,
      _totalController,
      _depositController,
      _notesController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? get _remaining {
    final total = double.tryParse(_totalController.text.trim());
    if (total == null) return null;
    final deposit = double.tryParse(_depositController.text.trim()) ?? 0;
    return (total - deposit).clamp(0, double.infinity).toDouble();
  }

  void _loadDates() {
    if (_serviceId == null) return;
    context.read<ProviderExternalBookingCubit>().loadTakenDates(
      _serviceId!,
      ProviderMonthCalendar.monthKey(_month),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اختر تاريخ الحجز')));
      return;
    }
    context.read<ProviderExternalBookingCubit>().save({
      'customer_name': _nameController.text.trim(),
      'customer_phone': _phoneController.text.trim(),
      'service_id': _serviceId,
      'booking_date': ProviderMonthCalendar.dateKey(_date!),
      'total_price': double.parse(_totalController.text.trim()),
      'deposit_amount': double.tryParse(_depositController.text.trim()) ?? 0,
      'payment_method': _paymentMethod,
      'status': 'confirmed',
      'notes': _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'إضافة حجز خارجي'),
      body:
          BlocConsumer<
            ProviderExternalBookingCubit,
            ProviderExternalBookingState
          >(
            listener: (context, state) {
              if (state.saved) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إضافة الحجز وحجز التاريخ')),
                );
                Navigator.pop(context, true);
              } else if (state.error != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _infoNote(primary),
                      const SizedBox(height: 18),
                      _card('بيانات العميل', [
                        _label('اسم العميل', primary),
                        TextFormField(
                          controller: _nameController,
                          decoration: _input('أدخل اسم العميل'),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'أدخل اسم العميل'
                              : null,
                        ),
                        _label('رقم العميل', primary),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: _input('أدخل رقم العميل'),
                        ),
                      ]),
                      _card('تفاصيل الخدمة', [
                        _label('الخدمة', primary),
                        DropdownButtonFormField<int>(
                          initialValue: _serviceId,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: primary),
                          decoration: _input('أختر الخدمة'),
                          items: [
                            for (final s in state.services)
                              DropdownMenuItem(
                                value: int.parse(s['id'].toString()),
                                child: Text(s['title']?.toString() ?? ''),
                              ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _serviceId = v;
                              _date = null;
                            });
                            _loadDates();
                          },
                          validator: (v) => v == null ? 'اختر الخدمة' : null,
                        ),
                      ]),
                      _card('تفاصيل الدفع', [
                        _label('السعر الإجمالي للخدمة', primary),
                        _amount(_totalController, 'أدخل سعر الخدمة', (v) {
                          final n = double.tryParse((v ?? '').trim());
                          return n == null || n <= 0 ? 'أدخل سعر الخدمة' : null;
                        }),
                        _label('المبلغ المدفوع (العربون)', primary),
                        _amount(_depositController, 'أدخل العربون المدفوع', (
                          v,
                        ) {
                          if ((v ?? '').trim().isEmpty) return null;
                          final n = double.tryParse(v!.trim());
                          final total = double.tryParse(
                            _totalController.text.trim(),
                          );
                          if (n == null) return 'أدخل مبلغاً صحيحاً';
                          return total != null && n > total
                              ? 'العربون أكبر من السعر الإجمالي'
                              : null;
                        }),
                        _label('طريقة استلام العربون', primary),
                        DropdownButtonFormField<String>(
                          initialValue: _paymentMethod,
                          isExpanded: true,
                          icon: Icon(Icons.keyboard_arrow_down, color: primary),
                          decoration: _input('اختر طريقة استلام المبلغ'),
                          items: [
                            for (final m in _paymentMethods)
                              DropdownMenuItem(value: m, child: Text(m)),
                          ],
                          onChanged: (v) => setState(() => _paymentMethod = v),
                        ),
                        _label('المبلغ المتبقي', primary),
                        InputDecorator(
                          decoration: _input('المبلغ المتبقي مقابل الخدمة'),
                          isEmpty: _remaining == null,
                          child: Text(
                            _remaining == null ? '' : _format(_remaining!),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ]),
                      const Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 12),
                        child: Text(
                          'تاريخ الحجز',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _calendar(state, primary),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _legend(primary, 'التاريخ المختار'),
                          _legend(const Color(0xFFDCDCDC), 'محجوز سابقا'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notesController,
                        minLines: 5,
                        maxLines: 7,
                        decoration: _input('اضافة ملاحظات..'),
                      ),
                      const SizedBox(height: 24),
                      ProviderPrimaryButton(
                        label: 'إضافة الحجز',
                        loading: state.saving,
                        onPressed: _submit,
                      ),
                      TextButton(
                        onPressed: () => Navigator.maybePop(context),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _calendar(ProviderExternalBookingState state, Color primary) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return ProviderMonthCalendar(
      month: _month,
      canGoBack: _month.isAfter(DateTime(now.year, now.month)),
      loading: state.loadingDates,
      onPrevious: () {
        setState(() => _month = DateTime(_month.year, _month.month - 1));
        _loadDates();
      },
      onNext: () {
        setState(() => _month = DateTime(_month.year, _month.month + 1));
        _loadDates();
      },
      dayBuilder: (day) {
        final key = ProviderMonthCalendar.dateKey(day);
        final past = day.isBefore(today);
        final taken = state.takenDates.contains(key);
        final selected =
            _date != null && ProviderMonthCalendar.dateKey(_date!) == key;
        return Tooltip(
          message: taken ? 'محجوز سابقا' : '',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: past || taken ? null : () => setState(() => _date = day),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? const Color(0xFF953B55)
                    : (taken
                          ? const Color(0xFFDCDCDC)
                          : const Color(0xFFF7F7F7)),
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 11,
                  color: selected
                      ? Colors.white
                      : (past ? Colors.black26 : Colors.black87),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legend(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _infoNote(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFF0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'قم بتسجيل الحجوزات التي تمت خارج التطبيق ، لحجز التاريخ ومنع تعارضه مع الحجوزات الأخرى',
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3DADD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _amount(
    TextEditingController controller,
    String hint,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: _input(hint),
      validator: validator,
    );
  }

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  InputDecoration _input(String hint) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(_fieldBorder),
      border: border(_fieldBorder),
      focusedBorder: border(Theme.of(context).colorScheme.primary),
    );
  }
}
