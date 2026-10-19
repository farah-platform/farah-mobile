import 'package:equatable/equatable.dart';

class FavoriteItem extends Equatable {
  final String id;
  final String title;
  final String providerName;
  final double rating;
  final double price;
  final String? thumbnailUrl;

  const FavoriteItem({
    required this.id,
    required this.title,
    required this.providerName,
    required this.rating,
    required this.price,
    this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [id];
}
