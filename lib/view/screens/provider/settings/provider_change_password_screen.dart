import 'package:farah/cubits/change_password/change_password_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/settings/provider_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// فرح: "تغيير كلمة المرور" للمزود حسب التصميم. يستخدم ChangePasswordCubit (POST /change-password).
class ProviderChangePasswordScreen extends StatefulWidget {
  const ProviderChangePasswordScreen({super.key});

  @override
  State<ProviderChangePasswordScreen> createState() =>
      _ProviderChangePasswordScreenState();
}

class _ProviderChangePasswordScreenState
    extends State<ProviderChangePasswordScreen> {
  static const _iconColor = Color(0xFF8A6B76);

  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  final _visible = <int>{};
  String? _currentError;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _currentError = null);
    if (!_formKey.currentState!.validate()) return;
    context.read<ChangePasswordCubit>().change(
      currentPassword: _current.text,
      newPassword: _new.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'تغيير كلمة المرور'),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
            );
            Navigator.pop(context, true);
          } else if (state is ChangePasswordCurrentPasswordWrong) {
            setState(() => _currentError = 'كلمة المرور الحالية غير صحيحة');
          } else if (state is ChangePasswordError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 70, 28, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _field(
                          0,
                          'كلمة المرور الحالية',
                          _current,
                          errorText: _currentError,
                          validator: (v) => (v ?? '').isEmpty
                              ? 'أدخل كلمة المرور الحالية'
                              : null,
                        ),
                        _field(
                          1,
                          'كلمة المرور الجديدة',
                          _new,
                          validator: (v) {
                            if ((v ?? '').length < 8) {
                              return 'كلمة المرور الجديدة يجب أن تتكون من 8 أحرف على الأقل';
                            }
                            if (v == _current.text) {
                              return 'اختر كلمة مرور مختلفة عن الحالية';
                            }
                            return null;
                          },
                        ),
                        _field(
                          2,
                          'تأكيد  كلمة المرور',
                          _confirm,
                          validator: (v) => v != _new.text
                              ? 'تأكيد كلمة المرور غير مطابق'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ProviderBottomAction(
                child: ProviderPrimaryButton(
                  label: 'حفظ التغيرات',
                  loading: state is ChangePasswordLoading,
                  onPressed: _save,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field(
    int index,
    String label,
    TextEditingController controller, {
    String? errorText,
    FormFieldValidator<String>? validator,
  }) {
    final visible = _visible.contains(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProviderFieldLabel(label, bold: false),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: providerFieldDecoration(
            hint: '••••••••',
            borderColor: kProviderOutlinedFieldBorder,
            errorText: errorText,
            prefixIcon: const Icon(Icons.lock_outline, color: _iconColor),
            suffixIcon: IconButton(
              tooltip: visible ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
              icon: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _iconColor,
              ),
              onPressed: () => setState(
                () => visible ? _visible.remove(index) : _visible.add(index),
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
