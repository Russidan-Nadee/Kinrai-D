import '../../domain/entities/admin_menu_entity.dart';
import '../../domain/entities/food_management_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/admin_menu_model.dart';
import '../models/food_management_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  // Menu Management
  @override
  Future<List<AdminMenuEntity>> getMenus({
    int page = 1,
    int limit = 10,
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
  }) {
    return remoteDataSource.getMenus(
      page: page,
      limit: limit,
      search: search,
      subcategoryId: subcategoryId,
      mealTime: mealTime,
      isActive: isActive,
    );
  }

  @override
  Future<AdminMenuEntity> getMenuById(int id) {
    return remoteDataSource.getMenuById(id);
  }

  @override
  Future<AdminMenuEntity> createMenu(AdminMenuEntity menu) {
    final menuModel = AdminMenuModel(
      id: menu.id,
      subcategoryId: menu.subcategoryId,
      proteinTypeId: menu.proteinTypeId,
      key: menu.key,
      imageUrl: menu.imageUrl,
      contains: menu.contains,
      mealTime: menu.mealTime,
      isActive: menu.isActive,
      createdAt: menu.createdAt,
      updatedAt: menu.updatedAt,
      translations: menu.translations.map((t) => MenuTranslationModel(
        id: t.id,
        menuId: t.menuId,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.createMenu(menuModel);
  }

  @override
  Future<AdminMenuEntity> updateMenu(int id, AdminMenuEntity menu) {
    final menuModel = AdminMenuModel(
      id: menu.id,
      subcategoryId: menu.subcategoryId,
      proteinTypeId: menu.proteinTypeId,
      key: menu.key,
      imageUrl: menu.imageUrl,
      contains: menu.contains,
      mealTime: menu.mealTime,
      isActive: menu.isActive,
      createdAt: menu.createdAt,
      updatedAt: menu.updatedAt,
      translations: menu.translations.map((t) => MenuTranslationModel(
        id: t.id,
        menuId: t.menuId,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.updateMenu(id, menuModel);
  }

  @override
  Future<void> deleteMenu(int id) {
    return remoteDataSource.deleteMenu(id);
  }

  @override
  Future<void> activateMenu(int id) {
    return remoteDataSource.activateMenu(id);
  }

  @override
  Future<void> deactivateMenu(int id) {
    return remoteDataSource.deactivateMenu(id);
  }

  // Food Type Management
  @override
  Future<List<FoodTypeEntity>> getFoodTypes({int page = 1}) {
    return remoteDataSource.getFoodTypes(page: page);
  }

  @override
  Future<FoodTypeEntity> getFoodTypeById(int id) {
    return remoteDataSource.getFoodTypeById(id);
  }

  @override
  Future<FoodTypeEntity> createFoodType(FoodTypeEntity foodType) {
    final foodTypeModel = FoodTypeModel(
      id: foodType.id,
      key: foodType.key,
      isActive: foodType.isActive,
      createdAt: foodType.createdAt,
      updatedAt: foodType.updatedAt,
      translations: foodType.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.createFoodType(foodTypeModel);
  }

  @override
  Future<FoodTypeEntity> updateFoodType(int id, FoodTypeEntity foodType) {
    final foodTypeModel = FoodTypeModel(
      id: foodType.id,
      key: foodType.key,
      isActive: foodType.isActive,
      createdAt: foodType.createdAt,
      updatedAt: foodType.updatedAt,
      translations: foodType.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.updateFoodType(id, foodTypeModel);
  }

  @override
  Future<void> deleteFoodType(int id) {
    return remoteDataSource.deleteFoodType(id);
  }

  // Category Management
  @override
  Future<List<CategoryEntity>> getCategories({int page = 1}) {
    return remoteDataSource.getCategories(page: page);
  }

  @override
  Future<CategoryEntity> getCategoryById(int id) {
    return remoteDataSource.getCategoryById(id);
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) {
    final categoryModel = CategoryModel(
      id: category.id,
      foodTypeId: category.foodTypeId,
      key: category.key,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      translations: category.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.createCategory(categoryModel);
  }

  @override
  Future<CategoryEntity> updateCategory(int id, CategoryEntity category) {
    final categoryModel = CategoryModel(
      id: category.id,
      foodTypeId: category.foodTypeId,
      key: category.key,
      isActive: category.isActive,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      translations: category.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.updateCategory(id, categoryModel);
  }

  @override
  Future<void> deleteCategory(int id) {
    return remoteDataSource.deleteCategory(id);
  }

  // Subcategory Management
  @override
  Future<List<SubcategoryEntity>> getSubcategories({int page = 1}) {
    return remoteDataSource.getSubcategories(page: page);
  }

  @override
  Future<SubcategoryEntity> getSubcategoryById(int id) {
    return remoteDataSource.getSubcategoryById(id);
  }

  @override
  Future<SubcategoryEntity> createSubcategory(SubcategoryEntity subcategory) {
    final subcategoryModel = SubcategoryModel(
      id: subcategory.id,
      categoryId: subcategory.categoryId,
      key: subcategory.key,
      isActive: subcategory.isActive,
      createdAt: subcategory.createdAt,
      updatedAt: subcategory.updatedAt,
      translations: subcategory.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.createSubcategory(subcategoryModel);
  }

  @override
  Future<SubcategoryEntity> updateSubcategory(int id, SubcategoryEntity subcategory) {
    final subcategoryModel = SubcategoryModel(
      id: subcategory.id,
      categoryId: subcategory.categoryId,
      key: subcategory.key,
      isActive: subcategory.isActive,
      createdAt: subcategory.createdAt,
      updatedAt: subcategory.updatedAt,
      translations: subcategory.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.updateSubcategory(id, subcategoryModel);
  }

  @override
  Future<void> deleteSubcategory(int id) {
    return remoteDataSource.deleteSubcategory(id);
  }

  // Protein Type Management
  @override
  Future<List<ProteinTypeEntity>> getProteinTypes({int page = 1}) {
    return remoteDataSource.getProteinTypes(page: page);
  }

  @override
  Future<ProteinTypeEntity> getProteinTypeById(int id) {
    return remoteDataSource.getProteinTypeById(id);
  }

  @override
  Future<ProteinTypeEntity> createProteinType(ProteinTypeEntity proteinType) {
    final proteinTypeModel = ProteinTypeModel(
      id: proteinType.id,
      key: proteinType.key,
      isActive: proteinType.isActive,
      createdAt: proteinType.createdAt,
      updatedAt: proteinType.updatedAt,
      translations: proteinType.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.createProteinType(proteinTypeModel);
  }

  @override
  Future<ProteinTypeEntity> updateProteinType(int id, ProteinTypeEntity proteinType) {
    final proteinTypeModel = ProteinTypeModel(
      id: proteinType.id,
      key: proteinType.key,
      isActive: proteinType.isActive,
      createdAt: proteinType.createdAt,
      updatedAt: proteinType.updatedAt,
      translations: proteinType.translations.map((t) => TranslationModel(
        id: t.id,
        language: t.language,
        name: t.name,
        description: t.description,
      )).toList(),
    );
    return remoteDataSource.updateProteinType(id, proteinTypeModel);
  }

  @override
  Future<void> deleteProteinType(int id) {
    return remoteDataSource.deleteProteinType(id);
  }
}