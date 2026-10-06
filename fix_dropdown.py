import re

with open('lib/view/screens/provider/provider_onboarding_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add _categories and _cities to the state class
text = text.replace(
    '  File? _coverImageFile;',
    '  File? _coverImageFile;\n  List<dynamic> _categories = [];\n  List<dynamic> _cities = [];'
)

# Replace the local variables in builder
text = text.replace(
'''          List<dynamic> categories = [];
          List<dynamic> cities = [];
          
          if (state is ProviderOnboardingLoaded) {
            categories = state.categories;
            cities = state.cities;
          }''',
'''          if (state is ProviderOnboardingLoaded) {
            _categories = state.categories;
            _cities = state.cities;
          }'''
)

text = text.replace('if (categories.isEmpty', 'if (_categories.isEmpty')
text = text.replace('else if (categories.isNotEmpty)', 'else if (_categories.isNotEmpty)')
text = text.replace('itemCount: categories.length,', 'itemCount: _categories.length,')
text = text.replace('final cat = categories[index];', 'final cat = _categories[index];')
text = text.replace('items: cities.map((city) {', 'items: _cities.map((city) {')

with open('lib/view/screens/provider/provider_onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
