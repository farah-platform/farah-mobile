import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/models/service_provider_model.dart';

abstract class ServiceRepository {
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
  });

  Future<ServiceModel> fetchServiceById(String id);

  Future<ServiceProviderModel> fetchProviderProfile(String providerId);

  Future<List<ServiceModel>> fetchProviderServices(String providerId);
}
