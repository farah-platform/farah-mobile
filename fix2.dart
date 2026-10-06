import 'dart:io';

void main() {
  final file = File('lib/view/screens/auth/login.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'Text(\n                            "المتابعة باستخدام Google",\n                            style: theme.textTheme.titleMedium?.copyWith(\n                              color: Colors.black,\n                              fontSize: 14,\n                            ),\n                          ),',
    'Flexible(\n                            child: Text(\n                              "المتابعة باستخدام Google",\n                              style: theme.textTheme.titleMedium?.copyWith(\n                                color: Colors.black,\n                                fontSize: 14,\n                              ),\n                              overflow: TextOverflow.ellipsis,\n                            ),\n                          ),'
  );
  file.writeAsStringSync(content);
}
