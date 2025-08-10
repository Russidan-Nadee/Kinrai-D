import '../entities/admin_menu_entity.dart';
import '../entities/food_management_entity.dart';

abstract class AdminRepository {
  // Menu Management
  Future<List<AdminMenuEntity>> getMenus({
    int page = 1,
    int limit = 10,
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
  });

  Future<AdminMenuEntity> getMenuById(int id);
  Future<AdminMenuEntity> createMenu(AdminMenuEntity menu);
  Future<AdminMenuEntity> updateMenu(int id, AdminMenuEntity menu);
  Future<void> deleteMenu(int id);
  Future<void> activateMenu(int id);
  Future<void> deactivateMenu(int id);

  // Food Type Management
  Future<List<FoodTypeEntity>> getFoodTypes({int page = 1});
  Future<FoodTypeEntity> getFoodTypeById(int id);
  Future<FoodTypeEntity> createFoodType(FoodTypeEntity foodType);
  Future<FoodTypeEntity> updateFoodType(int id, FoodTypeEntity foodType);
  Future<void> deleteFoodType(int id);

  // Category Management
  Future<List<CategoryEntity>> getCategories({int page = 1});
  Future<CategoryEntity> getCategoryById(int id);
  Future<CategoryEntity> createCategory(CategoryEntity category);
  Future<CategoryEntity> updateCategory(int id, CategoryEntity category);
  Future<void> deleteCategory(int id);

  // Subcategory Management
  Future<List<SubcategoryEntity>> getSubcategories({int page = 1});
  Future<SubcategoryEntity> getSubcategoryById(int id);
  Future<SubcategoryEntity> createSubcategory(SubcategoryEntity subcategory);
  Future<SubcategoryEntity> updateSubcategory(int id, SubcategoryEntity subcategory);
  Future<void> deleteSubcategory(int id);

  // Protein Type Management
  Future<List<ProteinTypeEntity>> getProteinTypes({int page = 1});
  Future<ProteinTypeEntity> getProteinTypeById(int id);
  Future<ProteinTypeEntity> createProteinType(ProteinTypeEntity proteinType);
  Future<ProteinTypeEntity> updateProteinType(int id, ProteinTypeEntity proteinType);
  Future<void> deleteProteinType(int id);
}