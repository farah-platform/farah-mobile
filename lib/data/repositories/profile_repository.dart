import 'dart:io';

import 'package:farah/data/models/user_model.dart';

/// Abstract interface for profile operations.
abstract class ProfileRepository {
  Future<UserModel> fetchUserProfile();

  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? region,
    File? avatar,
  });

  Future<UserModel> uploadAvatar(File image);
}
