class AdminMenuEntity {
  final int id;
  final int subcategoryId;
  final int? proteinTypeId;
  final String key;
  final String? imageUrl;
  final Map<String, dynamic> contains;
  final String mealTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<MenuTranslationEntity> translations;

  const AdminMenuEntity({
    required this.id,
    required this.subcategoryId,
    this.proteinTypeId,
    required this.key,
    this.imageUrl,
    required this.contains,
    required this.mealTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });
}

class MenuTranslationEntity {
  final int id;
  final int menuId;
  final String language;
  final String name;
  final String? description;

  const MenuTranslationEntity({
    required this.id,
    required this.menuId,
    required this.language,
    required this.name,
    this.description,
  });
}