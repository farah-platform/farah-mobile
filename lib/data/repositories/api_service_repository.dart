import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/models/service_provider_model.dart';
import 'package:farah/data/repositories/service_repository.dart';

/// Real backend implementation of [ServiceRepository].
class ApiServiceRepository implements ServiceRepository {
  final Dio _dio;

  ApiServiceRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
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

  @override
  Future<ServiceModel> fetchServiceById(String id) async {
    final res = await _dio.get('/services/$id');
    return ServiceModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ServiceProviderModel> fetchProviderProfile(String providerId) async {
    final res = await _dio.get('/providers/$providerId');
    return ServiceProviderModel.fromMap(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ServiceModel>> fetchProviderServices(String providerId) async {
    final res = await _dio.get('/providers/$providerId/services');
    return (res.data['data'] as List)
        .map((e) => ServiceModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
