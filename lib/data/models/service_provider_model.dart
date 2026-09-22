import 'package:equatable/equatable.dart';

class ServiceProviderModel extends Equatable {
  final String uid;
  final String name;
  final String phone;
  final String region;
  final String description;
  final String coverImageUrl;
  final List<String> categories;
  final double rating;
  final int reviewsCount;
  final bool isVerified;

  final String? bankAccount;
  final String? iban;
  final String? jawwalPay;
  final String? palPay;

  const ServiceProviderModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.region,
    required this.description,
    required this.coverImageUrl,
    required this.categories,
    required this.rating,
    required this.reviewsCount,
    required this.isVerified,
    this.bankAccount,
    this.iban,
    this.jawwalPay,
    this.palPay,
  });

  factory ServiceProviderModel.fromMap(Map<String, dynamic> map) =>
      ServiceProviderModel(
        uid: map['uid']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        region: map['region'] as String? ?? '',
        description: map['description'] as String? ?? '',
        coverImageUrl: map['cover_image_url'] as String? ?? '',
        categories: List<String>.from(map['categories'] as List? ?? []),
        rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
        reviewsCount: map['reviews_count'] as int? ?? 0,
        isVerified: map['is_verified'] as bool? ?? false,
        bankAccount: map['bank_account'] as String?,
        iban: map['iban'] as String?,
        jawwalPay: map['jawwal_pay'] as String?,
        palPay: map['pal_pay'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'phone': phone,
    'region': region,
    'description': description,
    'cover_image_url': coverImageUrl,
    'categories': categories,
    'rating': rating,
    'reviews_count': reviewsCount,
    'is_verified': isVerified,
    'bank_account': bankAccount,
    'iban': iban,
    'jawwal_pay': jawwalPay,
    'pal_pay': palPay,
  };

  @override
  List<Object?> get props => [
    uid,
    name,
    phone,
    region,
    bankAccount,
    iban,
    jawwalPay,
    palPay,
  ];
}
