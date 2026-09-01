class ServiceCategoryModel {
  final int id;
  final String name;
  final String icon;

  ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}
