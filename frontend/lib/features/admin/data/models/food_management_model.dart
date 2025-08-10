import '../../domain/entities/food_management_entity.dart';

class FoodTypeModel extends FoodTypeEntity {
  const FoodTypeModel({
    required super.id,
    required super.key,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.translations,
  });

  factory FoodTypeModel.fromJson(Map<String, dynamic> json) {
    return FoodTypeModel(
      id: json['id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['translations'] as List<dynamic>?)
          ?.map((e) => TranslationModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'translations': translations.map((e) => (e as TranslationModel).toJson()).toList(),
    };
  }
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.foodTypeId,
    required super.key,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.translations,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      foodTypeId: json['food_type_id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['translations'] as List<dynamic>?)
          ?.map((e) => TranslationModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_type_id': foodTypeId,
      'key': key,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'translations': translations.map((e) => (e as TranslationModel).toJson()).toList(),
    };
  }
}

class SubcategoryModel extends SubcategoryEntity {
  const SubcategoryModel({
    required super.id,
    required super.categoryId,
    required super.key,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.translations,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'],
      categoryId: json['category_id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['translations'] as List<dynamic>?)
          ?.map((e) => TranslationModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'key': key,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'translations': translations.map((e) => (e as TranslationModel).toJson()).toList(),
    };
  }
}

class ProteinTypeModel extends ProteinTypeEntity {
  const ProteinTypeModel({
    required super.id,
    required super.key,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.translations,
  });

  factory ProteinTypeModel.fromJson(Map<String, dynamic> json) {
    return ProteinTypeModel(
      id: json['id'],
      key: json['key'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['translations'] as List<dynamic>?)
          ?.map((e) => TranslationModel.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'translations': translations.map((e) => (e as TranslationModel).toJson()).toList(),
    };
  }
}

class TranslationModel extends TranslationEntity {
  const TranslationModel({
    required super.id,
    required super.language,
    required super.name,
    super.description,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'],
      language: json['language'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'name': name,
      'description': description,
    };
  }
}