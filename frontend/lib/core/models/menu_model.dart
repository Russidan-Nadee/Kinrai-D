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
  final List<MenuTranslation>? translations;
  final MenuSubcategory? subcategory;
  final MenuProteinType? proteinType;
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
      // Convert List to Map format for consistency
      containsMap = {'ingredients': containsValue};
    } else if (containsValue is Map<String, dynamic>) {
      containsMap = containsValue;
    }

    return MenuModel(
      id: json['id'] ?? 0,
      subcategoryId: json['subcategory_id'] ?? 0,
      proteinTypeId: json['protein_type_id'], // nullable
      key: json['key'] ?? '',
      imageUrl: json['image_url'],
      contains: containsMap,
      mealTime: json['meal_time'] ?? 'LUNCH',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      // Support both raw Prisma data (Translations) and cleaned data (translations)
      translations: json['Translations'] != null
          ? (json['Translations'] as List)
              .map((e) => MenuTranslation.fromJson(e))
              .toList()
          : json['translations'] != null
              ? (json['translations'] as List)
                  .map((e) => MenuTranslation.fromJson(e))
                  .toList()
              : null,
      // Support both raw Prisma data (Subcategory) and cleaned data (subcategory)
      subcategory: json['Subcategory'] != null
          ? MenuSubcategory.fromJson(json['Subcategory'])
          : json['subcategory'] != null
              ? MenuSubcategory.fromCleanedJson(json['subcategory'])
              : null,
      // Support both raw Prisma data (ProteinType) and cleaned data (protein_type)
      proteinType: json['ProteinType'] != null
          ? MenuProteinType.fromJson(json['ProteinType'])
          : json['protein_type'] != null
              ? MenuProteinType.fromCleanedJson(json['protein_type'])
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
      'translations': translations?.map((e) => e.toJson()).toList(),
      'subcategory': subcategory?.toJson(),
      'protein_type': proteinType?.toJson(),
      'average_rating': averageRating,
      'total_ratings': totalRatings,
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

  String? getDescription({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return null;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.description;
  }
}

class MenuTranslation {
  final int id;
  final int menuId;
  final String language;
  final String name;
  final String? description;

  MenuTranslation({
    required this.id,
    required this.menuId,
    required this.language,
    required this.name,
    this.description,
  });

  factory MenuTranslation.fromJson(Map<String, dynamic> json) {
    return MenuTranslation(
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

class MenuSubcategory {
  final int id;
  final int? categoryId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslation>? translations;
  final MenuCategory? category;

  MenuSubcategory({
    required this.id,
    this.categoryId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
    this.category,
  });

  factory MenuSubcategory.fromJson(Map<String, dynamic> json) {
    return MenuSubcategory(
      id: json['id'] ?? 0,
      categoryId: json['category_id'],
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List)
              .map((e) => MenuTranslation.fromJson(e))
              .toList()
          : null,
      category: json['Category'] != null
          ? MenuCategory.fromJson(json['Category'])
          : null,
    );
  }

  // For cleaned API response data
  factory MenuSubcategory.fromCleanedJson(Map<String, dynamic> json) {
    return MenuSubcategory(
      id: json['id'] ?? 0,
      categoryId: json['category_id'],
      key: json['key'] ?? '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      translations: null, // Use the name directly
      category: json['category'] != null
          ? MenuCategory.fromCleanedJson(json['category'])
          : null,
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

  String getName({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return key;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.name;
  }

}

class MenuCategory {
  final int id;
  final int? foodTypeId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslation>? translations;
  final MenuFoodType? foodType;

  MenuCategory({
    required this.id,
    this.foodTypeId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
    this.foodType,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? 0,
      foodTypeId: json['food_type_id'],
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List)
              .map((e) => MenuTranslation.fromJson(e))
              .toList()
          : null,
      foodType: json['FoodType'] != null
          ? MenuFoodType.fromJson(json['FoodType'])
          : null,
    );
  }

  // For cleaned API response data
  factory MenuCategory.fromCleanedJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? 0,
      foodTypeId: json['food_type_id'],
      key: json['key'] ?? '',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      translations: null,
      foodType: json['food_type'] != null
          ? MenuFoodType.fromCleanedJson(json['food_type'])
          : null,
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

  String getName({String language = 'th'}) {
    if (translations == null || translations!.isEmpty) return key;

    final translation = translations!.firstWhere(
      (t) => t.language == language,
      orElse: () => translations!.first,
    );

    return translation.name;
  }
}

class MenuFoodType {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslation>? translations;

  MenuFoodType({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
  });

  factory MenuFoodType.fromJson(Map<String, dynamic> json) {
    return MenuFoodType(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List)
              .map((e) => MenuTranslation.fromJson(e))
              .toList()
          : null,
    );
  }

  // For cleaned API response data
  factory MenuFoodType.fromCleanedJson(Map<String, dynamic> json) {
    return MenuFoodType(
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

class MenuProteinType {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslation>? translations;

  MenuProteinType({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.translations,
  });

  factory MenuProteinType.fromJson(Map<String, dynamic> json) {
    return MenuProteinType(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      translations: json['Translations'] != null
          ? (json['Translations'] as List)
              .map((e) => MenuTranslation.fromJson(e))
              .toList()
          : null,
    );
  }

  // For cleaned API response data
  factory MenuProteinType.fromCleanedJson(Map<String, dynamic> json) {
    return MenuProteinType(
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