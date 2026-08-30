import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward, size: 26),
                  ),
                ),

                const SizedBox(height: 60),

                Text(
                  "كلمة مرور جديدة",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "يرجى كتابة كلمة مرور قوية",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

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

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "تأكيد كلمة المرور",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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
                          () =>
                              obscureConfirmPassword = !obscureConfirmPassword,
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

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: استدعاء AuthCubit لتحديث كلمة المرور
                    }
                  },
                  child: const Text("إنشاء كلمة مرور جديدة"),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
