import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String region;
  final String role;
  // فرح: صورة الحساب (للمزود هي شعار المتجر) لعرضها في "تعديل الملف الشخصي".
  final String? avatar;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.region = '',
    this.role = 'customer',
    this.avatar,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    // Backend returns integer `id`; persisted format uses string `uid`.
    uid: (map['id'] ?? map['uid'] ?? '').toString(),
    name: (map['name'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    phone: (map['phone'] as String?) ?? '',
    region: (map['region'] as String?) ?? '',
    role: (map['role'] as String?) ?? 'customer',
    avatar: map['avatar'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'region': region,
    'role': role,
    'avatar': avatar,
  };

  @override
  List<Object?> get props => [uid, email];
}
