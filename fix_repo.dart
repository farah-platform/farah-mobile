import 'dart:io';

void main() {
  final file = File('lib/data/repositories/api_provider_repository.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    "'image', // The api accepts 'image' or 'images[]'? The screenshot showed 'image' (file). If it accepts multiple, it might be images[]",
    "'images[]',"
  );
  content = content.replaceAll(
    "'image',",
    "'images[]',"
  );

  file.writeAsStringSync(content);
}
