class PopularServiceModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String currency;
  final String? image;
  final double ratingAvg;
  final int reviewsCount;
  final String location;
  final String city;
  final PopularProviderModel? provider;
  final PopularCategoryModel? category;

  PopularServiceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    this.image,
    required this.ratingAvg,
    required this.reviewsCount,
    required this.location,
    required this.city,
    this.provider,
    this.category,
  });

  factory PopularServiceModel.fromJson(Map<String, dynamic> json) {
    return PopularServiceModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? '',
      image: json['image'],
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      provider: json['provider'] != null
          ? PopularProviderModel.fromJson(json['provider'])
          : null,
      category: json['category'] != null
          ? PopularCategoryModel.fromJson(json['category'])
          : null,
    );
  }
}

class PopularProviderModel {
  final int id;
  final String name;
  final String? avatar;

  PopularProviderModel({required this.id, required this.name, this.avatar});

  factory PopularProviderModel.fromJson(Map<String, dynamic> json) {
    return PopularProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class PopularCategoryModel {
  final int id;
  final String name;

  PopularCategoryModel({required this.id, required this.name});

  factory PopularCategoryModel.fromJson(Map<String, dynamic> json) {
    return PopularCategoryModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
