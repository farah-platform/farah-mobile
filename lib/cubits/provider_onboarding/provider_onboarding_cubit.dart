import 'dart:io';
import 'package:dio/dio.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ProviderOnboardingState {}

class ProviderOnboardingInitial extends ProviderOnboardingState {}
class ProviderOnboardingLoading extends ProviderOnboardingState {}
class ProviderOnboardingLoaded extends ProviderOnboardingState {
  final List<dynamic> categories;
  final List<dynamic> cities;
  ProviderOnboardingLoaded({required this.categories, required this.cities});
}
class ProviderOnboardingSaving extends ProviderOnboardingState {}
class ProviderOnboardingSuccess extends ProviderOnboardingState {}
class ProviderOnboardingError extends ProviderOnboardingState {
  final String message;
  ProviderOnboardingError(this.message);
}

class ProviderOnboardingCubit extends Cubit<ProviderOnboardingState> {
  final ProviderRepository _providerRepository;

  ProviderOnboardingCubit(this._providerRepository) : super(ProviderOnboardingInitial());

  Future<void> loadData() async {
    if (isClosed) return;
    emit(ProviderOnboardingLoading());
    try {
      final results = await Future.wait([
        _providerRepository.getCategories(),
        _providerRepository.getCities(),
      ]);
      final categories = results[0];
      final cities = results[1];

      if (isClosed) return;
      emit(ProviderOnboardingLoaded(categories: categories, cities: cities));
    } catch (e) {
      if (isClosed) return;
      emit(ProviderOnboardingError('فشل في جلب البيانات'));
    }
  }

  Future<void> submit({
    required String businessName,
    required String categoryId,
    required String description,
    required String cityId,
    required String address,
    required File idProof,
    required String profitAccount,
    String? commercialRegister,
    required File coverImage,
  }) async {
    if (isClosed) return;
    emit(ProviderOnboardingSaving());
    try {
      await _providerRepository.submitOnboardingData({
        'business_name': businessName,
        'category_id': categoryId,
        'description': description,
        'city_id': cityId,
        'address': address,
        // TODO: the API has no earnings-account field yet; it ignores this value.
        'profit_account': profitAccount,
        // TODO: the API expects commercial_register as a file, not a number,
        // so the typed number is not sent until the two sides agree.
      }, idProof, coverImage);
      
      if (isClosed) return;
      emit(ProviderOnboardingSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(ProviderOnboardingError(_mapError(e, 'حدث خطأ أثناء حفظ البيانات')));
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
