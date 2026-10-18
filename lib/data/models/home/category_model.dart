class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String status;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    required this.status,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      status: json['status'] ?? '',
    );
  }
}
