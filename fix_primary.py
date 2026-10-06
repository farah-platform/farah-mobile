import re
with open('lib/view/screens/provider/provider_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('  Widget _buildBody() {', '  Widget _buildBody(BuildContext context) {')
text = text.replace('  Widget _buildHomeContent() {', '  Widget _buildHomeContent(BuildContext context) {\n    final primary = Theme.of(context).colorScheme.primary;')
text = text.replace('return _buildHomeContent();', 'return _buildHomeContent(context);')
text = text.replace('body: _buildBody(),', 'body: _buildBody(context),')

with open('lib/view/screens/provider/provider_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
