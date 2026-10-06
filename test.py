import re

with open('lib/view/screens/provider/provider_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

state_start = text.find('class _ProviderHomeScreenState extends State<ProviderHomeScreen> {')
text = text[:state_start] + 'class _ProviderHomeScreenState extends State<ProviderHomeScreen> {\n  int _currentIndex = 0;\n' + text[state_start + 68:]

body_start = text.find('        body: BlocBuilder<ProviderDashboardCubit, ProviderDashboardState>(')
body_end_match = re.search(r'\n        \),\n        bottomNavigationBar: BottomNavigationBar', text)
body_end = body_end_match.start() + 10
old_body = text[body_start:body_end]

text = text[:body_start] + '        body: _buildBody(),' + text[body_end:]

home_content = old_body.replace('body: BlocBuilder', 'Widget _buildHomeContent() {\n    return BlocBuilder')
home_content = home_content[:-1] + ';\n  }'

build_body = '''
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const Center(child: Text('??????? (??????)'));
      case 2:
        return const Center(child: Text('?????? (??????)'));
      case 3:
        return const Center(child: Text('????? (??????)'));
      default:
        return _buildHomeContent();
    }
  }

''' + home_content

stat_card_idx = text.find('  Widget _buildStatCard({')
text = text[:stat_card_idx] + build_body + '\n' + text[stat_card_idx:]

nav_replace = '''bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey,'''
text = text.replace('bottomNavigationBar: BottomNavigationBar(', nav_replace, 1)

with open('lib/view/screens/provider/provider_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
