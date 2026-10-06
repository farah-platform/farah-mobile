import 'dart:io';

void main() {
  final file = File('lib/view/screens/provider/services/provider_services_screen.dart');
  var content = file.readAsStringSync();
  print(content.length);
}
