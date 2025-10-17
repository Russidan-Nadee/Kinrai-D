import '../../domain/entities/menu_entity.dart';

/// Menu Model - Data layer for API/Database mapping
class MenuModel {
  final int id;
  final int subcategoryId;
  final int? proteinTypeId;
  final String key;
  final String? imageUrl;
  final Map<String, dynamic>? contains;
  final String mealTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? name;
  final List<MenuTranslationModel>? translations;
  final MenuSubcategoryModel? subcategory;
  final MenuProteinTypeModel? proteinType;
  final double? averageRating;
  final int? totalRatings;

  MenuModel({
    required this.id,
    required this.subcategoryId,
    this.proteinTypeId,
    required this.key,
    this.imageUrl,
    this.contains,
    required this.mealTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.translations,
    this.subcategory,
    this.proteinType,
    this.averageRating,
    this.totalRatings,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    // Handle contains field - can be List or Map
    dynamic containsValue = json['contains'];
    Map<String, dynamic>? containsMap;

    if (containsValue is List) {
      containsMap = {'ingredients': containsValue};
    } else if (containsValue is Map<String, dynamic>) {
      containsMap = containsValue;
    }

    return MenuModel(
      id: json['id'] ?? 0,
      subcategoryId: json['subcategory_id'] ?? 0,
      proteinTypeId: json['protein_type_id'],
      key: json['key'] ?? '',
      imageUrl: json['image_url'],
      contains: containsMap,
      mealTime: json['meal_time'] ?? 'LUNCH',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      name: json['name'],
      translations: json['Translations'] != null
          ? (json['Translations'] as List).map((e) => MenuTranslationModel.fromJson(e)).toList()
          : json['translations'] != null
              ? (json['translations'] as List).map((e) => MenuTranslationModel.fromJson(e)).toList()
              : null,
      subcategory: json['Subcategory'] != null
          ? MenuSubcategoryModel.fromJson(json['Subcategory'])
          : json['subcategory'] != null
              ? MenuSubcategoryModel.fromCleanedJson(json['subcategory'])
              : null,
      proteinType: json['ProteinType'] != null
          ? MenuProteinTypeModel.fromJson(json['ProteinType'])
          : json['protein_type'] != null
              ? MenuProteinTypeModel.fromCleanedJson(json['protein_type'])
              : null,
      averageRating: json['average_rating']?.toDouble(),
      totalRatings: json['total_ratings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subcategory_id': subcategoryId,
      'protein_type_id': proteinTypeId,
      'key': key,
      'image_url': imageUrl,
      'contains': contains,
      'meal_time': mealTime,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'name': name,
      'translations': translations?.map((e) => e.toJson()).toList(),
      'subcategory': subcategory?.toJson(),
      'protein_type': proteinType?.toJson(),
      'average_rating': averageRating,
      'total_ratings': totalRatings,
    };
  }

  /// Convert Model to Entity
  MenuEntity toEntity({String language = 'th'}) {
    // Get localized name
    String localizedName = name ?? '';
    String? localizedDescription;

    if (localizedName.isEmpty && translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.language == language,
        orElse: () => translations!.first,
      );
      localizedName = translation.name;
      localizedDescription = translation.description;
    }

    if (localizedName.isEmpty) {
      localizedName = key;
    }

    return MenuEntity(
      id: id,
      key: key,
      imageUrl: imageUrl,
      mealTime: mealTime,
      isActive: isActive,
      name: localizedName,
      description: localizedDescription,
      contains: contains,
      subcategory: subcategory?.toEntity(language: language),
      proteinType: proteinType?.toEntity(language: language),
      averageRating: averageRating,
      totalRatings: totalRatings,
    );
  }

  String getName({String language = 'th'}) {
    if (name != null && name!.isNotEmpty) return name!;

    if (translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.language == language,
        orElse: () => translations!.first,
      );
      return translation.name;
    }

    return key;
  }

  String? getDescription({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return null;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.description;
  }
}

class MenuTranslationModel {
  final int id;
  final int menuId;
  final String language;
  final String name;
  final String? description;

  MenuTranslationModel({
    required this.id,
    required this.menuId,
    required this.language,
    required this.name,
    this.description,
  });

  factory MenuTranslationModel.fromJson(Map<String, dynamic> json) {
    return MenuTranslationModel(
      id: json['id'] ?? 0,
      menuId: json['menu_id'] ?? 0,
      language: json['language'] ?? 'th',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_id': menuId,
      'language': language,
      'name': name,
      'description': description,
    };
  }
}

class MenuSubcategoryModel {
  final int id;
  final int? categoryId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslationModel>? translations;
  final MenuCategoryModel? category;

  MenuSubcategoryModel({
    required this.id,
    this.categoryId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
    this.category,
  });

  factory MenuSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuSubcategoryModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'],
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List).map((e) => MenuTranslationModel.fromJson(e)).toList()
          : null,
      category: json['Category'] != null ? MenuCategoryModel.fromJson(json['Category']) : null,
    );
  }

  factory MenuSubcategoryModel.fromCleanedJson(Map<String, dynamic> json) {
    return MenuSubcategoryModel(
      id: json['id'] ?? 0,
      categoryId: json['category_id'],
      key: json['key'] ?? '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      translations: null,
      category: json['category'] != null ? MenuCategoryModel.fromCleanedJson(json['category']) : null,
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
      'translations': translations?.map((e) => e.toJson()).toList(),
      'category': category?.toJson(),
    };
  }

  MenuSubcategoryEntity toEntity({String language = 'th'}) {
    String localizedName = key;
    if (translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.language == language,
        orElse: () => translations!.first,
      );
      localizedName = translation.name;
    }

    return MenuSubcategoryEntity(
      id: id,
      key: key,
      name: localizedName,
      category: category?.toEntity(language: language),
    );
  }

  String getName({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return key;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.name;
  }
}

class MenuCategoryModel {
  final int id;
  final int? foodTypeId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslationModel>? translations;
  final MenuFoodTypeModel? foodType;

  MenuCategoryModel({
    required this.id,
    this.foodTypeId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
    this.foodType,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] ?? 0,
      foodTypeId: json['food_type_id'],
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List).map((e) => MenuTranslationModel.fromJson(e)).toList()
          : null,
      foodType: json['FoodType'] != null ? MenuFoodTypeModel.fromJson(json['FoodType']) : null,
    );
  }

  factory MenuCategoryModel.fromCleanedJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] ?? 0,
      foodTypeId: json['food_type_id'],
      key: json['key'] ?? '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      translations: null,
      foodType: json['food_type'] != null ? MenuFoodTypeModel.fromCleanedJson(json['food_type']) : null,
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
      'translations': translations?.map((e) => e.toJson()).toList(),
      'food_type': foodType?.toJson(),
    };
  }

  MenuCategoryEntity toEntity({String language = 'th'}) {
    String localizedName = key;
    if (translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.language == language,
        orElse: () => translations!.first,
      );
      localizedName = translation.name;
    }

    return MenuCategoryEntity(
      id: id,
      key: key,
      name: localizedName,
    );
  }

  String getName({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return key;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.name;
  }
}

class MenuFoodTypeModel {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslationModel>? translations;

  MenuFoodTypeModel({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
  });

  factory MenuFoodTypeModel.fromJson(Map<String, dynamic> json) {
    return MenuFoodTypeModel(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List).map((e) => MenuTranslationModel.fromJson(e)).toList()
          : null,
    );
  }

  factory MenuFoodTypeModel.fromCleanedJson(Map<String, dynamic> json) {
    return MenuFoodTypeModel(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      translations: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'translations': translations?.map((e) => e.toJson()).toList(),
    };
  }

  String getName({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return key;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.name;
  }
}

class MenuProteinTypeModel {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslationModel>? translations;

  MenuProteinTypeModel({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
  });

  factory MenuProteinTypeModel.fromJson(Map<String, dynamic> json) {
    return MenuProteinTypeModel(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List).map((e) => MenuTranslationModel.fromJson(e)).toList()
          : null,
    );
  }

  factory MenuProteinTypeModel.fromCleanedJson(Map<String, dynamic> json) {
    return MenuProteinTypeModel(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      translations: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'translations': translations?.map((e) => e.toJson()).toList(),
    };
  }

  MenuProteinTypeEntity toEntity({String language = 'th'}) {
    String localizedName = key;
    if (translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.language == language,
        orElse: () => translations!.first,
      );
      localizedName = translation.name;
    }

    return MenuProteinTypeEntity(
      id: id,
      key: key,
      name: localizedName,
    );
  }

  String getName({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return key;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.name;
  }
}
