import re
with open('lib/view/screens/provider/provider_home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Match the duplicate lines and remove them
text = re.sub(r'type: BottomNavigationBarType.fixed,\s*selectedItemColor: primary,\s*unselectedItemColor: Colors.grey,', 'type: BottomNavigationBarType.fixed,', text)

with open('lib/view/screens/provider/provider_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
