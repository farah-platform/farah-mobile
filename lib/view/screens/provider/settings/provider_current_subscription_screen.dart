import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_subscription/provider_current_subscription_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/settings/provider_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// فرح: شاشة "الاشتراك الحالي": اسم الباقة وحالتها والأيام المتبقية ومزاياها من السيرفر،
// مع "ترقية الباقة" (شاشة الباقات) و"الغاء الاشتراك" (POST /provider/subscription/cancel).
class ProviderCurrentSubscriptionScreen extends StatefulWidget {
  const ProviderCurrentSubscriptionScreen({super.key});

  @override
  State<ProviderCurrentSubscriptionScreen> createState() =>
      _ProviderCurrentSubscriptionScreenState();
}

class _ProviderCurrentSubscriptionScreenState
    extends State<ProviderCurrentSubscriptionScreen> {
  static const _titleColor = Color(0xFF4A0E25);
  static const _green = Color(0xFF2E7D3A);

  @override
  void initState() {
    super.initState();
    context.read<ProviderCurrentSubscriptionCubit>().load();
  }

  Future<void> _upgrade() async {
    final cubit = context.read<ProviderCurrentSubscriptionCubit>();
    await Navigator.pushNamed(context, AppRoutes.providerSubscriptionPlans);
    if (mounted) cubit.load();
  }

  Future<void> _confirmCancel() async {
    final cubit = context.read<ProviderCurrentSubscriptionCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('الغاء الاشتراك'),
        content: const Text(
          'سيتوقف استقبال الحجوزات وظهور خدماتك للعملاء. هل تريد إلغاء الاشتراك؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text(
              'الغاء الاشتراك',
              style: TextStyle(color: Color(0xFFD9473F)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) cubit.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'الاشتراك الحالي'),
      body:
          BlocConsumer<
            ProviderCurrentSubscriptionCubit,
            ProviderCurrentSubscriptionState
          >(
            listener: (context, state) {
              final text = state.error ?? state.message;
              if (text != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(text)));
              }
            },
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final subscription = state.subscription;
              if (subscription == null) return _empty();
              return _content(subscription, state.canceling);
            },
          ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.workspace_premium_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 14),
          const Text(
            'لا يوجد اشتراك حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ProviderPrimaryButton(label: 'اختيار باقة', onPressed: _upgrade),
        ],
      ),
    );
  }

  Widget _content(Map<String, dynamic> subscription, bool canceling) {
    final primary = Theme.of(context).colorScheme.primary;
    final plan = (subscription['plan'] as Map?) ?? const {};
    final features = [
      for (final f in (plan['features'] as List?) ?? const [])
        if (f is Map && (f['name']?.toString() ?? '').isNotEmpty) f,
    ];
    final active = subscription['is_active'] == true;
    final start = DateTime.tryParse(
      subscription['current_period_start']?.toString() ?? '',
    );
    final end = DateTime.tryParse(
      subscription['current_period_end']?.toString() ?? '',
    );
    final now = DateTime.now();
    final daysLeft = active && end != null
        ? (end.difference(now).inHours / 24).ceil().clamp(0, 9999)
        : 0;
    final totalDays = start != null && end != null
        ? end.difference(start).inDays
        : 0;
    final progress = totalDays > 0
        ? (daysLeft / totalDays).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan['name']?.toString() ?? '',
                            style: const TextStyle(
                              color: _titleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        _statusChip(subscription['status']?.toString(), active),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // RTL: the bar fills from the start (right), like the design.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        color: primary,
                        backgroundColor: const Color(0xFFF8E5EA),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      active
                          ? 'متبقي $daysLeft يوم لإنهاء الاشتراك'
                          : 'الاشتراك غير فعّال حالياً',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (features.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 28, bottom: 14),
                  child: Text(
                    'تفاصيل الباقة',
                    style: TextStyle(
                      color: _titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      for (var i = 0; i < features.length; i++) ...[
                        if (i > 0)
                          const Divider(height: 1, color: Color(0xFFDDDDDD)),
                        _featureRow(
                          features[i]['name'].toString(),
                          features[i]['included'] != false,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        ProviderBottomAction(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProviderPrimaryButton(label: 'ترقية الباقة', onPressed: _upgrade),
              if (active)
                TextButton(
                  onPressed: canceling ? null : _confirmCancel,
                  child: canceling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'الغاء الاشتراك',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFEAEAEA)),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  Widget _statusChip(String? status, bool active) {
    final (label, color) = active
        ? ('الاشتراك نشط', _green)
        : status == 'canceled'
        ? ('الاشتراك ملغي', const Color(0xFFD9473F))
        : ('الاشتراك منتهي', Colors.black54);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(String name, bool included) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: included
                  ? const Color(0xFFDDF3E2)
                  : const Color(0xFFEEEEEE),
              border: Border.all(
                color: included ? const Color(0xFF3DBE62) : Colors.black26,
              ),
            ),
            child: Icon(
              included ? Icons.check : Icons.close,
              size: 15,
              color: included ? const Color(0xFF2E9E4F) : Colors.black38,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: included ? Colors.black87 : Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
