import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
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

  @override
  Future<List<dynamic>> getProviderServices() async {
    final response = await dioClient.dio.get(ApiEndpoints.providerServices);
    if (response.data is Map && response.data['data'] != null) {
      return response.data['data'] as List<dynamic>;
    } else if (response.data is List) {
      return response.data as List<dynamic>;
    }
    return [];
  }

  @override
  Future<void> addProviderService(Map<String, dynamic> data, List<dynamic> images) async {
    final formData = FormData.fromMap(data);
    
    // Add images if any
    for (int i = 0; i < images.length; i++) {
      if (images[i] != null) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(images[i].path),
        ));
      }
    }
    
    await dioClient.dio.post(ApiEndpoints.providerServices, data: formData);
  }

  @override

  @override
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages) async {
    final formData = FormData.fromMap(data);
    formData.fields.add(const MapEntry('_method', 'PUT'));

    for (int i = 0; i < newImages.length; i++) {
      if (newImages[i] != null) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(newImages[i].path),
        ));
      }
    }
    
    await dioClient.dio.post('${ApiEndpoints.providerServices}/$id', data: formData);
  }

  @override
  Future<void> deleteProviderService(int id) async {
    await dioClient.dio.delete('${ApiEndpoints.providerServices}/$id');
  }

  @override
  Future<void> toggleServiceVisibility(int id) async {
    await dioClient.dio.patch('${ApiEndpoints.providerServices}/$id/visibility');
  }

  @override
  Future<Map<String, dynamic>> getDashboardData() async {
    final res = await dioClient.dio.get('/provider/dashboard');
    return res.data['data'] ?? {};
  }
  @override
  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote}) async {
    final data = {
      'decision': decision,
      if (reviewNote != null) 'review_note': reviewNote,
    };
    await dioClient.dio.post('${ApiEndpoints.providerBookings}/$bookingId/payments/$paymentId/review', data: data);
  }
  @override
  Future<Map<String, dynamic>> getBookingDetails(int bookingId) async {
    final response = await dioClient.dio.get('${ApiEndpoints.providerBookings}/$bookingId');
    return response.data['data'] ?? {};
  }
}
