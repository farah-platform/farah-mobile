import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends State<ProviderVerificationScreen> {
  // Set when "التالي" asks for a fresh status, so only that check navigates.
  bool _continuing = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderVerificationCubit>().checkStatus();
  }

  void _next() {
    setState(() => _continuing = true);
    context.read<ProviderVerificationCubit>().checkStatus();
  }

  void _onStatus(BuildContext context, ProviderVerificationState state) {
    if (!_continuing) return;
    if (state is ProviderVerificationError) {
      setState(() => _continuing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      return;
    }
    if (state is! ProviderVerificationLoaded) return;
    setState(() => _continuing = false);

    if (state.status == 'approved' || state.status == 'active') {
      Navigator.pushNamed(context, AppRoutes.providerSubscriptionPlans);
    } else if (state.nextStep == 'onboarding') {
      Navigator.pushReplacementNamed(context, AppRoutes.providerOnboarding);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حسابك قيد المراجعة، وسنُعلمك فور اعتماده.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'معلومات الخدمة'),
      body: BlocConsumer<ProviderVerificationCubit, ProviderVerificationState>(
        listener: _onStatus,
        builder: (context, state) {
          final loading =
              state is ProviderVerificationLoading ||
              state is ProviderVerificationInitial;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ProviderStepHeader(
                    step: 'الخطوة الثانية : توثيق الحساب',
                    progress: 2 / 3,
                    subtitle:
                        'توثيق بياناتك يعزز مصداقية متجرك ويمنح العرسان ثقة كاملة لحجز خدماتك بأمان.',
                  ),
                  const SizedBox(height: 24),
                  if (loading && !_continuing)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    _statusCard(state, theme, primary),
                  const Spacer(),
                  ProviderPrimaryButton(
                    label: 'التالي',
                    loading: loading && _continuing,
                    onPressed: _next,
                  ),
                  const SizedBox(height: 14),
                  const ProviderLoginLink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusCard(
    ProviderVerificationState state,
    ThemeData theme,
    Color primary,
  ) {
    var badge = '';
    var message = '';
    String? reason;
    if (state is ProviderVerificationLoaded) {
      badge = state.title;
      message = state.message;
      reason = state.decisionReason;
    } else if (state is ProviderVerificationError) {
      message = state.message;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kProviderCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'حالة التدقيق الحالية',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: kProviderNoteFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE9C9B5)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
              height: 1.6,
            ),
          ),
          if (reason != null && reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ملاحظة المنصة: $reason',
              style: theme.textTheme.bodySmall?.copyWith(color: primary),
            ),
          ],
        ],
      ),
    );
  }
}
