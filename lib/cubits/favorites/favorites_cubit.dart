import 'package:farah/data/models/favorite_item.dart';
import 'package:farah/data/repositories/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repo;

  FavoritesCubit(this._repo) : super(FavoritesInitial());

  Future<void> load() async {
    emit(FavoritesLoading());
    try {
      final items = await _repo.getFavorites();
      emit(FavoritesLoaded(items));
    } catch (_) {
      emit(FavoritesError('تعذّر تحميل المفضلة، يرجى المحاولة مجدداً'));
    }
  }

  Future<void> removeAll() async {
    final current = state;
    if (current is! FavoritesLoaded) return;
    try {
      await _repo.removeAll();
      emit(FavoritesLoaded(const []));
    } catch (_) {
      emit(FavoritesError('تعذّر حذف العناصر، يرجى المحاولة مجدداً'));
    }
  }

  Future<void> remove(String id) async {
    final current = state;
    if (current is! FavoritesLoaded) return;
    try {
      await _repo.remove(id);
      final updated = current.items.where((e) => e.id != id).toList();
      emit(FavoritesLoaded(updated));
    } catch (_) {
      emit(FavoritesError('تعذّر حذف العنصر، يرجى المحاولة مجدداً'));
    }
  }
}
