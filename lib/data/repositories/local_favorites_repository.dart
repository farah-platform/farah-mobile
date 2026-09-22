// TODO: Replace with a real backend endpoint once the favorites API is available.
import 'package:farah/data/models/favorite_item.dart';
import 'package:farah/data/repositories/favorites_repository.dart';

/// Local stub implementation of [FavoritesRepository].
/// Always returns an empty list until the backend favorites API is implemented.
class LocalFavoritesRepository implements FavoritesRepository {
  @override
  Future<List<FavoriteItem>> getFavorites() async => const [];

  @override
  Future<void> removeAll() async {}

  @override
  Future<void> remove(String id) async {}
}
