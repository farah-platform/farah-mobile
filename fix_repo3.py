import re

with open('lib/data/repositories/api_provider_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

impl = '''  @override
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages) async {
    final formData = FormData.fromMap(data);
    formData.fields.add(const MapEntry('_method', 'PUT'));

    for (int i = 0; i < newImages.length; i++) {
      if (newImages[i] != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(newImages[i].path),
        ));
      }
    }
    
    await dioClient.dio.post('\/\', data: formData);
  }

  @override
  Future<void> deleteProviderService(int id) async {
    await dioClient.dio.delete('\/\');
  }

  @override
  Future<void> toggleServiceVisibility(int id) async {
    await dioClient.dio.patch('\/\/visibility');
  }'''

# I will find everything from updateProviderService to the end of the class, and replace it.
text = re.sub(r'  @override\s+Future<void> updateProviderService.*?}\s*}', impl + '\n}', text, flags=re.DOTALL)

with open('lib/data/repositories/api_provider_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
