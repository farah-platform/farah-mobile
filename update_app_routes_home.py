import re

with open('lib/core/constants/app_routes.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    '''    providerHome: (context) => _ProviderGuard(
      child: BlocProvider(
        create: (c) => ProviderDashboardCubit(c.read<ProviderRepository>()),
        child: const ProviderHomeScreen(),
      ),
    ),''',
    '''    providerHome: (context) => _ProviderGuard(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => ProviderDashboardCubit(c.read<ProviderRepository>())),
          BlocProvider(create: (c) => ProviderServicesCubit(c.read<ProviderRepository>())..loadServices()),
        ],
        child: const ProviderHomeScreen(),
      ),
    ),'''
)

with open('lib/core/constants/app_routes.dart', 'w', encoding='utf-8') as f:
    f.write(text)
