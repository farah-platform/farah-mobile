import 'package:dio/dio.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderServiceEditorState {}

class ProviderServiceEditorIdle extends ProviderServiceEditorState {}

class ProviderServiceEditorAvailabilityLoading
    extends ProviderServiceEditorState {}

/// Dates of [month] (YYYY-MM) the provider blocked or customers reserved.
class ProviderServiceEditorAvailability extends ProviderServiceEditorState {
  final String month;
  final Set<String> blocked;
  final Set<String> reserved;
  ProviderServiceEditorAvailability({
    required this.month,
    required this.blocked,
    required this.reserved,
  });
}

class ProviderServiceEditorSaving extends ProviderServiceEditorState {}

class ProviderServiceEditorSaved extends ProviderServiceEditorState {}

class ProviderServiceEditorDeleted extends ProviderServiceEditorState {}

class ProviderServiceEditorError extends ProviderServiceEditorState {
  final String message;
  ProviderServiceEditorError(this.message);
}

/// Edit service/package screen: saving, deleting and the available-dates calendar.
class ProviderServiceEditorCubit extends Cubit<ProviderServiceEditorState> {
  final ProviderRepository _repository;

  ProviderServiceEditorCubit(this._repository)
    : super(ProviderServiceEditorIdle());

  Future<void> loadAvailability(int serviceId, String month) async {
    if (isClosed) return;
    emit(ProviderServiceEditorAvailabilityLoading());
    try {
      final data = await _repository.getServiceAvailability(serviceId, month);
      if (isClosed) return;
      final reserved = data['reserved_dates'];
      emit(
        ProviderServiceEditorAvailability(
          month: month,
          blocked: {
            for (final d in (data['unavailable_dates'] as List?) ?? const [])
              if (d is Map) d['date'].toString(),
          },
          reserved: reserved is Map
              ? reserved.keys.map((k) => k.toString()).toSet()
              : <String>{},
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServiceEditorError(_mapError(e, 'تعذّر تحميل المواعيد')));
    }
  }

  Future<void> save({
    required int serviceId,
    required Map<String, dynamic> data,
    required List<dynamic> newImages,
    List<String> blockDates = const [],
    List<String> unblockDates = const [],
  }) async {
    if (isClosed) return;
    emit(ProviderServiceEditorSaving());
    try {
      await _repository.updateProviderService(serviceId, data, newImages);
      if (blockDates.isNotEmpty || unblockDates.isNotEmpty) {
        await _repository.updateServiceAvailability(
          serviceId,
          block: blockDates,
          unblock: unblockDates,
        );
      }
      if (isClosed) return;
      emit(ProviderServiceEditorSaved());
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderServiceEditorError(_mapError(e, 'حدث خطأ أثناء حفظ التعديلات')),
      );
    }
  }

  Future<void> delete(int serviceId) async {
    if (isClosed) return;
    emit(ProviderServiceEditorSaving());
    try {
      await _repository.deleteProviderService(serviceId);
      if (isClosed) return;
      emit(ProviderServiceEditorDeleted());
    } catch (e) {
      if (isClosed) return;
      emit(ProviderServiceEditorError(_mapError(e, 'تعذّر حذف الخدمة')));
    }
  }

  String _mapError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final message = (data['title'] ?? data['message'])?.toString();
        if (message != null && message.isNotEmpty) return message;
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'تحقق من اتصالك بالإنترنت';
      }
    }
    return fallback;
  }
}
