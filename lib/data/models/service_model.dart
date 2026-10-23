import 'package:farah/data/models/home/service_category_model.dart';
import 'package:farah/data/models/service_provider_model.dart';

class ServiceModel {
  final int id;
  final String title;
  final String description;

  final List<String> features;
  // فرح: المزايا اللي سمح المزود بإزالتها (removable_features من السيرفر). الباقي مشمول دائماً.
  final List<String> removableFeatures;

  final int capacity;
  final double area;
  final String areaUnit;

  final List<BookingSlotModel> bookingSlots;

  final double price;
  final String currency;

  final String? image;
  final List<String> images;

  final double ratingAvg;
  final int reviewsCount;

  final String location;
  final String city;

  final bool isFavorited;

  final ServiceCategoryModel? category;
  final ServiceProviderModel? provider;

  final List<ServiceReviewModel> reviews;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.features,
    this.removableFeatures = const [],
    required this.capacity,
    required this.area,
    required this.areaUnit,
    required this.bookingSlots,
    required this.price,
    required this.currency,
    this.image,
    required this.images,
    required this.ratingAvg,
    required this.reviewsCount,
    required this.location,
    required this.city,
    required this.isFavorited,
    this.category,
    this.provider,
    required this.reviews,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,

      title: json['title'] ?? '',

      description: json['description'] ?? '',

      features: List<String>.from(json['features'] ?? []),
      removableFeatures: List<String>.from(json['removable_features'] ?? []),

      capacity: json['capacity'] ?? 0,

      area: (json['area'] as num?)?.toDouble() ?? 0,

      areaUnit: json['area_unit'] ?? '',

      bookingSlots:
          (json['booking_slots'] as List?)
              ?.map((e) => BookingSlotModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      price: (json['price'] as num?)?.toDouble() ?? 0,

      currency: json['currency'] ?? '',

      image: json['image'],

      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],

      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,

      reviewsCount: json['reviews_count'] ?? 0,

      location: json['location'] ?? '',

      city: json['city'] ?? '',

      isFavorited: json['is_favorited'] ?? false,

      category: json['category'] != null
          ? ServiceCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>,
            )
          : null,

      provider: json['provider'] != null
          ? ServiceProviderModel.fromMap(
              json['provider'] as Map<String, dynamic>,
            )
          : null,

      reviews:
          (json['reviews'] as List?)
              ?.map(
                (e) => ServiceReviewModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class BookingSlotModel {
  final String label;
  final String startTime;
  final String endTime;

  BookingSlotModel({
    required this.label,
    required this.startTime,
    required this.endTime,
  });

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      label: json['label'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class ServiceReviewModel {
  final int id;
  final double rating;
  final String comment;
  final String userName;
  final String createdAt;

  ServiceReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory ServiceReviewModel.fromJson(Map<String, dynamic> json) {
    return ServiceReviewModel(
      id: json['id'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] ?? '',
      userName: json['user_name'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
