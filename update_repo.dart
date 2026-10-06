import 'dart:io';

void main() {
  final repoFile = File('lib/data/repositories/provider_repository.dart');
  var repoContent = repoFile.readAsStringSync();
  if (!repoContent.contains('reviewPaymentProof')) {
    repoContent = repoContent.replaceFirst(
      'Future<void> toggleServiceVisibility(int id);',
      'Future<void> toggleServiceVisibility(int id);\n  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote});'
    );
    repoFile.writeAsStringSync(repoContent);
  }

  final apiRepoFile = File('lib/data/repositories/api_provider_repository.dart');
  var apiRepoContent = apiRepoFile.readAsStringSync();
  if (!apiRepoContent.contains('reviewPaymentProof')) {
    apiRepoContent = apiRepoContent.replaceFirst(
      '}',
      '''
  @override
  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote}) async {
    final data = {
      'decision': decision,
      if (reviewNote != null) 'review_note': reviewNote,
    };
    await dioClient.dio.post('\${ApiEndpoints.providerBookings}/\$bookingId/payments/\$paymentId/review', data: data);
  }
}'''
    );
    apiRepoFile.writeAsStringSync(apiRepoContent);
  }
}
