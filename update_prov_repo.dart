import 'dart:io';

void main() {
  final file = File('lib/data/repositories/provider_repository.dart');
  var content = file.readAsStringSync();
  if (!content.contains('Future<Map<String, dynamic>> getBookingDetails')) {
    content = content.replaceFirst(
      'Future<void> reviewPaymentProof',
      'Future<Map<String, dynamic>> getBookingDetails(int bookingId);\n  Future<void> reviewPaymentProof'
    );
    file.writeAsStringSync(content);
  }
}
