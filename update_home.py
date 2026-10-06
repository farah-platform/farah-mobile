import re

with open('lib/view/screens/provider/provider_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    '''import '../../widgets/provider/home/provider_home_quick_management_widget.dart';''',
    '''import '../../widgets/provider/home/provider_home_quick_management_widget.dart';
import 'services/provider_services_screen.dart';'''
)

text = text.replace(
    '''      case 2:
        return const Center(child: Text('خدماتي (قريباً)'));''',
    '''      case 2:
        return const ProviderServicesScreen();'''
)

with open('lib/view/screens/provider/provider_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
