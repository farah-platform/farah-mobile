import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// فرح: شاشة "حذف الحساب" حسب التصميم (بدل نافذة التأكيد القديمة). تستدعي DELETE /account.
class ProviderDeleteAccountScreen extends StatelessWidget {
  const ProviderDeleteAccountScreen({super.key});

  Future<void> _delete(BuildContext context) async {
    final auth = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    // Leave the provider screens before the auth state changes under them.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    await auth.deleteAccount();
    final state = auth.state;
    messenger.showSnackBar(
      SnackBar(
        content: Text(state is AuthError ? state.message : 'تم حذف الحساب'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'حذف الحساب'),
      body: Center(
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
                const SizedBox(height: 40),
                ProviderPrimaryButton(
                  label: 'تأكيد الحذف',
                  onPressed: () => _delete(context),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.maybePop(context),
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
    );
  }
}
