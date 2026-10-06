import 'dart:io';

void main() {
  final file = File('lib/data/repositories/api_provider_repository.dart');
  var content = file.readAsStringSync();
  
  // 1. Fix constructor
  content = content.replaceFirst(
    'ApiProviderRepository({required this.dioClient  @override\n  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote}) async {\n    final data = {\n      \'decision\': decision,\n      if (reviewNote != null) \'review_note\': reviewNote,\n    };\n    await dioClient.dio.post(\'\${ApiEndpoints.providerBookings}/\$bookingId/payments/\$paymentId/review\', data: data);\n  }\n});',
    'ApiProviderRepository({required this.dioClient});'
  );
  
  // 2. Add at the end
  if (!content.contains('reviewPaymentProof')) {
    final lastBrace = content.lastIndexOf('}');
    if (lastBrace != -1) {
      content = content.substring(0, lastBrace) + 
      '''
  @override
  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote}) async {
    final data = {
      'decision': decision,
      if (reviewNote != null) 'review_note': reviewNote,
    };
    await dioClient.dio.post('\${ApiEndpoints.providerBookings}/\$bookingId/payments/\$paymentId/review', data: data);
  }
}
''' ;
    }
  }
  file.writeAsStringSync(content);
}
