import 'dart:io';

void main() {
  final file = File('lib/data/repositories/api_provider_repository.dart');
  var content = file.readAsStringSync();
  if (!content.contains('getBookingDetails(int bookingId)')) {
    final lastBrace = content.lastIndexOf('}');
    content = content.substring(0, lastBrace) + '''
  @override
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    final response = await dioClient.dio.get('\${ApiEndpoints.providerBookings}/\$bookingId');
    return response.data['data'] ?? {};
  }
}
''';
    file.writeAsStringSync(content);
  }
}
