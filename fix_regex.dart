import 'dart:io';

void main() {
  final files = ['lib/view/screens/auth/sginup.dart', 'lib/view/screens/auth/login.dart'];
  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    // Using RegExp to replace the Text widget that contains "Google" inside the OutlinedButton Row
    final regex = RegExp(r'Text\(\s*"المتابعة باستخدام Google",\s*style:[^)]+\),\s*\),');
    content = content.replaceAllMapped(regex, (match) {
      return 'Flexible(\n                            child: \n                          )';
    });
    
    file.writeAsStringSync(content);
  }
}
