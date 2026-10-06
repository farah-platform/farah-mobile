import re

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = '''import '../../../core/constants/app_routes.dart';\n''' + text

text = text.replace(
    'Navigator.pushNamed(context, \'/provider-add-service\');',
    'Navigator.pushNamed(context, AppRoutes.providerAddService);'
)

with open('lib/view/screens/provider/services/provider_services_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
