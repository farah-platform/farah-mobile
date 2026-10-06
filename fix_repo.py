import re

with open('lib/data/repositories/api_provider_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    'await dioClient.dio.post(\'/\', data: formData);',
    'await dioClient.dio.post(\'\/\\', data: formData);'
)

text = text.replace(
    'await dioClient.dio.delete(\'/\');',
    'await dioClient.dio.delete(\'\/\\');'
)

text = text.replace(
    'await dioClient.dio.patch(\'//visibility\');',
    'await dioClient.dio.patch(\'\/\/visibility\');'
)

with open('lib/data/repositories/api_provider_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
