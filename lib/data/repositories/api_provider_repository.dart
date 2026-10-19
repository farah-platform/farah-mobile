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
  Future<List<dynamic>> getCategories() async {
    final res = await dioClient.dio.get(ApiEndpoints.categories);
    return res.data['data'] ?? [];
  }

  @override
  Future<List<dynamic>> getCities() async {
    final res = await dioClient.dio.get(ApiEndpoints.cities);
    return res.data['data'] ?? [];
  }

  @override
  Future<void> submitOnboardingData(Map<String, dynamic> data, dynamic idProof, dynamic coverImage) async {
    FormData formData = FormData.fromMap(data);
    
    if (idProof != null) {
      formData.files.add(MapEntry('identity_document', await MultipartFile.fromFile(idProof.path)));
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
  Future<Map<String, dynamic>> activateSubscription(String planSlug, {dynamic proof}) async {
    final Object data = proof == null
        ? {'plan': planSlug}
        : FormData.fromMap({
            'plan': planSlug,
            'proof': await MultipartFile.fromFile(proof.path),
          });
    final res = await dioClient.dio.post('/provider/subscription', data: data);
    final body = res.data;
    return body is Map && body['data'] is Map
        ? Map<String, dynamic>.from(body['data'])
        : {};
  }

  @override
  Future<Map<String, dynamic>> getBankTransferDetails() async {
    final res = await dioClient.dio.get(ApiEndpoints.settings);
    final bank = res.data['data']?['bank_transfer'];
    return bank is Map ? Map<String, dynamic>.from(bank) : {};
  }

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
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages) async {
    // The API updates with POST /provider/services/{id}; spoofing PUT gives 405.
    final formData = FormData.fromMap(data);

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
  Future<void> toggleServiceVisibility(int id, bool isAvailable) async {
    await dioClient.dio.patch(
      '${ApiEndpoints.providerServices}/$id/visibility',
      data: {'is_available': isAvailable},
    );
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

  @override
  Future<List<dynamic>> getProviderBookings({String? status}) async {
    final res = await dioClient.dio.get(
      ApiEndpoints.providerBookings,
      queryParameters: {'per_page': 50, if (status != null) 'status': status},
    );
    final data = res.data['data'];
    return data is List ? data : [];
  }

  @override
  Future<void> decideBooking(int bookingId, String decision, {double? depositAmount, String? note}) async {
    await dioClient.dio.post('${ApiEndpoints.providerBookings}/$bookingId/decision', data: {
      'decision': decision,
      if (depositAmount != null) 'deposit_amount': depositAmount,
      if (note != null && note.isNotEmpty) 'provider_note': note,
    });
  }

  @override
  Future<void> completeBooking(int bookingId) async {
    await dioClient.dio.post('${ApiEndpoints.providerBookings}/$bookingId/complete');
  }

  @override
  Future<List<int>> getPaymentProof(int bookingId, int paymentId) async {
    final res = await dioClient.dio.get<List<int>>(
      '${ApiEndpoints.providerBookings}/$bookingId/payments/$paymentId/proof',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? [];
  }

  @override
  Future<void> updatePaymentInstructions(String instructions) async {
    await dioClient.dio.put('/provider/payment-instructions', data: {'payment_instructions': instructions});
  }

  @override
  Future<Map<String, dynamic>> getServiceAvailability(int serviceId, String month) async {
    final res = await dioClient.dio.get(
      '${ApiEndpoints.providerServices}/$serviceId/availability',
      queryParameters: {'month': month},
    );
    final data = res.data['data'];
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  @override
  Future<void> updateServiceAvailability(int serviceId, {List<String> block = const [], List<String> unblock = const []}) async {
    await dioClient.dio.put('${ApiEndpoints.providerServices}/$serviceId/availability', data: {
      if (block.isNotEmpty) 'block_dates': [for (final d in block) {'date': d}],
      if (unblock.isNotEmpty) 'unblock_dates': unblock,
    });
  }
}
