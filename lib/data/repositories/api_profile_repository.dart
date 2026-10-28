import 'dart:io';

import 'package:dio/dio.dart';
import 'package:farah/core/network/api_endpoints.dart';
import 'package:farah/core/network/dio_client.dart';
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
}
