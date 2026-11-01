import 'package:farah/data/models/service_model.dart';

// فرح: صفحة المزود العامة من GET /providers/{id}: بيانات المتجر وخدماته المنشورة فقط.
class PublicProviderModel {
  final int id;
  final String name;
  final String? avatar;
  final String? coverImage;
  final String? specialty;
  final String? description;
  final String? city;
  final String? address;
  final String? phone;
  final double rating;
  final int reviewsCount;
  final bool isBookable;
  final List<ServiceModel> services;

  const PublicProviderModel({
    required this.id,
    required this.name,
    this.avatar,
    this.coverImage,
    this.specialty,
    this.description,
    this.city,
    this.address,
    this.phone,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isBookable = false,
    this.services = const [],
  });

  factory PublicProviderModel.fromJson(Map<String, dynamic> json) {
    String? text(Object? value) {
      final s = value?.toString().trim() ?? '';
      return s.isEmpty ? null : s;
    }

    return PublicProviderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      avatar: text(json['avatar']),
      coverImage: text(json['cover_image']),
      specialty: text(json['specialty']),
      description: text(json['description']),
      city: text(json['city']),
      address: text(json['address']),
      phone: text(json['phone']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      isBookable: json['is_bookable'] == true,
      services: [
        for (final s in (json['services'] as List?) ?? const [])
          if (s is Map) ServiceModel.fromJson(Map<String, dynamic>.from(s)),
      ],
    );
  }
}
