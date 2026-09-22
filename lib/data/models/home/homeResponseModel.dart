import 'package:farah/data/models/user_model.dart' show UserModel;
import 'service_category_model.dart';
import 'banner_model.dart';
import 'provider_model.dart';
import 'package_model.dart';
import 'popular_service_model.dart';
import 'userhome_model.dart';

class HomeResponseModel {
  final UserHomeModel? user;
  final List<ServiceCategoryModel> categories;
  final List<BannerModel> banners;
  final List<ProviderModel> suggestedProviders;
  final List<PackageModel> featuredPackages;
  final List<PopularServiceModel> mostPopular;
  final List<ProviderModel> featuredProviders;
  final List<PopularServiceModel> services;

  HomeResponseModel({
    this.user,
    required this.categories,
    required this.banners,
    required this.suggestedProviders,
    required this.featuredPackages,
    required this.mostPopular,
    required this.featuredProviders,
    required this.services,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    return HomeResponseModel(
      user: json['user'] != null ? UserHomeModel.fromJson(json['user']) : null,

      categories: (json['categories'] as List? ?? [])
          .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      banners: (json['banners'] as List? ?? [])
          .map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      suggestedProviders: (json['suggested_providers'] as List? ?? [])
          .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      featuredPackages: (json['featured_packages'] as List? ?? [])
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      mostPopular: (json['most_popular'] as List? ?? [])
          .map((e) => PopularServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      featuredProviders: (json['featured_providers'] as List? ?? [])
          .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      services: (json['services'] as List? ?? [])
          .map((e) => PopularServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
