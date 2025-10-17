import '../../domain/entities/protein_preference_entity.dart';

class ProteinTypeModel {
  final int id;
  final String key;
  final bool isActive;
  final List<TranslationData>? translations;

  ProteinTypeModel({
    required this.id,
    required this.key,
    required this.isActive,
    this.translations,
  });

  factory ProteinTypeModel.fromJson(Map<String, dynamic> json) {
    return ProteinTypeModel(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      isActive: json['is_active'] ?? true,
      translations: json['Translations'] != null
          ? (json['Translations'] as List)
              .map((t) => TranslationData.fromJson(t))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'is_active': isActive,
      'Translations': translations?.map((t) => t.toJson()).toList(),
    };
  }

  ProteinTypeEntity toEntity({String language = 'th'}) {
    String name = key;
    if (translations != null && translations!.isNotEmpty) {
      final translation = translations!.firstWhere(
        (t) => t.language == language,
        orElse: () => translations!.first,
      );
      name = translation.name;
    }

    return ProteinTypeEntity(
      id: id,
      key: key,
      name: name,
    );
  }
}

class ProteinPreferenceModel {
  final int proteinTypeId;
  final bool exclude;
  final ProteinTypeData? proteinType;

  ProteinPreferenceModel({
    required this.proteinTypeId,
    required this.exclude,
    this.proteinType,
  });

  factory ProteinPreferenceModel.fromJson(Map<String, dynamic> json) {
    return ProteinPreferenceModel(
      proteinTypeId: json['protein_type_id'] ?? 0,
      exclude: json['exclude'] ?? true,
      proteinType: json['ProteinType'] != null
          ? ProteinTypeData.fromJson(json['ProteinType'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein_type_id': proteinTypeId,
      'exclude': exclude,
      'ProteinType': proteinType?.toJson(),
    };
  }

  ProteinPreferenceEntity toEntity({String language = 'th'}) {
    String proteinTypeName = 'Unknown';
    if (proteinType != null) {
      final translations = proteinType!.translations;
      if (translations != null && translations.isNotEmpty) {
        final translation = translations.firstWhere(
          (t) => t.language == language,
          orElse: () => translations.first,
        );
        proteinTypeName = translation.name;
      }
    }

    return ProteinPreferenceEntity(
      proteinTypeId: proteinTypeId,
      proteinTypeName: proteinTypeName,
      exclude: exclude,
    );
  }
}

class ProteinTypeData {
  final int id;
  final String key;
  final List<TranslationData>? translations;

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
          ? (json['Translations'] as List)
              .map((t) => TranslationData.fromJson(t))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'Translations': translations?.map((t) => t.toJson()).toList(),
    };
  }
}

class TranslationData {
  final String language;
  final String name;

  TranslationData({
    required this.language,
    required this.name,
  });

  factory TranslationData.fromJson(Map<String, dynamic> json) {
    return TranslationData(
      language: json['language'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'name': name,
    };
  }
}
