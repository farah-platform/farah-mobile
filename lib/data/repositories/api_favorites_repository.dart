import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/data/models/favorite_item.dart';
import 'package:farah/data/repositories/favorites_repository.dart';

/// Favorites backed by GET /favorites and POST /favorites/toggle/{service_id}.
/// [FavoriteItem.id] holds the service id, since the API toggles by service.
class ApiFavoritesRepository implements FavoritesRepository {
  final Dio _dio;

  ApiFavoritesRepository({required DioClient dioClient}) : _dio = dioClient.dio;

  @override
  Future<List<FavoriteItem>> getFavorites() async {
    final res = await _dio.get('/favorites');
    return (res.data['data'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => FavoriteItem(
            id: e['service_id'].toString(),
            title: e['title']?.toString() ?? '',
            providerName:
                (e['provider'] is Map ? e['provider']['name'] : null)
                    ?.toString() ??
                '',
            rating: (e['rating_avg'] as num?)?.toDouble() ?? 0,
            price: (e['price'] as num?)?.toDouble() ?? 0,
            thumbnailUrl: e['image']?.toString(),
          ),
        )
        .toList();
  }

  @override
  Future<bool> toggle(String serviceId) async {
    final res = await _dio.post('/favorites/toggle/$serviceId');
    return res.data['is_favorited'] == true;
  }

  @override
  Future<void> remove(String id) async {
    final stillFavorited = await toggle(id);
    // The endpoint toggles; if the item was already gone it was just re-added.
    if (stillFavorited) await toggle(id);
  }

  // TODO: no bulk endpoint (e.g. DELETE /favorites) exists yet, so each
  // favorite is removed with its own toggle request.
  @override
  Future<void> removeAll() async {
    for (final item in await getFavorites()) {
      await toggle(item.id);
    }
  }
}
