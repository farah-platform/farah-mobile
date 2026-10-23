import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/cubits/delete_account/delete_account_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/settings/provider_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// فرح: شاشة "حذف الحساب" حسب التصميم (بدل نافذة التأكيد القديمة). تستدعي DELETE /account
// مع كلمة المرور الحالية، لأن السيرفر بيرفض الحذف بدونها.
class ProviderDeleteAccountScreen extends StatefulWidget {
  const ProviderDeleteAccountScreen({super.key});

  @override
  State<ProviderDeleteAccountScreen> createState() =>
      _ProviderDeleteAccountScreenState();
}

class _ProviderDeleteAccountScreenState
    extends State<ProviderDeleteAccountScreen> {
  final _password = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'حذف الحساب'),
      body: BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
        listener: (context, state) {
          if (state.deleted) {
            final auth = context.read<AuthCubit>();
            final messenger = ScaffoldMessenger.of(context);
            // Leave the provider screens before the auth state changes under them.
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
            auth.accountDeleted();
            messenger.showSnackBar(
              const SnackBar(content: Text('تم حذف الحساب')),
            );
          }
        },
        builder: (context, state) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(26, 26, 26, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDDDDDD)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3E9EC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'هل أنت متأكد ؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'سيؤدي حذف حسابك إلى مسح جميع بياناتك، سجل نشاطك، وإعداداتك بشكل دائم، لا يمكن التراجع عن هذا الإجراء !',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _password,
                    obscureText: !_visible,
                    decoration: providerFieldDecoration(
                      hint: 'كلمة المرور الحالية',
                      borderColor: kProviderOutlinedFieldBorder,
                      errorText: state.error,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF8A6B76),
                      ),
                      suffixIcon: IconButton(
                        tooltip: _visible
                            ? 'إخفاء كلمة المرور'
                            : 'إظهار كلمة المرور',
                        icon: Icon(
                          _visible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF8A6B76),
                        ),
                        onPressed: () => setState(() => _visible = !_visible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ProviderPrimaryButton(
                    label: 'تأكيد الحذف',
                    loading: state.loading,
                    onPressed: () => context.read<DeleteAccountCubit>().delete(
                      _password.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: state.loading
                          ? null
                          : () => Navigator.maybePop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: primary.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
