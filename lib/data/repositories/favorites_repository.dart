import 'package:farah/data/models/favorite_item.dart';

/// Abstract interface for favorites operations.
abstract class FavoritesRepository {
  Future<List<FavoriteItem>> getFavorites();
  Future<void> removeAll();
  Future<void> remove(String id);

  /// Returns whether the service is favorited after the toggle.
  Future<bool> toggle(String serviceId);
}
