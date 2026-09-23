import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/service_provider_model.dart';
import 'package:farah/data/models/user_model.dart';
import 'package:farah/data/repositories/profile_repository.dart';

/// Real backend implementation of [ProfileRepository].
class ApiProfileRepository implements ProfileRepository {
  final Dio _dio;

  ApiProfileRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<UserModel> fetchUserProfile() async {
    final res = await _dio.get(ApiEndpoints.profile);
    return UserModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? region,
    File? avatar,
  }) async {
    final fields = <String, dynamic>{
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (region != null) 'region': region,
      if (avatar != null)
        'avatar': await MultipartFile.fromFile(
          avatar.path,
          filename: 'avatar.jpg',
        ),
    };
    final res = await _dio.post(
      ApiEndpoints.profileUpdate,
      data: FormData.fromMap(fields),
    );
    return UserModel.fromMap(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> uploadAvatar(File image) => updateUserProfile(avatar: image);

  // TODO: /provider/profile is not in the current backend spec.
  // These methods will be updated when the endpoint is documented.
  @override
  Future<ServiceProviderModel> fetchProviderProfile() async {
    final res = await _dio.get('/provider/profile');
    return ServiceProviderModel.fromMap(
      res.data['data'] as Map<String, dynamic>,
    );
  }

  @override
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
    return ServiceProviderModel.fromMap(
      res.data['data'] as Map<String, dynamic>,
    );
  }
}
