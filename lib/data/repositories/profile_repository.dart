import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/service_provider_model.dart';
import 'package:farah/data/models/user_model.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  Future<UserModel> fetchUserProfile() async {
    final res = await _dio.get(ApiEndpoints.profile);
    return UserModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? region,
  }) async {
    final res = await _dio.put(
      ApiEndpoints.profile,
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (region != null) 'region': region,
      },
    );
    return UserModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  // TODO: spec says POST /profile/update (multipart). Full multipart
  // implementation is in Step 4. Placeholder keeps compilation valid.
  Future<UserModel> uploadAvatar(File image) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        image.path,
        filename: 'avatar.jpg',
      ),
    });
    final res = await _dio.post(ApiEndpoints.profileUpdate, data: formData);
    return UserModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  // TODO: /provider/profile is not in the current backend spec.
  // These methods will be updated when the endpoint is documented.
  Future<ServiceProviderModel> fetchProviderProfile() async {
    final res = await _dio.get('/provider/profile');
    return ServiceProviderModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  Future<ServiceProviderModel> updateProviderProfile({
    String? name,
    String? phone,
    String? region,
    String? description,
    List<String>? categories,
  }) async {
    final res = await _dio.put(
      '/provider/profile',
      data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (region != null) 'region': region,
        if (description != null) 'description': description,
        if (categories != null) 'categories': categories,
      },
    );
    return ServiceProviderModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }
}
