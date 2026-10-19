/// A service or package as returned by GET /provider/services.
class ProviderServiceModel {
  final int id;
  final String title;
  final bool isPackage;
  final double price;
  final double? originalPrice;
  final String currency;
  final String? coverImage;
  final String? executionDuration;
  final bool isPublished;
  final bool isDraft;
  final Map<String, dynamic> raw;

  const ProviderServiceModel({
    required this.id,
    required this.title,
    required this.isPackage,
    required this.price,
    required this.originalPrice,
    required this.currency,
    required this.coverImage,
    required this.executionDuration,
    required this.isPublished,
    required this.isDraft,
    required this.raw,
  });

  factory ProviderServiceModel.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] is Map ? json['pricing'] as Map : const {};
    double? number(dynamic v) => v == null ? null : num.tryParse(v.toString())?.toDouble();
    final cover = json['cover_image']?.toString();

    return ProviderServiceModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      isPackage: json['type'] == 'package',
      price: number(pricing['price']) ?? 0,
      originalPrice: number(pricing['original_price']),
      currency: pricing['currency']?.toString() ?? 'ILS',
      coverImage: cover == null || cover.isEmpty ? null : cover,
      executionDuration: (json['execution_duration']?.toString() ?? '').trim().isEmpty
          ? null
          : json['execution_duration'].toString(),
      isPublished: json['is_published'] == true,
      isDraft: json['is_draft'] == true,
      raw: json,
    );
  }

  String get priceLabel {
    final value = price == price.roundToDouble() ? price.toInt().toString() : price.toString();
    return '$value$currency';
  }
}
