import '../../../../core/api/api_client.dart';
import '../models/admin_menu_model.dart';
import '../models/food_management_model.dart';

abstract class AdminRemoteDataSource {
  // Menu Management
  Future<List<AdminMenuModel>> getMenus({
    int page = 1,
    int limit = 10,
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
  });

  Future<AdminMenuModel> getMenuById(int id);
  Future<AdminMenuModel> createMenu(AdminMenuModel menu);
  Future<AdminMenuModel> updateMenu(int id, AdminMenuModel menu);
  Future<void> deleteMenu(int id);
  Future<void> activateMenu(int id);
  Future<void> deactivateMenu(int id);

  // Food Type Management
  Future<List<FoodTypeModel>> getFoodTypes({int page = 1});
  Future<FoodTypeModel> getFoodTypeById(int id);
  Future<FoodTypeModel> createFoodType(FoodTypeModel foodType);
  Future<FoodTypeModel> updateFoodType(int id, FoodTypeModel foodType);
  Future<void> deleteFoodType(int id);

  // Category Management
  Future<List<CategoryModel>> getCategories({int page = 1});
  Future<CategoryModel> getCategoryById(int id);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(int id, CategoryModel category);
  Future<void> deleteCategory(int id);

  // Subcategory Management
  Future<List<SubcategoryModel>> getSubcategories({int page = 1});
  Future<SubcategoryModel> getSubcategoryById(int id);
  Future<SubcategoryModel> createSubcategory(SubcategoryModel subcategory);
  Future<SubcategoryModel> updateSubcategory(int id, SubcategoryModel subcategory);
  Future<void> deleteSubcategory(int id);

  // Protein Type Management
  Future<List<ProteinTypeModel>> getProteinTypes({int page = 1});
  Future<ProteinTypeModel> getProteinTypeById(int id);
  Future<ProteinTypeModel> createProteinType(ProteinTypeModel proteinType);
  Future<ProteinTypeModel> updateProteinType(int id, ProteinTypeModel proteinType);
  Future<void> deleteProteinType(int id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AdminMenuModel>> getMenus({
    int page = 1,
    int limit = 10,
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null) queryParams['search'] = search;
    if (subcategoryId != null) queryParams['subcategory_id'] = subcategoryId.toString();
    if (mealTime != null) queryParams['meal_time'] = mealTime;
    if (isActive != null) queryParams['is_active'] = isActive.toString();

    final response = await apiClient.get(
      '/admin/menus',
      queryParameters: queryParams,
    );

    return (response.data['menus'] as List)
        .map((menu) => AdminMenuModel.fromJson(menu))
        .toList();
  }

  @override
  Future<AdminMenuModel> getMenuById(int id) async {
    final response = await apiClient.get('/admin/menus/$id');
    return AdminMenuModel.fromJson(response.data);
  }

  @override
  Future<AdminMenuModel> createMenu(AdminMenuModel menu) async {
    final response = await apiClient.post('/admin/menus', data: menu.toJson());
    return AdminMenuModel.fromJson(response.data);
  }

  @override
  Future<AdminMenuModel> updateMenu(int id, AdminMenuModel menu) async {
    final response = await apiClient.put('/admin/menus/$id', data: menu.toJson());
    return AdminMenuModel.fromJson(response.data);
  }

  @override
  Future<void> deleteMenu(int id) async {
    await apiClient.delete('/admin/menus/$id');
  }

  @override
  Future<void> activateMenu(int id) async {
    await apiClient.put('/admin/menus/$id/activate');
  }

  @override
  Future<void> deactivateMenu(int id) async {
    await apiClient.put('/admin/menus/$id/deactivate');
  }

  // Food Types Implementation
  @override
  Future<List<FoodTypeModel>> getFoodTypes({int page = 1}) async {
    final response = await apiClient.get('/admin/food-management/food-types', 
        queryParameters: {'page': page.toString()});
    return (response.data['foodTypes'] as List)
        .map((foodType) => FoodTypeModel.fromJson(foodType))
        .toList();
  }

  @override
  Future<FoodTypeModel> getFoodTypeById(int id) async {
    final response = await apiClient.get('/admin/food-management/food-types/$id');
    return FoodTypeModel.fromJson(response.data);
  }

  @override
  Future<FoodTypeModel> createFoodType(FoodTypeModel foodType) async {
    final response = await apiClient.post('/admin/food-management/food-types', 
        data: foodType.toJson());
    return FoodTypeModel.fromJson(response.data);
  }

  @override
  Future<FoodTypeModel> updateFoodType(int id, FoodTypeModel foodType) async {
    final response = await apiClient.put('/admin/food-management/food-types/$id', 
        data: foodType.toJson());
    return FoodTypeModel.fromJson(response.data);
  }

  @override
  Future<void> deleteFoodType(int id) async {
    await apiClient.delete('/admin/food-management/food-types/$id');
  }

  // Categories Implementation  
  @override
  Future<List<CategoryModel>> getCategories({int page = 1}) async {
    final response = await apiClient.get('/admin/food-management/categories', 
        queryParameters: {'page': page.toString()});
    return (response.data['categories'] as List)
        .map((category) => CategoryModel.fromJson(category))
        .toList();
  }

  @override
  Future<CategoryModel> getCategoryById(int id) async {
    final response = await apiClient.get('/admin/food-management/categories/$id');
    return CategoryModel.fromJson(response.data);
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    final response = await apiClient.post('/admin/food-management/categories', 
        data: category.toJson());
    return CategoryModel.fromJson(response.data);
  }

  @override
  Future<CategoryModel> updateCategory(int id, CategoryModel category) async {
    final response = await apiClient.put('/admin/food-management/categories/$id', 
        data: category.toJson());
    return CategoryModel.fromJson(response.data);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await apiClient.delete('/admin/food-management/categories/$id');
  }

  // Subcategories Implementation
  @override
  Future<List<SubcategoryModel>> getSubcategories({int page = 1}) async {
    final response = await apiClient.get('/admin/food-management/subcategories', 
        queryParameters: {'page': page.toString()});
    return (response.data['subcategories'] as List)
        .map((subcategory) => SubcategoryModel.fromJson(subcategory))
        .toList();
  }

  @override
  Future<SubcategoryModel> getSubcategoryById(int id) async {
    final response = await apiClient.get('/admin/food-management/subcategories/$id');
    return SubcategoryModel.fromJson(response.data);
  }

  @override
  Future<SubcategoryModel> createSubcategory(SubcategoryModel subcategory) async {
    final response = await apiClient.post('/admin/food-management/subcategories', 
        data: subcategory.toJson());
    return SubcategoryModel.fromJson(response.data);
  }

  @override
  Future<SubcategoryModel> updateSubcategory(int id, SubcategoryModel subcategory) async {
    final response = await apiClient.put('/admin/food-management/subcategories/$id', 
        data: subcategory.toJson());
    return SubcategoryModel.fromJson(response.data);
  }

  @override
  Future<void> deleteSubcategory(int id) async {
    await apiClient.delete('/admin/food-management/subcategories/$id');
  }

  // Protein Types Implementation
  @override
  Future<List<ProteinTypeModel>> getProteinTypes({int page = 1}) async {
    final response = await apiClient.get('/admin/food-management/protein-types', 
        queryParameters: {'page': page.toString()});
    return (response.data['proteinTypes'] as List)
        .map((proteinType) => ProteinTypeModel.fromJson(proteinType))
        .toList();
  }

  @override
  Future<ProteinTypeModel> getProteinTypeById(int id) async {
    final response = await apiClient.get('/admin/food-management/protein-types/$id');
    return ProteinTypeModel.fromJson(response.data);
  }

  @override
  Future<ProteinTypeModel> createProteinType(ProteinTypeModel proteinType) async {
    final response = await apiClient.post('/admin/food-management/protein-types', 
        data: proteinType.toJson());
    return ProteinTypeModel.fromJson(response.data);
  }

  @override
  Future<ProteinTypeModel> updateProteinType(int id, ProteinTypeModel proteinType) async {
    final response = await apiClient.put('/admin/food-management/protein-types/$id', 
        data: proteinType.toJson());
    return ProteinTypeModel.fromJson(response.data);
  }

  @override
  Future<void> deleteProteinType(int id) async {
    await apiClient.delete('/admin/food-management/protein-types/$id');
  }
}