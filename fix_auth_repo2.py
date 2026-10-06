import re

with open('lib/data/repositories/api_auth_repository.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("'/change-password'", 'ApiEndpoints.changePassword')

# Fix delete account
delete_impl = """  @override
  Future<void> deleteAccount() async {
    final token = await _cache.getToken();
    if (token == null) throw Exception('No session token');
    await _dio.delete(ApiEndpoints.account);
    await logout();
  }"""
text = re.sub(r'  @override\s+Future<void> deleteAccount\(\) async \{.*?\n  \}', delete_impl, text, flags=re.DOTALL)

with open('lib/data/repositories/api_auth_repository.dart', 'w', encoding='utf-8') as f:
    f.write(text)
