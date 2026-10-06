import 'dart:io';

void main() {
  final file = File('lib/view/screens/provider/provider_onboarding_screen.dart');
  var content = file.readAsStringSync();

  content = content.replaceFirst(
    '_cities.map((city)',
    '_cities.map<DropdownMenuItem<String>>((city)'
  );

  file.writeAsStringSync(content);
  print('Fixed map type');
}
