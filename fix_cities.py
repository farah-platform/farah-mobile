import re

with open('lib/view/screens/auth/sginup.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add _citiesError variable
content = re.sub(
    r'bool _isLoadingCities = true;',
    'bool _isLoadingCities = true;\n  String? _citiesError;',
    content
)

# Update _fetchCities to capture error
content = re.sub(
    r'\} catch \(\_\) \{\s*if \(mounted\) \{\s*setState\(\(\) => _isLoadingCities = false\);\s*\}\s*\}',
    '} catch (e) {\n      if (mounted) {\n        setState(() {\n          _isLoadingCities = false;\n          _citiesError = e.toString();\n        });\n      }\n    }',
    content
)

# Update UI to show error if _citiesError is not null
ui_replacement = """_citiesError != null
                        ? Text(
                            'خطأ في تحميل المناطق: $_citiesError',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          )
                        : DropdownButtonFormField<int>("""

content = content.replace(': DropdownButtonFormField<int>(', ui_replacement)

with open('lib/view/screens/auth/sginup.dart', 'w', encoding='utf-8') as f:
    f.write(content)
