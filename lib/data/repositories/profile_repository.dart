import 'dart:io';

import 'package:farah/data/models/service_provider_model.dart';
import 'package:farah/data/models/user_model.dart';

/// Abstract interface for profile operations.
abstract class ProfileRepository {
  Future<UserModel> fetchUserProfile();

  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? region,
  });

  Future<UserModel> uploadAvatar(File image);

  Future<ServiceProviderModel> fetchProviderProfile();

  Future<ServiceProviderModel> updateProviderProfile({
    String? name,
    String? phone,
    String? region,
    String? description,
    List<String>? categories,
  });
}
