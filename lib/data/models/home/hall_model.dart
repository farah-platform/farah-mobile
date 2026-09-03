class HallModel {
  final int id;
  final String name;
  final String image;
  final double price;
  final String location;
  final double rating;

  HallModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.location,
    required this.rating,
  });

  factory HallModel.fromJson(Map<String, dynamic> json) {
    return HallModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      location: json['location'],
      rating: (json['rating'] as num).toDouble(),
    );
  }
}
