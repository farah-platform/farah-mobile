import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// فرح: زر "تواصل معنا": واتساب على هاتف الدعم، وإلا بريد الدعم (من إعدادات الأدمن).
// إذا لم يعبّئهما الأدمن تظهر "هذه الميزة غير متاحة حالياً" بدل رقم وهمي.
Future<void> openSupportContact(
  BuildContext context, {
  String? phone,
  String? email,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final digits = phone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
  final whatsApp = digits.startsWith('00')
      ? digits.substring(2)
      : digits.startsWith('0')
      ? '970${digits.substring(1)}'
      : digits;
  final uri = whatsApp.isNotEmpty
      ? Uri.parse('https://wa.me/$whatsApp')
      : email != null && email.isNotEmpty
      ? Uri(scheme: 'mailto', path: email)
      : null;
  if (uri == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('هذه الميزة غير متاحة حالياً')),
    );
    return;
  }
  final opened = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  ).catchError((_) => false);
  if (!opened) {
    messenger.showSnackBar(
      const SnackBar(content: Text('تعذّر فتح وسيلة التواصل')),
    );
  }
}
