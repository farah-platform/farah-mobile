import re

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r"Text\('السعر:.*?'", "Text('السعر: $price شيكل'", text)

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
