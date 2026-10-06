import re

with open('lib/data/repositories/api_auth_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('\'/change-password\'', 'ApiEndpoints.changePassword')
text = text.replace('// await _dio.delete(\'/account\', options: Options(headers: {\'Authorization\': \'Bearer \\'}));\n    await Future.delayed(const Duration(seconds: 1));', 'await _dio.delete(ApiEndpoints.account, options: Options(headers: {\'Authorization\': \'Bearer \\'}));')

with open('lib/data/repositories/api_auth_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
