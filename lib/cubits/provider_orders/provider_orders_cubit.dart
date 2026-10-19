import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'provider_order_errors.dart';

abstract class ProviderOrdersState {
  /// Workflow status filter; null shows every order.
  final String? status;
  const ProviderOrdersState(this.status);
}

class ProviderOrdersLoading extends ProviderOrdersState {
  const ProviderOrdersLoading(super.status);
}

class ProviderOrdersLoaded extends ProviderOrdersState {
  final List<Map<String, dynamic>> orders;
  const ProviderOrdersLoaded(super.status, this.orders);
}

class ProviderOrdersError extends ProviderOrdersState {
  final String message;
  const ProviderOrdersError(super.status, this.message);
}

/// The provider's "الطلبات" tab.
class ProviderOrdersCubit extends Cubit<ProviderOrdersState> {
  final ProviderRepository _repository;

  ProviderOrdersCubit(this._repository)
    : super(const ProviderOrdersLoading(null));

  Future<void> load({String? status}) async {
    if (isClosed) return;
    emit(ProviderOrdersLoading(status));
    try {
      final orders = await _repository.getProviderBookings(status: status);
      if (isClosed) return;
      emit(
        ProviderOrdersLoaded(status, [
          for (final o in orders)
            if (o is Map) Map<String, dynamic>.from(o),
        ]),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderOrdersError(
          status,
          providerOrderError(e, 'تعذّر تحميل الطلبات'),
        ),
      );
    }
  }

  Future<void> refresh() => load(status: state.status);
}
