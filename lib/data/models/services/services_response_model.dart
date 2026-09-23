import 'package:farah/data/models/service_model.dart';

class ServicesResponseModel {
  final ServicesCategoryModel? category;
  final List<ServicesSortModel> availableSorts;
  final String activeSort;
  final List<ServiceModel> data;
  final PaginationModel? pagination;

  ServicesResponseModel({
    this.category,
    this.availableSorts = const [],
    required this.activeSort,
    this.data = const [],
    this.pagination,
  });

  factory ServicesResponseModel.fromJson(Map<String, dynamic> json) {
    return ServicesResponseModel(
      category: json['category'] != null
          ? ServicesCategoryModel.fromJson(json['category'])
          : null,
      availableSorts:
          (json['available_sorts'] as List?)
              ?.map((e) => ServicesSortModel.fromJson(e))
              .toList() ??
          [],
      activeSort: json['active_sort'] ?? 'all',
      data:
          (json['data'] as List?)
              ?.map((e) => ServiceModel.fromJson(e))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

class ServicesCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;

  ServicesCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
  });

  factory ServicesCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServicesCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
    );
  }
}

class ServicesSortModel {
  final String key;
  final String label;

  ServicesSortModel({required this.key, required this.label});

  factory ServicesSortModel.fromJson(Map<String, dynamic> json) {
    return ServicesSortModel(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  PaginationModel({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }
}
