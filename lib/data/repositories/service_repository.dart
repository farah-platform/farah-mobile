import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/models/service_provider_model.dart';

/// Abstract interface for service / provider data operations.
abstract class ServiceRepository {
  Future<List<ServiceModel>> fetchServices({
    String? category,
    String? region,
    String? query,
  });

  Future<ServiceModel> fetchServiceById(String id);

  Future<ServiceProviderModel> fetchProviderProfile(String providerId);

  Future<List<ServiceModel>> fetchProviderServices(String providerId);
}
