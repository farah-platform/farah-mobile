import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderSubscriptionPlansScreen extends StatefulWidget {
  const ProviderSubscriptionPlansScreen({super.key});

  @override
  State<ProviderSubscriptionPlansScreen> createState() =>
      _ProviderSubscriptionPlansScreenState();
}

class _ProviderSubscriptionPlansScreenState
    extends State<ProviderSubscriptionPlansScreen> {
  static const _priceFill = Color(0xFFF6ECE6);
  static const _priceBorder = Color(0xFFE2C9B8);

  List<dynamic> _plans = [];
  String? _selectedSlug;
  // "شهري" / "سنوي" toggle; picks the paid plan with this interval.
  String _interval = 'month';

  @override
  void initState() {
    super.initState();
    context.read<ProviderSubscriptionCubit>().fetchPlans();
  }

  bool _isFree(dynamic plan) =>
      (num.tryParse(plan['price']?.toString() ?? '') ?? 0) == 0;

  Map<String, dynamic>? get _selectedPlan {
    for (final plan in _plans) {
      if (plan['slug']?.toString() == _selectedSlug) {
        return Map<String, dynamic>.from(plan);
      }
    }
    return null;
  }

  void _selectInterval(String interval) {
    final match = _plans.where(
      (p) => !_isFree(p) && p['interval'] == interval,
    );
    setState(() {
      _interval = interval;
      if (match.isNotEmpty) _selectedSlug = match.first['slug']?.toString();
    });
  }

  void _onPlansLoaded(List<dynamic> plans) {
    _plans = plans;
    if (_selectedSlug != null || plans.isEmpty) return;
    final paid = plans.where((p) => !_isFree(p) && p['interval'] == _interval);
    _selectedSlug = (paid.isNotEmpty ? paid.first : plans.first)['slug']
        ?.toString();
  }

  void _activate() {
    final plan = _selectedPlan;
    if (plan == null) return;
    if (_isFree(plan)) {
      context.read<ProviderSubscriptionCubit>().activateSubscription(
        planSlug: plan['slug'].toString(),
      );
    } else {
      Navigator.pushNamed(
        context,
        AppRoutes.providerActivateSubscription,
        arguments: plan,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'الاشتراك'),
      body: BlocConsumer<ProviderSubscriptionCubit, ProviderSubscriptionState>(
        listener: (context, state) {
          if (state is ProviderSubscriptionPlansLoaded) {
            setState(() => _onPlansLoaded(state.plans));
          } else if (state is ProviderSubscriptionSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.providerSubscriptionSuccess,
              (route) => false,
            );
          } else if (state is ProviderSubscriptionError && _plans.isNotEmpty) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final Widget content;
          if (state is ProviderSubscriptionLoading ||
              state is ProviderSubscriptionInitial) {
            content = const Center(child: CircularProgressIndicator());
          } else if (state is ProviderSubscriptionError && _plans.isEmpty) {
            content = _message(
              state.message,
              onRetry: () =>
                  context.read<ProviderSubscriptionCubit>().fetchPlans(),
            );
          } else if (_plans.isEmpty) {
            content = _message('لا توجد باقات اشتراك متاحة حالياً');
          } else {
            content = ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final plan in _plans)
                  _planCard(Map<String, dynamic>.from(plan), theme, primary),
              ],
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProviderStepHeader(
                    step: 'الخطوة الثالثة : تفعيل الاشتراك',
                    progress: 1,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'اختر الخطة المناسبة لنشاطك',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _intervalChip('شهري', 'month', primary),
                      const SizedBox(width: 18),
                      _intervalChip('سنوي', 'year', primary),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: content),
                  const SizedBox(height: 12),
                  ProviderPrimaryButton(
                    label: 'تفعيل الاشتراك',
                    loading: state is ProviderSubscriptionActivating,
                    onPressed: _selectedPlan == null ? null : _activate,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _message(String text, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  Widget _intervalChip(String label, String interval, Color primary) {
    final selected = _interval == interval;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _selectInterval(interval),
      child: Container(
        width: 82,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _planCard(Map<String, dynamic> plan, ThemeData theme, Color primary) {
    final slug = plan['slug']?.toString();
    final selected = slug == _selectedSlug;
    final gold = theme.colorScheme.secondary;
    final features = (plan['features'] as List?) ?? const [];

    return GestureDetector(
      onTap: () => setState(() => _selectedSlug = slug),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? (plan['interval'] == 'year' ? gold : primary).withValues(
                    alpha: 0.6,
                  )
                : const Color(0xFFF1E7EA),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan['name']?.toString() ?? '',
                        style: TextStyle(
                          color: primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if ((plan['description'] ?? '').toString().isNotEmpty)
                        Text(
                          plan['description'].toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (selected && !_isFree(plan))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _priceFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _priceBorder),
                    ),
                    child: Text(
                      '${_formatPrice(plan['price'])} ${plan['currency'] ?? ''}',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (!selected)
                  Icon(Icons.keyboard_arrow_down, color: primary, size: 28),
              ],
            ),
            if (selected && features.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final feature in features)
                _featureRow(
                  feature['name']?.toString() ?? '',
                  feature['included'] == true,
                  primary,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _featureRow(String name, bool included, Color primary) {
    final color = included ? Colors.black87 : Colors.black26;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 13,
            color: included ? primary : Colors.black26,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(dynamic price) {
    final value = num.tryParse(price?.toString() ?? '') ?? 0;
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
