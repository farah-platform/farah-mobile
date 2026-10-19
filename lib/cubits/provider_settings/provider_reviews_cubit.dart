import 'package:farah/cubits/provider_orders/provider_order_errors.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderReviewsState {}

class ProviderReviewsLoading extends ProviderReviewsState {}

class ProviderReviewsLoaded extends ProviderReviewsState {
  final List<Map<String, dynamic>> reviews;
  ProviderReviewsLoaded(this.reviews);
}

class ProviderReviewsError extends ProviderReviewsState {
  final String message;
  ProviderReviewsError(this.message);
}

/// "تقييماتي": customer reviews on the provider's services.
class ProviderReviewsCubit extends Cubit<ProviderReviewsState> {
  final ProviderRepository _repository;

  ProviderReviewsCubit(this._repository) : super(ProviderReviewsLoading());

  Future<void> load() async {
    emit(ProviderReviewsLoading());
    try {
      final reviews = await _repository.getProviderReviews();
      if (isClosed) return;
      emit(
        ProviderReviewsLoaded([
          for (final r in reviews)
            if (r is Map) Map<String, dynamic>.from(r),
        ]),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        ProviderReviewsError(providerOrderError(e, 'تعذّر تحميل التقييمات')),
      );
    }
  }
}
