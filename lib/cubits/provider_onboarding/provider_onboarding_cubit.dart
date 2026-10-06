import 'dart:io';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/data/repositories/home_repostory.dart';
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
  final HomeRepository _homeRepository;

  ProviderOnboardingCubit(this._providerRepository, this._homeRepository) : super(ProviderOnboardingInitial());

  Future<void> loadData() async {
    if (isClosed) return;
    emit(ProviderOnboardingLoading());
    try {
      final categories = await _homeRepository.getCategories();
      final cities = await _homeRepository.getCities();

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
        'profit_account': profitAccount,
        'commercial_register': commercialRegister ?? '',
      }, idProof, coverImage);
      
      if (isClosed) return;
      emit(ProviderOnboardingSuccess());
    } catch (e) {
      if (isClosed) return;
      emit(ProviderOnboardingError('حدث خطأ أثناء حفظ البيانات'));
    }
  }
}
