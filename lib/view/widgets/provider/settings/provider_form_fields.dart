import 'package:flutter/material.dart';

// فرح: عناصر الحقول المشتركة لشاشات حساب المزود (بيانات المتجر، الملف الشخصي،
// كلمة المرور، حساب استلام الارباح) كما في التصميم.

/// Grey border of "بيانات المتجر" and "حساب استلام الارباح".
const kProviderFieldBorder = Color(0xFFDADADA);

/// Thin maroon border of "تعديل الملف الشخصي" and "تغيير كلمة المرور".
const kProviderOutlinedFieldBorder = Color(0xFFB57A92);

/// Label above a field; [color] is maroon for most labels in the designs.
class ProviderFieldLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;

  const ProviderFieldLabel(
    this.text, {
    super.key,
    this.color,
    this.bold = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: bold ? 16 : 15,
        ),
      ),
    );
  }
}

InputDecoration providerFieldDecoration({
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  Color borderColor = kProviderFieldBorder,
  String? errorText,
}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: border(borderColor),
    enabledBorder: border(borderColor),
    focusedBorder: border(const Color(0xFF7B2146)),
    errorBorder: border(const Color(0xFFD9473F)),
    focusedErrorBorder: border(const Color(0xFFD9473F)),
  );
}

/// "حفظ التغيرات" pinned at the bottom of the account screens.
class ProviderBottomAction extends StatelessWidget {
  final Widget child;

  const ProviderBottomAction({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 20),
        child: child,
      ),
    );
  }
}
