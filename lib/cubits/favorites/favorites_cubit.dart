import 'package:dio/dio.dart';
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

  /// Toggles a service from its detail page. Returns an error message, or
  /// null on success. The list state is refreshed the next time it loads.
  Future<String?> toggle(String serviceId) async {
    try {
      await _repo.toggle(serviceId);
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'سجّل الدخول لإضافة الخدمة إلى المفضلة';
      }
      final data = e.response?.data;
      if (data is Map) {
        final message = (data['title'] ?? data['message'])?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
      return 'تعذّر تحديث المفضلة، يرجى المحاولة مجدداً';
    } catch (_) {
      return 'تعذّر تحديث المفضلة، يرجى المحاولة مجدداً';
    }
  }
}
