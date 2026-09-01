import 'dart:async';

import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/view/screens/auth/login.dart';
import 'package:farah/view/screens/auth/terms_and_conditions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedRegion;
  String selectedCountryCode = '+970';
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool _showWaitHint = false;
  Timer? _waitHintTimer;

  void _startWaitHintTimer() {
    _waitHintTimer?.cancel();
    _waitHintTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showWaitHint = true);
    });
  }

  void _cancelWaitHintTimer() {
    _waitHintTimer?.cancel();
    _waitHintTimer = null;
    if (mounted) setState(() => _showWaitHint = false);
  }

  @override
  void dispose() {
    _waitHintTimer?.cancel();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState!.validate()) {
      // cityId is null until the screen is rebuilt with a real city picker
      // in Part B. The region dropdown is kept for UX but value is not sent.
      context.read<AuthCubit>().signUp(
        name: nameController.text.trim(),
        email: emailController.text,
        phone: '$selectedCountryCode${phoneController.text.trim()}',
        password: passwordController.text,
        cityId: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          _startWaitHintTimer();
        } else {
          _cancelWaitHintTimer();
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is AuthSignUpTimeout) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 8),
                content: Text(
                  'تم إرسال الطلب. تحقق من بريدك الإلكتروني، وإن لم يصلك شيء أعد المحاولة.',
                ),
              ),
            );
          } else if (state is AuthSuccess) {
            final route = state.user.role == 'provider'
                ? AppRoutes.providerHome
                : AppRoutes.home;
            Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'إنشاء حساب',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'انضم إلينا وابدأ رحلة التخطيط لزفافك بكل أناقة وسهولة.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  OutlinedButton(
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/image/google1.png", width: 24),
                        const SizedBox(width: 12),
                        Text(
                          "المتابعة باستخدام Google",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildLabel('الاسم', theme),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'example'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('البريد الإلكتروني', theme),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      hintText: 'example@gmail.com',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'صيغة البريد الإلكتروني غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('رقم الجوال', theme),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: '598577418',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCountryCode,
                            icon: const Icon(Icons.arrow_drop_down),
                            items: const [
                              DropdownMenuItem(
                                value: '+970',
                                child: Text('+970'),
                              ),
                              DropdownMenuItem(
                                value: '+972',
                                child: Text('+972'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCountryCode = value ?? '+970';
                              });
                            },
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال رقم الجوال';
                      }
                      final phoneRegex = RegExp(r'^5[69][0-9]{7}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'رقم الهاتف غير صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('المنطقة', theme),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRegion,
                    decoration: InputDecoration(
                      hintText: 'اختر منطقتك',
                      suffixIcon: Icon(Icons.my_location, color: primary),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'شمال غزة',
                        child: Text('شمال غزة'),
                      ),
                      DropdownMenuItem(
                        value: 'وسط غزة',
                        child: Text('وسط غزة'),
                      ),
                      DropdownMenuItem(
                        value: 'جنوب غزة',
                        child: Text('جنوب غزة'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedRegion = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء اختيار المنطقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('كلمة المرور', theme),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: primary,
                        ),
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('تأكيد كلمة المرور', theme),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      prefixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: primary,
                        ),
                        onPressed: () {
                          setState(
                            () => obscureConfirmPassword =
                                !obscureConfirmPassword,
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء تأكيد كلمة المرور';
                      }
                      if (value != passwordController.text) {
                        return 'كلمة المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(
                          text: 'بالضغط على اشتراك فإنك توافق على ',
                        ),
                        TextSpan(
                          text: 'سياسية الخصوصية والاستخدام',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TermsAndConditionsScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onSignUpPressed,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('اشتراك'),
                      );
                    },
                  ),
                  if (_showWaitHint) ...[
                    const SizedBox(height: 10),
                    Text(
                      'جارٍ إنشاء الحساب، قد يستغرق هذا لحظات...',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'لديك حساب بالفعل! '),
                        TextSpan(
                          text: 'تسجيل الدخول',
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
