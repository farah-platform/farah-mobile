class ServiceCategoryModel {
  final int id;
  final String name;
  final String? slug;
  final String? image;
  final String status;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    this.slug,
    this.image,
    required this.status,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      image: json['image'],
      status: json['status'] ?? '',
    );
  }
}
