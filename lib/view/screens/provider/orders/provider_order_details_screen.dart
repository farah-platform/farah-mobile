import 'package:farah/core/utils/arabic_date.dart';
import 'package:farah/cubits/provider_orders/provider_order_details_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/orders/provider_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One booking for the provider: accept or reject the request, review the
/// customer's deposit proof, and mark the booking done after its date.
class ProviderOrderDetailsScreen extends StatefulWidget {
  const ProviderOrderDetailsScreen({super.key});

  @override
  State<ProviderOrderDetailsScreen> createState() =>
      _ProviderOrderDetailsScreenState();
}

class _ProviderOrderDetailsScreenState
    extends State<ProviderOrderDetailsScreen> {
  static const _cardBorder = Color(0xFFE3DADD);
  static const _red = Color(0xFFD9473F);

  bool _changed = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderOrderDetailsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _changed);
      },
      child: Scaffold(
        backgroundColor: kProviderStepBackground,
        appBar: providerStepAppBar(context, 'تفاصيل الطلب'),
        body:
            BlocConsumer<ProviderOrderDetailsCubit, ProviderOrderDetailsState>(
              listener: (context, state) {
                final text = state.message ?? state.error;
                if (state.message != null) _changed = true;
                if (text != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(text)));
                }
              },
              builder: (context, state) {
                final booking = state.booking;
                if (state.loading && booking == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (booking == null) {
                  return Center(
                    child: TextButton(
                      onPressed: () =>
                          context.read<ProviderOrderDetailsCubit>().load(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    _header(booking),
                    _bookingCard(booking, primary),
                    _customerCard(booking),
                    _amountsCard(booking),
                    ..._paymentsSection(booking, state, primary),
                    const SizedBox(height: 12),
                    ..._actions(booking, state, primary),
                  ],
                );
              },
            ),
      ),
    );
  }

  // ---- Sections --------------------------------------------------------------

  Widget _card({String? title, required List<Widget> children}) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
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
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ?trailing,
        ],
      ),
    );
  }

  Widget _header(Map<String, dynamic> b) {
    return _card(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                (b['customer'] as Map?)?['name']?.toString() ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ProviderOrderStatusChip(status: b['status']?.toString()),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'رقم الطلب: ${b['reference'] ?? ''}',
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        if (b['status'] == 'provider_pending' && b['expires_at'] != null)
          _hint(
            'يرجى الرد على الطلب قبل ${_dateTime(b['expires_at'])}، وإلا سينتهي تلقائياً.',
          ),
      ],
    );
  }

  Widget _bookingCard(Map<String, dynamic> b, Color primary) {
    final service = (b['service'] as Map?) ?? const {};
    final image = service['image']?.toString();
    final date = DateTime.tryParse(b['date']?.toString() ?? '');
    final slot = b['slot']?.toString();
    return _card(
      title: 'تفاصيل الحجز',
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 54,
                height: 54,
                child: image != null && image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                service['title']?.toString() ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 22, color: Color(0xFFEDE6E8)),
        _row('التاريخ', date != null ? formatArabicDate(date) : '—'),
        _row(
          'الفترة',
          [
            if (slot != null && slot.isNotEmpty) slot,
            b['time'] ?? '',
          ].where((s) => s.toString().isNotEmpty).join(' · '),
        ),
        if ((b['notes']?.toString() ?? '').isNotEmpty)
          _row('ملاحظات العميل', b['notes'].toString()),
        if ((b['provider_note']?.toString() ?? '').isNotEmpty)
          _row('ملاحظتك', b['provider_note'].toString()),
      ],
    );
  }

  Widget _customerCard(Map<String, dynamic> b) {
    final phone = (b['customer'] as Map?)?['phone']?.toString();
    return _card(
      title: 'التواصل مع العميل',
      children: [
        if (phone != null && phone.isNotEmpty)
          _row(
            'رقم الهاتف',
            phone,
            trailing: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: phone));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('تم نسخ الرقم')));
              },
              child: const Icon(
                Icons.copy_rounded,
                size: 18,
                color: Colors.black54,
              ),
            ),
          )
        else
          const Text(
            'يظهر رقم العميل بعد قبول الطلب.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        _hint('التنسيق حول الاستلام يتم مباشرة بينك وبين العميل'),
      ],
    );
  }

  Widget _amountsCard(Map<String, dynamic> b) {
    final pricing = (b['pricing'] as Map?) ?? const {};
    final currency = pricing['currency'];
    return _card(
      title: 'المبلغ',
      children: [
        _row('الإجمالي', formatOrderAmount(pricing['total'], currency)),
        _row('العربون', formatOrderAmount(pricing['deposit'], currency)),
        _row('المتبقي', formatOrderAmount(pricing['remaining'], currency)),
        if (b['status'] == 'payment_awaiting')
          _hint(
            b['payment_due_at'] != null
                ? 'بانتظار رفع العميل لإثبات دفع العربون قبل ${_dateTime(b['payment_due_at'])}.'
                : 'بانتظار رفع العميل لإثبات دفع العربون.',
          ),
      ],
    );
  }

  List<Widget> _paymentsSection(
    Map<String, dynamic> b,
    ProviderOrderDetailsState state,
    Color primary,
  ) {
    final payments = ((b['payments'] as List?) ?? const [])
        .whereType<Map>()
        .toList();
    if (payments.isEmpty) return const [];
    const statusLabels = {
      'submitted': 'بانتظار مراجعتك',
      'confirmed': 'معتمد',
      'rejected': 'مرفوض',
    };
    return [
      _card(
        title: 'إثباتات الدفع',
        children: [
          for (final p in payments) ...[
            _row(
              formatOrderAmount(
                p['amount'],
                (b['pricing'] as Map?)?['currency'],
              ),
              statusLabels[p['status']] ?? p['status'].toString(),
            ),
            if ((p['customer_note']?.toString() ?? '').isNotEmpty)
              _row('ملاحظة العميل', p['customer_note'].toString()),
            if ((p['review_note']?.toString() ?? '').isNotEmpty)
              _row('سبب الرفض', p['review_note'].toString()),
            if (p['status'] == 'submitted' &&
                b['status'] == 'review_under_proof')
              _proofReview(Map<String, dynamic>.from(p), state, primary),
            const Divider(color: Color(0xFFEDE6E8)),
          ],
        ],
      ),
    ];
  }

  Widget _proofReview(
    Map<String, dynamic> payment,
    ProviderOrderDetailsState state,
    Color primary,
  ) {
    final id = int.parse(payment['id'].toString());
    final bytes = state.proofs[id];
    final isPdf = payment['proof_type'] == 'pdf';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (bytes != null && !isPdf)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              child: Image.memory(bytes, height: 260, fit: BoxFit.contain),
            ),
          )
        else if (bytes != null)
          const Text(
            'الإثبات ملف PDF، راجعه مع العميل عند الحاجة.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          )
        else
          OutlinedButton.icon(
            onPressed: () =>
                context.read<ProviderOrderDetailsCubit>().loadProof(id),
            icon: Icon(Icons.receipt_long_outlined, color: primary),
            label: Text('عرض إثبات الدفع', style: TextStyle(color: primary)),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: state.acting
                    ? null
                    : () => context
                          .read<ProviderOrderDetailsCubit>()
                          .reviewPayment(id, 'confirmed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('اعتماد الدفع'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: state.acting
                    ? null
                    : () async {
                        final note = await _askNote(
                          'رفض إثبات الدفع',
                          'سبب الرفض (يظهر للعميل)',
                        );
                        if (note != null && mounted) {
                          context
                              .read<ProviderOrderDetailsCubit>()
                              .reviewPayment(id, 'rejected', note: note);
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _red,
                  side: const BorderSide(color: _red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('رفض'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _actions(
    Map<String, dynamic> b,
    ProviderOrderDetailsState state,
    Color primary,
  ) {
    final status = b['status'];
    if (status == 'provider_pending') {
      return [
        ProviderPrimaryButton(
          label: 'قبول الطلب',
          loading: state.acting,
          onPressed: () => _showAcceptSheet(b, state),
        ),
        TextButton(
          onPressed: state.acting
              ? null
              : () async {
                  final note = await _askNote(
                    'رفض الطلب',
                    'سبب الرفض (اختياري، يظهر للعميل)',
                    required: false,
                  );
                  if (note != null && mounted) {
                    context.read<ProviderOrderDetailsCubit>().reject(note);
                  }
                },
          child: const Text('رفض الطلب', style: TextStyle(color: _red)),
        ),
      ];
    }
    final date = DateTime.tryParse(b['date']?.toString() ?? '');
    final today = DateTime.now();
    final due =
        date != null &&
        !DateTime(
          date.year,
          date.month,
          date.day,
        ).isAfter(DateTime(today.year, today.month, today.day));
    if (status == 'confirmed' && due) {
      return [
        ProviderPrimaryButton(
          label: 'تم تنفيذ الطلب',
          loading: state.acting,
          onPressed: () => context.read<ProviderOrderDetailsCubit>().complete(),
        ),
      ];
    }
    return const [];
  }

  // ---- Helpers ---------------------------------------------------------------

  Widget _hint(String text) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kProviderNoteFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFEFE7EA),
    child: const Icon(Icons.image_outlined, color: Colors.black26),
  );

  static String _dateTime(dynamic iso) {
    final d = DateTime.tryParse(iso?.toString() ?? '')?.toLocal();
    if (d == null) return '';
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '${formatArabicDate(d)} $h:$m${d.hour < 12 ? 'ص' : 'م'}';
  }

  Future<String?> _askNote(String title, String hint, {bool required = true}) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (required && text.isEmpty) return;
              Navigator.pop(dialog, text);
            },
            child: const Text('تأكيد', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAcceptSheet(
    Map<String, dynamic> b,
    ProviderOrderDetailsState state,
  ) async {
    final pricing = (b['pricing'] as Map?) ?? const {};
    final total = (pricing['total'] as num?)?.toDouble() ?? 0;
    final deposit = TextEditingController(
      text: formatOrderAmount(pricing['deposit'], ''),
    );
    final instructions = TextEditingController(
      text: state.paymentInstructions ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(sheet).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'قبول الطلب',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: deposit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'قيمة العربون',
                  suffixText: pricing['currency']?.toString(),
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null) return 'أدخل قيمة العربون';
                  return n > total
                      ? 'العربون لا يمكن أن يتجاوز الإجمالي'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: instructions,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'تعليمات التحويل للعميل',
                  hintText: 'مكان التحويل ورقم الحساب واسم المستفيد',
                ),
                validator: (v) => (v ?? '').trim().length < 10
                    ? 'اكتب تعليمات التحويل (10 أحرف على الأقل)'
                    : null,
              ),
              const SizedBox(height: 16),
              ProviderPrimaryButton(
                label: 'تأكيد القبول',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(sheet, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

    if (accepted == true && mounted) {
      context.read<ProviderOrderDetailsCubit>().accept(
        deposit: double.parse(deposit.text.trim()),
        instructions: instructions.text,
      );
    }
  }
}
