class ServiceModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String? image;
  final List<String> images;
  final double ratingAvg;
  final int reviewsCount;
  final String location;
  final String city;
  final bool isFavorited;
  final String buttonText;
  final ServiceProviderModel? provider;
  final ServiceCategoryModel? category;

  ServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    this.image,
    this.images = const [],
    required this.ratingAvg,
    required this.reviewsCount,
    required this.location,
    required this.city,
    required this.isFavorited,
    required this.buttonText,
    this.provider,
    this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
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
      buttonText: json['button_text'] ?? '',
      provider: json['provider'] != null
          ? ServiceProviderModel.fromJson(json['provider'])
          : null,
      category: json['category'] != null
          ? ServiceCategoryModel.fromJson(json['category'])
          : null,
    );
  }
}

class ServiceProviderModel {
  final int id;
  final String name;
  final String? avatar;

  ServiceProviderModel({required this.id, required this.name, this.avatar});

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    return ServiceProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class ServiceCategoryModel {
  final int id;
  final String name;
  final String slug;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
