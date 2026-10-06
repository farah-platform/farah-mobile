import re

with open('lib/core/constants/app_routes.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    'import \'../../view/screens/provider/services/provider_add_service_screen.dart\';',
    'import \'../../view/screens/provider/services/provider_add_service_screen.dart\';\nimport \'../../view/screens/provider/services/provider_edit_service_screen.dart\';'
)

text = text.replace(
    '''  static const String providerAddService = '/provider/add-service';''',
    '''  static const String providerAddService = '/provider/add-service';\n  static const String providerEditService = '/provider/edit-service';'''
)

text = text.replace(
    '''    providerAddService: (context) => _ProviderGuard(''',
    '''    providerEditService: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return _ProviderGuard(
        child: BlocProvider(
          create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
          child: ProviderEditServiceScreen(serviceData: args),
        ),
      );
    },
    providerAddService: (context) => _ProviderGuard('''
)

with open('lib/core/constants/app_routes.dart', 'w', encoding='utf-8') as f:
    f.write(text)
