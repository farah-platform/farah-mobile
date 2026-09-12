part of 'favorites_cubit.dart';

sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

final class FavoritesLoading extends FavoritesState {}

final class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> items;
  FavoritesLoaded(this.items);
}

final class FavoritesError extends FavoritesState {
  final String message;
  FavoritesError(this.message);
}
