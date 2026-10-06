import re

with open('lib/data/repositories/api_provider_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

impl = '''
  @override
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages) async {
    final formData = FormData.fromMap(data);
    
    // In Laravel, to send a PUT request with FormData, we often use POST and add _method=PUT
    formData.fields.add(const MapEntry('_method', 'PUT'));

    for (int i = 0; i < newImages.length; i++) {
      if (newImages[i] != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(newImages[i].path),
        ));
      }
    }
    
    // The endpoint is POST /api/provider/services/{id} for update based on the swagger list
    await dioClient.dio.post('\/\', data: formData);
  }

  @override
  Future<void> deleteProviderService(int id) async {
    await dioClient.dio.delete('\/\');
  }

  @override
  Future<void> toggleServiceVisibility(int id) async {
    await dioClient.dio.patch('\/\/visibility');
  }
'''

text = text.replace(
    '  Future<Map<String, dynamic>> getDashboardData() async {',
    impl + '\n  @override\n  Future<Map<String, dynamic>> getDashboardData() async {'
)

with open('lib/data/repositories/api_provider_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
