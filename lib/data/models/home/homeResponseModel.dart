import 'package:farah/data/models/home/userhome_model.dart';
import 'package:farah/data/models/home/service_category_model.dart';
import 'package:farah/data/models/home/banner_model.dart';
import 'package:farah/data/models/home/provider_model.dart';
import 'package:farah/data/models/home/package_model.dart';
import 'package:farah/data/models/home/popular_service_model.dart';

class HomeResponseModel {
  final UserHomeModel? user;
  final List<ServiceCategoryModel> categories;
  final List<BannerModel> banners;
  final List<ProviderModel> suggestedProviders;
  final List<PackageModel> featuredPackages;
  final List<PopularServiceModel> mostPopular;
  final List<dynamic> featuredProviders;
  final List<dynamic> services;

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
      categories:
          (json['categories'] as List?)
              ?.where((e) => e is Map<String, dynamic> && e['id'] != null)
              .map((e) => ServiceCategoryModel.fromJson(e))
              .toList() ??
          [],
      banners:
          (json['banners'] as List?)
              ?.where((e) => e is Map<String, dynamic> && e['id'] != null)
              .map((e) => BannerModel.fromJson(e))
              .toList() ??
          [],
      suggestedProviders:
          (json['suggested_providers'] as List?)
              ?.where((e) => e is Map<String, dynamic> && e['id'] != null)
              .map((e) => ProviderModel.fromJson(e))
              .toList() ??
          [],
      featuredPackages:
          (json['featured_packages'] as List?)
              ?.where((e) => e is Map<String, dynamic> && e['id'] != null)
              .map((e) => PackageModel.fromJson(e))
              .toList() ??
          [],
      mostPopular:
          (json['most_popular'] as List?)
              ?.where((e) => e is Map<String, dynamic> && e['id'] != null)
              .map((e) => PopularServiceModel.fromJson(e))
              .toList() ??
          [],
      featuredProviders:
          (json['featured_providers'] as List?)
              ?.where((e) => e is Map && e.isNotEmpty)
              .toList() ??
          [],
      services:
          (json['services'] as List?)
              ?.where((e) => e is Map && e.isNotEmpty)
              .toList() ??
          [],
    );
  }
}
