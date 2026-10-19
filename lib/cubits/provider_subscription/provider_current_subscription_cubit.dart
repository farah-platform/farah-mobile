import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderCurrentSubscriptionState {
  /// Latest subscription from GET /provider/subscription (with `plan`).
  final Map<String, dynamic>? subscription;
  final bool loading;
  final bool canceling;
  final String? message;
  final String? error;

  const ProviderCurrentSubscriptionState({
    this.subscription,
    this.loading = true,
    this.canceling = false,
    this.message,
    this.error,
  });

  ProviderCurrentSubscriptionState copyWith({
    Map<String, dynamic>? subscription,
    bool clearSubscription = false,
    bool? loading,
    bool? canceling,
    String? message,
    String? error,
  }) {
    return ProviderCurrentSubscriptionState(
      subscription: clearSubscription
          ? null
          : subscription ?? this.subscription,
      loading: loading ?? this.loading,
      canceling: canceling ?? this.canceling,
      message: message,
      error: error,
    );
  }
}

// فرح: شاشة "الاشتراك الحالي": تحميل الاشتراك وإلغاؤه.
class ProviderCurrentSubscriptionCubit
    extends Cubit<ProviderCurrentSubscriptionState> {
  final ProviderRepository _repository;

  ProviderCurrentSubscriptionCubit(this._repository)
    : super(const ProviderCurrentSubscriptionState());

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final subscription = await _repository.getCurrentSubscription();
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          subscription: subscription,
          clearSubscription: subscription == null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          error: providerOrderError(e, 'تعذّر تحميل الاشتراك'),
        ),
      );
    }
  }

  Future<void> cancel() async {
    if (state.canceling) return;
    emit(state.copyWith(canceling: true));
    try {
      await _repository.cancelSubscription();
      final subscription = await _repository.getCurrentSubscription();
      if (isClosed) return;
      emit(
        state.copyWith(
          canceling: false,
          subscription: subscription,
          clearSubscription: subscription == null,
          message: 'تم إلغاء الاشتراك',
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          canceling: false,
          error: providerOrderError(e, 'تعذّر إلغاء الاشتراك'),
        ),
      );
    }
  }
}
