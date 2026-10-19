import 'dart:io';

import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProviderActivateSubscriptionScreen extends StatefulWidget {
  /// The paid plan picked on the plans screen.
  final Map<String, dynamic> plan;
  const ProviderActivateSubscriptionScreen({super.key, required this.plan});

  @override
  State<ProviderActivateSubscriptionScreen> createState() =>
      _ProviderActivateSubscriptionScreenState();
}

class _ProviderActivateSubscriptionScreenState
    extends State<ProviderActivateSubscriptionScreen> {
  static const _ibanBorder = Color(0xFFE2D6C5);

  Map<String, dynamic>? _bank;
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
    context.read<ProviderSubscriptionCubit>().fetchBankDetails();
  }

  bool get _hasBank =>
      _bank != null &&
      ['bank_name', 'account_number', 'iban'].any(
        (k) => (_bank![k] ?? '').toString().trim().isNotEmpty,
      );

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _receiptImage = File(picked.path));
    }
  }

  void _submit() {
    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء رفع إشعار التحويل البنكي')),
      );
      return;
    }
    context.read<ProviderSubscriptionCubit>().activateSubscription(
      planSlug: widget.plan['slug'].toString(),
      proof: _receiptImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'تفعيل الاشتراك'),
      body: BlocConsumer<ProviderSubscriptionCubit, ProviderSubscriptionState>(
        listener: (context, state) {
          if (state is ProviderSubscriptionBankLoaded) {
            setState(() => _bank = state.bank);
          } else if (state is ProviderSubscriptionSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.providerSubscriptionSuccess,
              (route) => false,
              arguments: state.pendingReview,
            );
          } else if (state is ProviderSubscriptionError && _bank != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProviderSubscriptionLoading ||
              state is ProviderSubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProviderSubscriptionError && _bank == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () => context
                        .read<ProviderSubscriptionCubit>()
                        .fetchBankDetails(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'بيانات التحويل البنكي المعتمد',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _infoNote(theme, primary),
                const SizedBox(height: 10),
                _bankCard(theme, primary),
                const SizedBox(height: 14),
                _receiptCard(theme, primary),
                const SizedBox(height: 24),
                ProviderPrimaryButton(
                  label: 'تأكيد',
                  loading: state is ProviderSubscriptionActivating,
                  onPressed: _hasBank ? _submit : null,
                ),
                const SizedBox(height: 10),
                Center(
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.terms),
                    child: Text(
                      'بالنقر على التفعيل، فإنك توافق على الشروط والاحكام',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoNote(ThemeData theme, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kProviderNoteFill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'لا توجد بوابة دفع إلكتروني فورية. يتم سداد الاشتراكات عبر المحافظ الالكترونية أو التحويل البنكي.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.info_outline, color: primary, size: 20),
        ],
      ),
    );
  }

  Widget _bankCard(ThemeData theme, Color primary) {
    final labelStyle = TextStyle(
      color: primary,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    );
    const valueStyle = TextStyle(color: Colors.black87, fontSize: 11);

    if (!_hasBank) {
      return _whiteCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'هذه الميزة غير متاحة حالياً',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ),
      );
    }

    String value(String key) => (_bank![key] ?? '').toString();

    Widget row(String label, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(text, textDirection: TextDirection.ltr, style: valueStyle),
        ],
      ),
    );

    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row('مكان التحويل', value('bank_name')),
          const Divider(height: 1, color: Color(0xFFF1E7EA)),
          row('رقم الحساب', value('account_number')),
          const Divider(height: 1, color: Color(0xFFF1E7EA)),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 10),
            child: Text('الايبان', style: labelStyle),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ibanBorder),
            ),
            child: SelectableText(
              value('iban'),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptCard(ThemeData theme, Color primary) {
    return _whiteCard(
      border: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'اشعار رفع التحويل',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Icon(Icons.show_chart, color: primary),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1E7EA)),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: primary.withValues(alpha: 0.6),
                ),
                child: SizedBox(
                  height: 150,
                  child: _receiptImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_receiptImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, color: primary),
                            const SizedBox(height: 10),
                            Text(
                              'رفع إشعار التحويل البنكي',
                              style: TextStyle(
                                color: primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child, bool border = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: border ? Border.all(color: kProviderCardBorder) : null,
      ),
      child: child,
    );
  }
}
