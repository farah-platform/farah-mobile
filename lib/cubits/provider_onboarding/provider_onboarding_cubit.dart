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
    emit(ProviderOnboardingLoading());
    try {
      // Mocking categories and cities fetch since endpoints are missing in repositories or we can just fetch them via Dio.
      // Wait, HomeRepository might have categories. Let's just emit empty for now and let the UI handle or use DioClient.
      // Since we don't have a direct CityRepository, we'll just mock them for now.
      
      final categories = [
        {'id': 1, 'name': 'صالات أفراح'},
        {'id': 2, 'name': 'كوافير'},
        {'id': 3, 'name': 'دي جي'},
      ];
      final cities = [
        {'id': 1, 'name': 'شمال غزة'},
        {'id': 2, 'name': 'وسط غزة'},
        {'id': 3, 'name': 'جنوب غزة'},
      ];

      emit(ProviderOnboardingLoaded(categories: categories, cities: cities));
    } catch (e) {
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
      
      emit(ProviderOnboardingSuccess());
    } catch (e) {
      emit(ProviderOnboardingError('حدث خطأ أثناء حفظ البيانات'));
    }
  }
}
