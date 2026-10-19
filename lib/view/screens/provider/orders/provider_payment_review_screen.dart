import 'package:farah/cubits/provider_orders/provider_order_details_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/orders/provider_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "مراجعة الدفع": the customer's deposit proof for one booking, with the
/// provider's transfer details, to accept or reject.
class ProviderPaymentReviewScreen extends StatefulWidget {
  const ProviderPaymentReviewScreen({super.key});

  @override
  State<ProviderPaymentReviewScreen> createState() =>
      _ProviderPaymentReviewScreenState();
}

class _ProviderPaymentReviewScreenState
    extends State<ProviderPaymentReviewScreen> {
  static const _red = Color(0xFFD9473F);
  bool _proofRequested = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderOrderDetailsCubit>().load();
  }

  Map<String, dynamic>? _pendingPayment(Map<String, dynamic> booking) {
    if (booking['status'] != 'review_under_proof') return null;
    for (final p in (booking['payments'] as List?) ?? const []) {
      if (p is Map && p['status'] == 'submitted') {
        return Map<String, dynamic>.from(p);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'مراجعة الدفع'),
      body: BlocConsumer<ProviderOrderDetailsCubit, ProviderOrderDetailsState>(
        listener: (context, state) {
          final booking = state.booking;
          final payment = booking == null ? null : _pendingPayment(booking);
          if (payment != null && !_proofRequested) {
            _proofRequested = true;
            context.read<ProviderOrderDetailsCubit>().loadProof(
              int.parse(payment['id'].toString()),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          final booking = state.booking;
          if (booking == null) {
            return state.loading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: TextButton(
                      onPressed: () =>
                          context.read<ProviderOrderDetailsCubit>().load(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  );
          }
          final payment = _pendingPayment(booking);
          if (payment == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'لا يوجد إشعار دفع بانتظار المراجعة لهذا الحجز.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            );
          }
          final paymentId = int.parse(payment['id'].toString());
          final expiresAt = DateTime.tryParse(
            booking['expires_at']?.toString() ?? '',
          );
          final overdue =
              expiresAt != null && expiresAt.isBefore(DateTime.now());
          final account = state.payoutAccount;
          final currency = (booking['pricing'] as Map?)?['currency'];

          return ListView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
            children: [
              if (overdue)
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEAEA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _red.withValues(alpha: 0.6)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'انتهت مهلة المراجعة(24 ساعة)',
                        style: TextStyle(
                          color: _red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'يرجى المراجعة في اقرب وقت لتفادي تأثر تقييم متجرك',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              const Text(
                'بيانات التحويل',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1E7EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row(
                      'اسم العميل',
                      (booking['customer'] as Map?)?['name']?.toString(),
                      primary,
                    ),
                    _row(
                      'الخدمة',
                      (booking['service'] as Map?)?['title']?.toString(),
                      primary,
                    ),
                    _row(
                      'المبلغ المستحق',
                      formatOrderAmount(payment['amount'], currency),
                      primary,
                      ltr: true,
                    ),
                    _row(
                      'مكان التحويل',
                      account['bank_name']?.toString(),
                      primary,
                    ),
                    _row(
                      'رقم الحساب',
                      account['account_number']?.toString(),
                      primary,
                      ltr: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 12),
                      child: Text('الايبان', style: _labelStyle(primary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF1E7EA)),
                      ),
                      child: Text(
                        _orDash(account['iban']?.toString()),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CustomPaint(
                painter: DashedBorderPainter(
                  color: primary.withValues(alpha: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _proof(state, paymentId, payment),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: state.acting
                            ? null
                            : () => context
                                  .read<ProviderOrderDetailsCubit>()
                                  .reviewPayment(paymentId, 'confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: state.acting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'قبول الاشعار',
                                style: TextStyle(fontSize: 17),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: state.acting
                            ? null
                            : () async {
                                final reason = await showDialog<String>(
                                  context: context,
                                  builder: (_) => const RejectReasonDialog(),
                                );
                                if (reason != null && context.mounted) {
                                  context
                                      .read<ProviderOrderDetailsCubit>()
                                      .reviewPayment(
                                        paymentId,
                                        'rejected',
                                        note: reason,
                                      );
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(color: Color(0xFFEDE6E8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'رفض',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _proof(
    ProviderOrderDetailsState state,
    int paymentId,
    Map<String, dynamic> payment,
  ) {
    final bytes = state.proofs[paymentId];
    if (bytes == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (payment['proof_type'] == 'pdf') {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            'الإشعار ملف PDF، راجعه مع العميل عند الحاجة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain));
  }

  static String _orDash(String? v) => v == null || v.trim().isEmpty ? '—' : v;

  TextStyle _labelStyle(Color primary) =>
      TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 17);

  Widget _row(String label, String? value, Color primary, {bool ltr = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEDE6E8))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: _labelStyle(primary))),
          Text(
            _orDash(value),
            textDirection: ltr ? TextDirection.ltr : null,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// "سبب الرفض" dialog; returns the reason the customer will see.
class RejectReasonDialog extends StatefulWidget {
  const RejectReasonDialog({super.key});

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD9473F);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'سبب الرفض',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'سيظهر السبب للعميل لمساعدته على المحاولة مجددا',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'مثال الصورة غير واضحة',
                hintStyle: const TextStyle(fontSize: 11, color: Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _controller.text.trim().isEmpty
                          ? null
                          : () =>
                                Navigator.pop(context, _controller.text.trim()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الرفض',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFE6E6E6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
