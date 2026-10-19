import 'package:farah/cubits/provider_settings/provider_store_settings_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/settings/provider_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "حساب استلام الارباح": where customers transfer deposits and the
/// platform sends the provider's earnings.
class ProviderPayoutAccountScreen extends StatefulWidget {
  const ProviderPayoutAccountScreen({super.key});

  @override
  State<ProviderPayoutAccountScreen> createState() =>
      _ProviderPayoutAccountScreenState();
}

class _ProviderPayoutAccountScreenState
    extends State<ProviderPayoutAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankController = TextEditingController();
  final _accountController = TextEditingController();
  final _ibanController = TextEditingController();
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderStoreSettingsCubit>().load();
  }

  @override
  void dispose() {
    _bankController.dispose();
    _accountController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'حساب استلام الارباح'),
      body: BlocConsumer<ProviderStoreSettingsCubit, ProviderStoreSettingsState>(
        listener: (context, state) {
          if (state.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ حساب استلام الأرباح')),
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
          if (!_filled) {
            _filled = true;
            _bankController.text =
                state.payoutAccount['bank_name']?.toString() ?? '';
            _accountController.text =
                state.payoutAccount['account_number']?.toString() ?? '';
            _ibanController.text =
                state.payoutAccount['iban']?.toString() ?? '';
          }
          // فرح: حسب تصميم "حساب استلام الارباح": ملاحظة التحويل ثم البنك ورقم الحساب والايبان.
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 12, 32, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6EFF1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: primary),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'سيتم التحويل من حجوزات عملائك على هذا الحساب',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _field(
                          'اسم البنك',
                          _bankController,
                          'مثال: بنك فلسطين أو محفظة جوال باي',
                          required: true,
                        ),
                        _field(
                          'رقم الحساب',
                          _accountController,
                          'رقم الحساب أو المحفظة',
                          labelColor: primary,
                          required: true,
                        ),
                        _field(
                          'الايبان',
                          _ibanController,
                          'اختياري',
                          labelColor: primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ProviderBottomAction(
                child: ProviderPrimaryButton(
                  label: 'حفظ التغيرات',
                  loading: state.saving,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    context.read<ProviderStoreSettingsCubit>().savePayout(
                      bankName: _bankController.text.trim(),
                      accountNumber: _accountController.text.trim(),
                      iban: _ibanController.text.trim(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    Color? labelColor,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProviderFieldLabel(label, color: labelColor),
        TextFormField(
          controller: controller,
          decoration: providerFieldDecoration(hint: hint),
          validator: required
              ? (v) => (v ?? '').trim().isEmpty ? 'هذا الحقل مطلوب' : null
              : null,
        ),
      ],
    );
  }
}
