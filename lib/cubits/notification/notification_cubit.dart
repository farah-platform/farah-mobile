import 'package:dio/dio.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/data/repositories/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repo;

  NotificationCubit(this._repo) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final notifications = await _repo.fetchNotifications();
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError(_mapError(e)));
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    try {
      await _repo.markAsRead(id);
      final updated = current.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(NotificationsLoaded(updated));
    } catch (_) {
      // فرح: فشل تعليم إشعار كمقروء ما لازم يخفي القائمة كلها ويطلع شاشة خطأ.
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;
    try {
      await _repo.markAllAsRead();
      final updated = current.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(NotificationsLoaded(updated));
    } catch (e) {
      emit(NotificationError(_mapError(e)));
    }
  }

  String _mapError(Object e) {
    if (e is DioException && e.type == DioExceptionType.connectionError) {
      return 'تحقق من اتصالك بالإنترنت';
    }
    return 'حدث خطأ، يرجى المحاولة مجدداً';
  }
}
