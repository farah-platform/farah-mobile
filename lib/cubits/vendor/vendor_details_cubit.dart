import 'package:dio/dio.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/models/vendor/public_provider_model.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class VendorDetailsState {}

final class VendorDetailsInitial extends VendorDetailsState {}

final class VendorDetailsLoading extends VendorDetailsState {}

final class VendorDetailsLoaded extends VendorDetailsState {
  final PublicProviderModel provider;

  VendorDetailsLoaded(this.provider);

  String get vendorName => provider.name;
  String get specialty => provider.specialty ?? '';
  String? get avatar => provider.avatar;
  double get rating => provider.rating;
  List<ServiceModel> get services => provider.services;
}

final class VendorDetailsError extends VendorDetailsState {
  final String message;
  VendorDetailsError(this.message);
}

// فرح: صفحة المزود للعميل من GET /providers/{id}. بدون بيانات بديلة:
// إذا فشل التحميل تظهر رسالة خطأ مع "إعادة المحاولة".
class VendorDetailsCubit extends Cubit<VendorDetailsState> {
  final ServiceRepository _repository;

  VendorDetailsCubit(this._repository) : super(VendorDetailsInitial());

  /// [providerId] is the provider's account id (`user_id`).
  /// The other values are only shown in the title while loading.
  Future<void> loadVendorDetails({
    required String providerId,
    String? vendorName,
    String? avatar,
    num? rating,
  }) async {
    final id = int.tryParse(providerId);
    if (id == null) {
      emit(VendorDetailsError('تعذّر فتح صفحة المزود'));
      return;
    }
    emit(VendorDetailsLoading());
    try {
      final provider = await _repository.fetchPublicProvider(id);
      if (isClosed) return;
      emit(VendorDetailsLoaded(provider));
    } catch (e) {
      if (isClosed) return;
      emit(VendorDetailsError(_message(e)));
    }
  }

  String _message(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 404) {
        return 'هذا المزود غير متاح حالياً';
      }
      if (e.response == null) return 'تحقق من اتصالك بالإنترنت';
    }
    return 'تعذّر تحميل صفحة المزود، يرجى المحاولة مجدداً';
  }
}
