import re
with open('lib/view/screens/provider/provider_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('body: _buildBody(),,', 'body: _buildBody(),')
text = re.sub(r'currentIndex: 0,\s*', '', text)

with open('lib/view/screens/provider/provider_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
