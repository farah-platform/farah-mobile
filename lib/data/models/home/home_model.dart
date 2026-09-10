import 'home_user_model.dart';
import 'category_model.dart';
import 'banner_model.dart';
import 'provider_model.dart';
import 'package_model.dart';
import 'popular_service_model.dart';

class HomeModel {
  final HomeUserModel? user;
  final List<CategoryModel> categories;
  final List<BannerModel> banners;
  final List<ProviderModel> suggestedProviders;
  final List<PackageModel> featuredPackages;
  final List<PopularServiceModel> mostPopular;
  final List<ProviderModel> featuredProviders;

  HomeModel({
    this.user,
    this.categories = const [],
    this.banners = const [],
    this.suggestedProviders = const [],
    this.featuredPackages = const [],
    this.mostPopular = const [],
    this.featuredProviders = const [],
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      user: json['user'] != null ? HomeUserModel.fromJson(json['user']) : null,

      categories:
          (json['categories'] as List?)
              ?.map((e) => CategoryModel.fromJson(e))
              .toList() ??
          [],

      banners:
          (json['banners'] as List?)
              ?.map((e) => BannerModel.fromJson(e))
              .toList() ??
          [],

      suggestedProviders:
          (json['suggested_providers'] as List?)
              ?.map((e) => ProviderModel.fromJson(e))
              .toList() ??
          [],

      featuredPackages:
          (json['featured_packages'] as List?)
              ?.map((e) => PackageModel.fromJson(e))
              .toList() ??
          [],

      mostPopular:
          (json['most_popular'] as List?)
              ?.map((e) => PopularServiceModel.fromJson(e))
              .toList() ??
          [],

      featuredProviders:
          (json['featured_providers'] as List?)
              ?.map((e) => ProviderModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
