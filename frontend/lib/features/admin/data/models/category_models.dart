import '../../domain/entities/category_entities.dart';

class FoodTypeModel {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationModel> translations;

  const FoodTypeModel({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  factory FoodTypeModel.fromJson(Map<String, dynamic> json) {
    return FoodTypeModel(
      id: json['id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['Translations'] as List<dynamic>? ?? [])
          .map((t) => TranslationModel.fromJson(t))
          .toList(),
    );
  }

  FoodTypeEntity toEntity() {
    final englishTranslation = translations
        .where((t) => t.language == 'en')
        .firstOrNull;

    return FoodTypeEntity(
      id: id,
      key: key,
      name: englishTranslation?.name ?? key,
      description: englishTranslation?.description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CategoryModel {
  final int id;
  final int foodTypeId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationModel> translations;

  const CategoryModel({
    required this.id,
    required this.foodTypeId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      foodTypeId: json['food_type_id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['Translations'] as List<dynamic>? ?? [])
          .map((t) => TranslationModel.fromJson(t))
          .toList(),
    );
  }

  CategoryEntity toEntity() {
    final englishTranslation = translations
        .where((t) => t.language == 'en')
        .firstOrNull;

    return CategoryEntity(
      id: id,
      foodTypeId: foodTypeId,
      key: key,
      name: englishTranslation?.name ?? key,
      description: englishTranslation?.description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class SubcategoryModel {
  final int id;
  final int categoryId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationModel> translations;

  const SubcategoryModel({
    required this.id,
    required this.categoryId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'],
      categoryId: json['category_id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['Translations'] as List<dynamic>? ?? [])
          .map((t) => TranslationModel.fromJson(t))
          .toList(),
    );
  }

  SubcategoryEntity toEntity() {
    final englishTranslation = translations
        .where((t) => t.language == 'en')
        .firstOrNull;

    return SubcategoryEntity(
      id: id,
      categoryId: categoryId,
      key: key,
      name: englishTranslation?.name ?? key,
      description: englishTranslation?.description,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class TranslationModel {
  final int id;
  final String language;
  final String name;
  final String? description;

  const TranslationModel({
    required this.id,
    required this.language,
    required this.name,
    this.description,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'],
      language: json['language'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class ApiResponseModel<T> {
  final int statusCode;
  final String message;
  final T data;

  const ApiResponseModel({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) dataParser,
  ) {
    return ApiResponseModel(
      statusCode: json['statusCode'],
      message: json['message'],
      data: dataParser(json['data']),
    );
  }
}