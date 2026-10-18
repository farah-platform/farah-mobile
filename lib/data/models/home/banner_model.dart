class BannerModel {
  final int id;
  final int serviceId;
  final String title;
  final String? badge;
  final double price;
  final String currency;
  final String? image;
  final List<String> features;

  BannerModel({
    required this.id,
    required this.serviceId,
    required this.title,
    this.badge,
    required this.price,
    required this.currency,
    this.image,
    this.features = const [],
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      title: json['title'] ?? '',
      badge: json['badge'],
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? '',
      image: json['image'],
      features:
          (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
