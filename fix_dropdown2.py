import re

with open('lib/view/screens/provider/provider_onboarding_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    '''                      decoration: InputDecoration(
                        hintText: 'اختر منطقتك',
                        suffixIcon: Icon(Icons.my_location, color: primary),
                      ),''',
    '''                      decoration: InputDecoration(
                        hintText: 'اختر منطقتك',
                        suffixIcon: Icon(Icons.my_location, color: primary),
                        constraints: const BoxConstraints(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),'''
)

with open('lib/view/screens/provider/provider_onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
