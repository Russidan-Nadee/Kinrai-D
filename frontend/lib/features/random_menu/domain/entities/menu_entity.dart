import 'package:equatable/equatable.dart';

/// Menu Entity - Pure business object
class MenuEntity extends Equatable {
  final int id;
  final String key;
  final String? imageUrl;
  final String mealTime;
  final bool isActive;
  final String name;
  final String? description;
  final Map<String, dynamic>? contains;
  final MenuSubcategoryEntity? subcategory;
  final MenuProteinTypeEntity? proteinType;
  final double? averageRating;
  final int? totalRatings;

  const MenuEntity({
    required this.id,
    required this.key,
    this.imageUrl,
    required this.mealTime,
    required this.isActive,
    required this.name,
    this.description,
    this.contains,
    this.subcategory,
    this.proteinType,
    this.averageRating,
    this.totalRatings,
  });

  @override
  List<Object?> get props => [
        id,
        key,
        imageUrl,
        mealTime,
        isActive,
        name,
        description,
        contains,
        subcategory,
        proteinType,
        averageRating,
        totalRatings,
      ];
}

class MenuSubcategoryEntity extends Equatable {
  final int id;
  final String key;
  final String name;
  final MenuCategoryEntity? category;

  const MenuSubcategoryEntity({
    required this.id,
    required this.key,
    required this.name,
    this.category,
  });

  @override
  List<Object?> get props => [id, key, name, category];
}

class MenuCategoryEntity extends Equatable {
  final int id;
  final String key;
  final String name;

  const MenuCategoryEntity({
    required this.id,
    required this.key,
    required this.name,
  });

  @override
  List<Object?> get props => [id, key, name];
}

class MenuProteinTypeEntity extends Equatable {
  final int id;
  final String key;
  final String name;

  const MenuProteinTypeEntity({
    required this.id,
    required this.key,
    required this.name,
  });

  @override
  List<Object?> get props => [id, key, name];
}
