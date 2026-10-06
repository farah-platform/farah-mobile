import re

with open('lib/data/repositories/api_auth_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("ApiEndpoints.account", "ApiEndpoints.deleteAccount")

with open('lib/data/repositories/api_auth_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
