import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String providerId;
  final String providerName;
  final String name;
  final String description;
  final String category;
  final double price;
  final String coverImageUrl;
  final double rating;
  final int reviewsCount;
  final String region;

  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.coverImageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.region,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
    id: map['id'] as String,
    providerId: map['provider_id'] as String,
    providerName: map['provider_name'] as String,
    name: map['name'] as String,
    description: map['description'] as String,
    category: map['category'] as String,
    price: (map['price'] as num).toDouble(),
    coverImageUrl: map['cover_image_url'] as String? ?? '',
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    reviewsCount: map['reviews_count'] as int? ?? 0,
    region: map['region'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'provider_id': providerId,
    'provider_name': providerName,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'cover_image_url': coverImageUrl,
    'rating': rating,
    'reviews_count': reviewsCount,
    'region': region,
  };

  @override
  List<Object?> get props => [id];
}
