import '../../domain/entities/admin_menu_entity.dart';

class AdminMenuModel extends AdminMenuEntity {
  const AdminMenuModel({
    required super.id,
    required super.subcategoryId,
    super.proteinTypeId,
    required super.key,
    super.imageUrl,
    required super.contains,
    required super.mealTime,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.translations,
  });

  factory AdminMenuModel.fromJson(Map<String, dynamic> json) {
    return AdminMenuModel(
      id: json['id'],
      subcategoryId: json['subcategory_id'],
      proteinTypeId: json['protein_type_id'],
      key: json['key'],
      imageUrl: json['image_url'],
      contains: json['contains'],
      mealTime: json['meal_time'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      translations: (json['translations'] as List<dynamic>?)
          ?.map((e) => MenuTranslationModel.fromJson(e))
          .toList() ?? [],
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
      'translations': translations.map((e) => (e as MenuTranslationModel).toJson()).toList(),
    };
  }
}

class MenuTranslationModel extends MenuTranslationEntity {
  const MenuTranslationModel({
    required super.id,
    required super.menuId,
    required super.language,
    required super.name,
    super.description,
  });

  factory MenuTranslationModel.fromJson(Map<String, dynamic> json) {
    return MenuTranslationModel(
      id: json['id'],
      menuId: json['menu_id'],
      language: json['language'],
      name: json['name'],
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