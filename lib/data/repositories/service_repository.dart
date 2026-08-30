import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/models/service_provider_model.dart';

// TODO: paths below are not yet in the backend spec and will 404.
// Wire to real endpoints once they are documented.
class ServiceRepository {
  final Dio _dio;

  ServiceRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<List<ServiceModel>> fetchServices({
    String? category,
    String? region,
    String? query,
  }) async {
    final res = await _dio.get(
      '/services',
      queryParameters: {
        if (category != null) 'category': category,
        if (region != null) 'region': region,
        if (query != null) 'q': query,
      },
    );
    return (res.data['data'] as List)
        .map((e) => ServiceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<ServiceModel> fetchServiceById(String id) async {
    final res = await _dio.get('/services/$id');
    return ServiceModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  Future<ServiceProviderModel> fetchProviderProfile(String providerId) async {
    final res = await _dio.get('/providers/$providerId');
    return ServiceProviderModel.fromMap(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  Future<List<ServiceModel>> fetchProviderServices(String providerId) async {
    final res = await _dio.get('/providers/$providerId/services');
    return (res.data['data'] as List)
        .map((e) => ServiceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
