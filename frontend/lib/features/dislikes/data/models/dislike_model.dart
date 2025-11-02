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
      // Menu name is constructed from ProteinType + Subcategory
      // Example: "ไก่ ผัดกะเพรา" = "ไก่" (protein) + "ผัดกะเพรา" (subcategory)

      String? proteinName;
      String? subcategoryName;

      // Get protein type translation
      if (menu!.proteinType != null && menu!.proteinType!.translations != null) {
        final proteinTranslations = menu!.proteinType!.translations!;
        if (proteinTranslations.isNotEmpty) {
          final proteinTranslation = proteinTranslations.firstWhere(
            (t) => t['language'] == language,
            orElse: () => proteinTranslations.first,
          );
          proteinName = proteinTranslation['name'];
        }
      }

      // Get subcategory translation
      if (menu!.subcategory != null && menu!.subcategory!.translations != null) {
        final subcategoryTranslations = menu!.subcategory!.translations!;
        if (subcategoryTranslations.isNotEmpty) {
          final subcategoryTranslation = subcategoryTranslations.firstWhere(
            (t) => t['language'] == language,
            orElse: () => subcategoryTranslations.first,
          );
          subcategoryName = subcategoryTranslation['name'];
          menuDescription = subcategoryTranslation['description'];
        }
      }

      // Construct menu name from protein + subcategory
      if (proteinName != null && subcategoryName != null) {
        menuName = '$proteinName $subcategoryName';
      } else if (subcategoryName != null) {
        menuName = subcategoryName;
      } else if (proteinName != null) {
        menuName = proteinName;
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
  final SubcategoryData? subcategory;
  final ProteinTypeData? proteinType;

  MenuData({
    required this.id,
    this.subcategory,
    this.proteinType,
  });

  factory MenuData.fromJson(Map<String, dynamic> json) {
    return MenuData(
      id: json['id'] ?? 0,
      subcategory: json['Subcategory'] != null
          ? SubcategoryData.fromJson(json['Subcategory'])
          : null,
      proteinType: json['ProteinType'] != null
          ? ProteinTypeData.fromJson(json['ProteinType'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Subcategory': subcategory?.toJson(),
      'ProteinType': proteinType?.toJson(),
    };
  }
}

class SubcategoryData {
  final int id;
  final String key;
  final List<Map<String, dynamic>>? translations;

  SubcategoryData({
    required this.id,
    required this.key,
    this.translations,
  });

  factory SubcategoryData.fromJson(Map<String, dynamic> json) {
    return SubcategoryData(
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

class ProteinTypeData {
  final int id;
  final String key;
  final List<Map<String, dynamic>>? translations;

  ProteinTypeData({
    required this.id,
    required this.key,
    this.translations,
  });

  factory ProteinTypeData.fromJson(Map<String, dynamic> json) {
    return ProteinTypeData(
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
