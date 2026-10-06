import re

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('fetchServices()', 'loadServices()')
text = text.replace('''Text('السعر:  شيكل',''', '''Text('السعر: \ شيكل',''')

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
