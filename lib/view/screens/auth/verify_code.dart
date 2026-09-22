import 'package:farah/view/screens/auth/new_password.dart';
import 'package:flutter/material.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => controllers.map((c) => c.text).join();

  Widget _buildCodeBox(int index, ThemeData theme) {
    final primary = theme.colorScheme.primary;

    return SizedBox(
      width: 65,
      height: 70,
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primary, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isComplete = _code.length == 4;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
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
                "أدخل رمز التحقق",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "تم ارسال رمز التحقق إلى بريدك",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => _buildCodeBox(index, theme),
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: isComplete
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewPasswordScreen(),
                          ),
                        );
                      }
                    : null,
                child: const Text("تأكيد"),
              ),

              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لم يصلك الرمز؟ ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'إعادة الإرسال',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
