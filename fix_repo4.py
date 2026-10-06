import re

with open('lib/data/repositories/api_provider_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

impl = """  @override
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
    
    await dioClient.dio.post('${ApiEndpoints.providerServices}/$id', data: formData);
  }

  @override
  Future<void> deleteProviderService(int id) async {
    await dioClient.dio.delete('${ApiEndpoints.providerServices}/$id');
  }

  @override
  Future<void> toggleServiceVisibility(int id) async {
    await dioClient.dio.patch('${ApiEndpoints.providerServices}/$id/visibility');
  }"""

# Replace all everything from updateProviderService down to before getDashboardData
text = re.sub(r'  @override\s+Future<void> updateProviderService.*?(?=  @override\s+Future<Map<String, dynamic>> getDashboardData)', impl + '\n\n', text, flags=re.DOTALL)

with open('lib/data/repositories/api_provider_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
