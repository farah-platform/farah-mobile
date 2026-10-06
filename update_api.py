import re

with open('lib/core/network/api_endpoints.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    '  static const String services = \'/services\';',
    '  static const String services = \'/services\';\n\n  // Provider Services\n  static const String providerServices = \'/provider/services\';'
)

with open('lib/core/network/api_endpoints.dart', 'w', encoding='utf-8') as f:
    f.write(text)
