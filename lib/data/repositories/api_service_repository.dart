import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/service_repository.dart';

class ApiServiceRepository implements ServiceRepository {
  final Dio _dio;

  ApiServiceRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<ServiceModel>> fetchServices({
    int? categoryId,
    String? categorySlug,
    String? search,
    String? sortBy,
    int? cityId,
    double? latitude,
    double? longitude,
    int? perPage,
    int? page,
  }) async {
    final res = await _dio.get(
      '/services',
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (categorySlug != null) 'category_slug': categorySlug,
        if (search != null) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (cityId != null) 'city_id': cityId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
      },
    );

    final data = res.data as Map<String, dynamic>;

    return (data['data'] as List?)
            ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<ServiceModel> fetchServiceById(String id) async {
    final res = await _dio.get('/services/$id');

    final data = res.data as Map<String, dynamic>;

    return ServiceModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ServiceProviderModel> fetchProviderProfile(String providerId) async {
    final res = await _dio.get('/providers/$providerId');

    final data = res.data as Map<String, dynamic>;

    return ServiceProviderModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ServiceModel>> fetchProviderServices(String providerId) async {
    final res = await _dio.get('/providers/$providerId/services');

    final data = res.data as Map<String, dynamic>;

    return (data['data'] as List?)
            ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
}
