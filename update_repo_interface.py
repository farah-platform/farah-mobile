import re

with open('lib/data/repositories/provider_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    '  Future<void> addProviderService(Map<String, dynamic> data, List<dynamic> images);',
    '''  Future<void> addProviderService(Map<String, dynamic> data, List<dynamic> images);
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages);
  Future<void> deleteProviderService(int id);
  Future<void> toggleServiceVisibility(int id);'''
)

with open('lib/data/repositories/provider_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
