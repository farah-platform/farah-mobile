with open('lib/view/screens/provider/provider_onboarding_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

icon_helper = '''
  IconData _getCategoryIcon(String name) {
    if (name.contains('????')) return Icons.weekend_outlined;
    if (name.contains('?????')) return Icons.apartment_outlined;
    if (name.contains('??????')) return Icons.content_cut;
    if (name.contains('?????')) return Icons.camera_alt_outlined;
    if (name.contains('??????')) return Icons.checkroom_outlined;
    if (name.contains('???')) return Icons.local_florist_outlined;
    if (name.contains('?? ??')) return Icons.headphones_outlined;
    if (name.contains('????? ??????')) return Icons.directions_car_outlined;
    if (name.contains('????')) return Icons.mail_outline;
    if (name.contains('???')) return Icons.cake_outlined;
    if (name.contains('????? ??????')) return Icons.car_rental;
    return Icons.business_center_outlined;
  }
'''

build_idx = text.find('  @override\n  Widget build(BuildContext context) {')
text = text[:build_idx] + icon_helper + '\n' + text[build_idx:]

text = text.replace('Icons.business_center', "_getCategoryIcon(cat['name'])")

with open('lib/view/screens/provider/provider_onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
