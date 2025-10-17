import '../../domain/entities/dislike_entity.dart';

class DislikeModel {
  final int menuId;
  final String? reason;
  final DateTime createdAt;
  final MenuData? menu;

  DislikeModel({
    required this.menuId,
    this.reason,
    required this.createdAt,
    this.menu,
  });

  factory DislikeModel.fromJson(Map<String, dynamic> json) {
    return DislikeModel(
      menuId: json['menu_id'] ?? 0,
      reason: json['reason'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      menu: json['Menu'] != null ? MenuData.fromJson(json['Menu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'Menu': menu?.toJson(),
    };
  }

  DislikeEntity toEntity({String language = 'th'}) {
    String menuName = 'Unknown Menu';
    String? menuDescription;

    if (menu != null) {
      final translations = menu!.translations;
      if (translations != null && translations.isNotEmpty) {
        final translation = translations.firstWhere(
          (t) => t['language'] == language,
          orElse: () => translations.first,
        );
        menuName = translation['name'] ?? menuName;
        menuDescription = translation['description'];
      }
    }

    return DislikeEntity(
      menuId: menuId,
      menuName: menuName,
      menuDescription: menuDescription,
      reason: reason,
      createdAt: createdAt,
    );
  }
}

class MenuData {
  final int id;
  final String key;
  final List<Map<String, dynamic>>? translations;

  MenuData({
    required this.id,
    required this.key,
    this.translations,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) {
    return MenuData(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      translations: json['Translations'] != null
          ? List<Map<String, dynamic>>.from(json['Translations'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'Translations': translations,
    };
  }
}
