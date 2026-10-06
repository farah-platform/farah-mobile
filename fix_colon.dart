import 'dart:io';

void main() {
  final file = File('lib/view/screens/auth/sginup.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    ')\n                          \n                      _citiesError != null',
    ')\n                          \n                      : _citiesError != null'
  );
  
  content = content.replaceAll(
    ')\n                      _citiesError != null',
    ')\n                      : _citiesError != null'
  );

  // If the above don't work, let's use a Regex
  content = content.replaceAllMapped(
    RegExp(r'\)\s+_citiesError != null\s+\? Text\('),
    (match) => match.group(0)!.replaceFirst('_citiesError != null', ': _citiesError != null')
  );

  file.writeAsStringSync(content);
  print('Done fixing colon');
}
