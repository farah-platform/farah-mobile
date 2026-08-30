import 'package:farah/view/screens/auth/forgot_password.dart';
import 'package:farah/view/screens/auth/sginup.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 90),

                Text(
                  "تسجيل دخول",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "اهلا بعودتك مجددا",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 35),

                OutlinedButton(
                  onPressed: () {},
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

                const SizedBox(height: 45),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "البريد الإلكتروني",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: const InputDecoration(
                    hintText: "example@gmail.com",
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

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "كلمة المرور",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: "••••••••••••",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: primary,
                      ),
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

                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    //هنشيل التنقل اليدوي لما نربط API
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "نسيت كلمة المرور؟",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                  onPressed: _onLoginPressed,
                  child: Text(
                    "تسجيل الدخول",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("ليس لديك حساب؟", style: theme.textTheme.bodyLarge),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "إنشاء حساب",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
