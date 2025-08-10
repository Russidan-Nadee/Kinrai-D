import '../entities/food_management_entity.dart';
import '../repositories/admin_repository.dart';

class FoodManagementUseCase {
  final AdminRepository repository;

  FoodManagementUseCase(this.repository);

  // Food Types
  Future<List<FoodTypeEntity>> getFoodTypes({int page = 1}) {
    return repository.getFoodTypes(page: page);
  }

  Future<FoodTypeEntity> getFoodTypeById(int id) {
    return repository.getFoodTypeById(id);
  }

  Future<FoodTypeEntity> createFoodType(FoodTypeEntity foodType) {
    return repository.createFoodType(foodType);
  }

  Future<FoodTypeEntity> updateFoodType(int id, FoodTypeEntity foodType) {
    return repository.updateFoodType(id, foodType);
  }

  Future<void> deleteFoodType(int id) {
    return repository.deleteFoodType(id);
  }

  // Categories
  Future<List<CategoryEntity>> getCategories({int page = 1}) {
    return repository.getCategories(page: page);
  }

  Future<CategoryEntity> getCategoryById(int id) {
    return repository.getCategoryById(id);
  }

  Future<CategoryEntity> createCategory(CategoryEntity category) {
    return repository.createCategory(category);
  }

  Future<CategoryEntity> updateCategory(int id, CategoryEntity category) {
    return repository.updateCategory(id, category);
  }

  Future<void> deleteCategory(int id) {
    return repository.deleteCategory(id);
  }

  // Subcategories
  Future<List<SubcategoryEntity>> getSubcategories({int page = 1}) {
    return repository.getSubcategories(page: page);
  }

  Future<SubcategoryEntity> getSubcategoryById(int id) {
    return repository.getSubcategoryById(id);
  }

  Future<SubcategoryEntity> createSubcategory(SubcategoryEntity subcategory) {
    return repository.createSubcategory(subcategory);
  }

  Future<SubcategoryEntity> updateSubcategory(int id, SubcategoryEntity subcategory) {
    return repository.updateSubcategory(id, subcategory);
  }

  Future<void> deleteSubcategory(int id) {
    return repository.deleteSubcategory(id);
  }

  // Protein Types
  Future<List<ProteinTypeEntity>> getProteinTypes({int page = 1}) {
    return repository.getProteinTypes(page: page);
  }

  Future<ProteinTypeEntity> getProteinTypeById(int id) {
    return repository.getProteinTypeById(id);
  }

  Future<ProteinTypeEntity> createProteinType(ProteinTypeEntity proteinType) {
    return repository.createProteinType(proteinType);
  }

  Future<ProteinTypeEntity> updateProteinType(int id, ProteinTypeEntity proteinType) {
    return repository.updateProteinType(id, proteinType);
  }

  Future<void> deleteProteinType(int id) {
    return repository.deleteProteinType(id);
  }
}