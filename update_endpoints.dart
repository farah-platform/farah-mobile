import 'dart:io';

void main() {
  final file = File('lib/core/network/api_endpoints.dart');
  var content = file.readAsStringSync();
  if (!content.contains('providerBookings')) {
    content = content.replaceFirst(
      'static const String providerServices = \'/provider/services\';',
      'static const String providerServices = \'/provider/services\';\n  static const String providerBookings = \'/provider/bookings\';'
    );
    file.writeAsStringSync(content);
  }
}
