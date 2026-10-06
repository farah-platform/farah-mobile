import re

with open('lib/core/constants/app_routes.dart', 'r', encoding='utf-8') as f:
    text = f.read()

imports = '''import '../../view/screens/provider/services/provider_add_package_screen.dart';
import '../../view/screens/provider/services/provider_edit_package_screen.dart';'''

text = text.replace('import \'../../view/screens/provider/services/provider_edit_service_screen.dart\';', 'import \'../../view/screens/provider/services/provider_edit_service_screen.dart\';\n' + imports)

text = text.replace('  static const String providerEditService = \'/provider/edit-service\';', '  static const String providerEditService = \'/provider/edit-service\';\n  static const String providerAddPackage = \'/provider/add-package\';\n  static const String providerEditPackage = \'/provider/edit-package\';')

routes = '''    providerAddPackage: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
        child: const ProviderAddPackageScreen(),
      ),
    ),
    providerEditPackage: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return _ProviderGuard(
        child: BlocProvider(
          create: (c) => ProviderServicesCubit(c.read<ProviderRepository>()),
          child: ProviderEditPackageScreen(packageData: args),
        ),
      );
    },'''

text = text.replace('    providerAddService: (context) => _ProviderGuard(', routes + '\n    providerAddService: (context) => _ProviderGuard(')

with open('lib/core/constants/app_routes.dart', 'w', encoding='utf-8') as f:
    f.write(text)
