import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/repositories/provider_repository.dart';

class ApiProviderRepository implements ProviderRepository {
  final DioClient dioClient;

  ApiProviderRepository({required this.dioClient});

  @override
  Future<Map<String, dynamic>> getOnboardingData() async {
    final res = await dioClient.dio.get('/provider/onboarding');
    return res.data['data'] ?? {};
  }

  @override
  Future<void> submitOnboardingData(Map<String, dynamic> data, dynamic idProof, dynamic coverImage) async {
    FormData formData = FormData.fromMap(data);
    
    if (idProof != null) {
      formData.files.add(MapEntry('id_proof', await MultipartFile.fromFile(idProof.path)));
    }
    if (coverImage != null) {
      formData.files.add(MapEntry('cover_image', await MultipartFile.fromFile(coverImage.path)));
    }

    await dioClient.dio.post('/provider/onboarding', data: formData);
  }

  @override
  Future<Map<String, dynamic>> getVerificationStatus() async {
    final res = await dioClient.dio.get('/provider/verification');
    return res.data['data'] ?? {};
  }

  @override
  Future<List<dynamic>> getSubscriptionPlans() async {
    final res = await dioClient.dio.get('/provider/subscription-plans');
    return res.data['data'] ?? [];
  }

  @override
  Future<void> activateSubscription(String planId, String bankName, String accountNumber, dynamic receiptImage) async {
    FormData formData = FormData.fromMap({
      'plan_id': planId,
      'bank_name': bankName,
      'account_number': accountNumber,
    });

    if (receiptImage != null) {
      formData.files.add(MapEntry('receipt_image', await MultipartFile.fromFile(receiptImage.path)));
    }

    await dioClient.dio.post('/provider/subscription', data: formData);
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    final res = await dioClient.dio.get('/provider/dashboard');
    return res.data['data'] ?? {};
  }
}
