import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderExternalBookingState {
  final List<Map<String, dynamic>> services;

  /// Days of the shown month already taken for the chosen service (YYYY-MM-DD).
  final Set<String> takenDates;
  final bool loading;
  final bool loadingDates;
  final bool saving;
  final bool saved;
  final String? error;

  const ProviderExternalBookingState({
    this.services = const [],
    this.takenDates = const {},
    this.loading = true,
    this.loadingDates = false,
    this.saving = false,
    this.saved = false,
    this.error,
  });

  ProviderExternalBookingState copyWith({
    List<Map<String, dynamic>>? services,
    Set<String>? takenDates,
    bool? loading,
    bool? loadingDates,
    bool? saving,
    bool? saved,
    String? error,
  }) {
    return ProviderExternalBookingState(
      services: services ?? this.services,
      takenDates: takenDates ?? this.takenDates,
      loading: loading ?? this.loading,
      loadingDates: loadingDates ?? this.loadingDates,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      error: error,
    );
  }
}

/// "إضافة حجز خارجي": the provider's services, their taken dates, and saving.
class ProviderExternalBookingCubit extends Cubit<ProviderExternalBookingState> {
  final ProviderRepository _repository;

  ProviderExternalBookingCubit(this._repository)
    : super(const ProviderExternalBookingState());

  Future<void> load() async {
    try {
      final services = await _repository.getProviderServices();
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          services: [
            for (final s in services)
              if (s is Map) Map<String, dynamic>.from(s),
          ],
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: providerOrderError(e, 'تعذّر تحميل خدماتك'),
        ),
      );
    }
  }

  /// Blocked and reserved days of [month] (YYYY-MM) for [serviceId].
  Future<void> loadTakenDates(int serviceId, String month) async {
    emit(state.copyWith(loadingDates: true, takenDates: {}));
    try {
      final data = await _repository.getServiceAvailability(serviceId, month);
      if (isClosed) return;
      final reserved = data['reserved_dates'];
      emit(
        state.copyWith(
          loadingDates: false,
          takenDates: {
            for (final d in (data['unavailable_dates'] as List?) ?? const [])
              if (d is Map) d['date'].toString(),
            if (reserved is Map) ...reserved.keys.map((k) => k.toString()),
          },
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loadingDates: false,
          error: providerOrderError(e, 'تعذّر تحميل المواعيد'),
        ),
      );
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      await _repository.addExternalBooking(data);
      if (isClosed) return;
      emit(state.copyWith(saving: false, saved: true));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          saving: false,
          error: providerOrderError(e, 'تعذّر حفظ الحجز'),
        ),
      );
    }
  }
}
