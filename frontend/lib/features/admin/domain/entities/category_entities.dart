// Food Type Entity
class FoodTypeEntity {
  final int id;
  final String key;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FoodTypeEntity({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Category Entity
class CategoryEntity {
  final int id;
  final int foodTypeId;
  final String key;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.foodTypeId,
    required this.key,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Subcategory Entity
class SubcategoryEntity {
  final int id;
  final int categoryId;
  final String key;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubcategoryEntity({
    required this.id,
    required this.categoryId,
    required this.key,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
}