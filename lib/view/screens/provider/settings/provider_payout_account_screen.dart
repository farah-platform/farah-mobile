import 'package:farah/cubits/provider_settings/provider_store_settings_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kProviderNoteFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primary),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'يظهر هذا الحساب لك عند مراجعة دفعات العملاء، وتحوّل المنصة مستحقاتك عليه.',
                            style: TextStyle(fontSize: 12, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _field(
                    'مكان التحويل',
                    _bankController,
                    'مثال: بنك فلسطين أو محفظة جوال باي',
                    required: true,
                  ),
                  _field(
                    'رقم الحساب',
                    _accountController,
                    'رقم الحساب أو المحفظة',
                    required: true,
                    ltr: true,
                  ),
                  _field(
                    'الايبان (اختياري)',
                    _ibanController,
                    'PS00...',
                    ltr: true,
                  ),
                  const SizedBox(height: 28),
                  ProviderPrimaryButton(
                    label: 'حفظ',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String hint, {
    bool required = false,
    bool ltr = false,
  }) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        TextFormField(
          controller: controller,
          textDirection: ltr ? TextDirection.ltr : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: border(const Color(0xFFDADADA)),
            border: border(const Color(0xFFDADADA)),
          ),
          validator: required
              ? (v) => (v ?? '').trim().isEmpty ? 'هذا الحقل مطلوب' : null
              : null,
        ),
      ],
    );
  }
}
