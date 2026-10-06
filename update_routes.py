import re

with open('lib/core/constants/app_routes.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add route constant
text = text.replace(
    '  static const String providerSubscriptionSuccess = \'/provider/subscription-success\';',
    '  static const String providerSubscriptionSuccess = \'/provider/subscription-success\';\n  static const String providerAddService = \'/provider/add-service\';'
)

# Import the screen
text = text.replace(
    'import \'../../view/screens/provider/provider_verification_screen.dart\';',
    'import \'../../view/screens/provider/provider_verification_screen.dart\';\nimport \'../../view/screens/provider/services/provider_add_service_screen.dart\';'
)

# Add to routes map
text = text.replace(
    '''    providerSubscriptionSuccess: (_) => const _ProviderGuard(
      child: ProviderSubscriptionSuccessScreen(),
    ),''',
    '''    providerSubscriptionSuccess: (_) => const _ProviderGuard(
      child: ProviderSubscriptionSuccessScreen(),
    ),
    providerAddService: (_) => const _ProviderGuard(
      child: ProviderAddServiceScreen(),
    ),'''
)

with open('lib/core/constants/app_routes.dart', 'w', encoding='utf-8') as f:
    f.write(text)
