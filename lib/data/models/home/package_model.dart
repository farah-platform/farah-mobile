class PackageModel {
  final int id;
  final String title;
  final String? image;
  final String? discountBadge;
  final double discountPercentage;
  final double price;
  final double originalPrice;
  final String currency;
  final double ratingAvg;
  final int reviewsCount;
  final PackageProviderModel? provider;
  final PackageCategoryModel? category;

  PackageModel({
    required this.id,
    required this.title,
    this.image,
    this.discountBadge,
    required this.discountPercentage,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.ratingAvg,
    required this.reviewsCount,
    this.provider,
    this.category,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'],
      discountBadge: json['discount_badge'],
      discountPercentage:
          (json['discount_percentage'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? '',
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviews_count'] ?? 0,
      provider: json['provider'] != null
          ? PackageProviderModel.fromJson(json['provider'])
          : null,
      category: json['category'] != null
          ? PackageCategoryModel.fromJson(json['category'])
          : null,
    );
  }
}

class PackageProviderModel {
  final int id;
  final String name;
  final String? avatar;

  PackageProviderModel({required this.id, required this.name, this.avatar});

  factory PackageProviderModel.fromJson(Map<String, dynamic> json) {
    return PackageProviderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class PackageCategoryModel {
  final int id;
  final String name;

  PackageCategoryModel({required this.id, required this.name});

  factory PackageCategoryModel.fromJson(Map<String, dynamic> json) {
    return PackageCategoryModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}
