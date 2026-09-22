class BannerModel {
  final int id;
  final int serviceId;
  final String title;
  final String badge;
  final double price;
  final String currency;
  final String? image;
  final List<String> features;

  BannerModel({
    required this.id,
    required this.serviceId,
    required this.title,
    required this.badge,
    required this.price,
    required this.currency,
    this.image,
    required this.features,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      serviceId: json['service_id'],
      title: json['title'] ?? '',
      badge: json['badge'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'ILS',
      image: json['image'],
      features: (json['features'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
