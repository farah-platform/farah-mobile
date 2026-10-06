import 'dart:io';

void main() {
  final file = File('lib/view/screens/provider/services/provider_services_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    'const Text(\n                      userName,',
    'Text(\n                      userName,'
  );
  content = content.replaceAll(
    'const Text(\n                      userRegion,',
    'Text(\n                      userRegion,'
  );
  content = content.replaceAll(
    'Text(\n                      userRegion',
    'Text(\n                      userRegion'
  ); // fallback in case it was const
  
  // Also check if they are inline without newlines
  content = content.replaceAll('const Text(userName', 'Text(userName');
  content = content.replaceAll('const Text(userRegion', 'Text(userRegion');
  
  file.writeAsStringSync(content);
}
