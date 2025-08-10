class FoodTypeEntity {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationEntity> translations;

  const FoodTypeEntity({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });
}

class CategoryEntity {
  final int id;
  final int foodTypeId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationEntity> translations;

  const CategoryEntity({
    required this.id,
    required this.foodTypeId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });
}

class SubcategoryEntity {
  final int id;
  final int categoryId;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationEntity> translations;

  const SubcategoryEntity({
    required this.id,
    required this.categoryId,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });
}

class ProteinTypeEntity {
  final int id;
  final String key;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TranslationEntity> translations;

  const ProteinTypeEntity({
    required this.id,
    required this.key,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });
}

class TranslationEntity {
  final int id;
  final String language;
  final String name;
  final String? description;

  const TranslationEntity({
    required this.id,
    required this.language,
    required this.name,
    this.description,
  });
}