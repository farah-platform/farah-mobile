class ProviderModel {
  final int id;
  final int userId;
  final String name;
  final String businessName;
  final String? avatar;
  final String specialty;
  final String categoryName;
  final double rating;
  final String city;
  final bool isFeatured;

  ProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.businessName,
    this.avatar,
    required this.specialty,
    required this.categoryName,
    required this.rating,
    required this.city,
    required this.isFeatured,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      businessName: json['business_name'] ?? '',
      avatar: json['avatar'],
      specialty: json['specialty'] ?? '',
      categoryName: json['category_name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      city: json['city'] ?? '',
      isFeatured: json['is_featured'] ?? false,
    );
  }
}
