import 'dart:io';

void main() {
  final file = File('lib/data/repositories/api_provider_repository.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains('reviewPaymentProof')) {
    content = content.replaceFirst(
      '}\n',
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
'''
    );
    file.writeAsStringSync(content);
  }
}
