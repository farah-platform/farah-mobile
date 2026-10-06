import 'dart:io';

void main() {
  final file = File('lib/view/screens/provider/bookings/provider_payment_review_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('EdgeInsets.bottom(', 'EdgeInsets.only(bottom: ');
  file.writeAsStringSync(content);
}
