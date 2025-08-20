import '../../../../core/api/api_client.dart';
import '../models/category_models.dart';

abstract class CategoryRemoteDataSource {
  Future<List<FoodTypeModel>> getFoodTypes();
  Future<List<CategoryModel>> getCategories();
  Future<List<SubcategoryModel>> getSubcategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient apiClient;

  CategoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<FoodTypeModel>> getFoodTypes() async {
    try {
      print('[CategoryRemoteDataSource] Fetching food types...');
      final response = await apiClient.get('/food-types?lang=en');
      
      print('[CategoryRemoteDataSource] Food types API call successful');
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => (data as List<dynamic>)
            .map((item) => FoodTypeModel.fromJson(item))
            .toList(),
      );
      
      return apiResponse.data;
    } catch (e) {
      print('[CategoryRemoteDataSource] Food types API call failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      print('[CategoryRemoteDataSource] Fetching categories...');
      final response = await apiClient.get('/categories?lang=en');
      
      print('[CategoryRemoteDataSource] Categories API call successful');
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => (data as List<dynamic>)
            .map((item) => CategoryModel.fromJson(item))
            .toList(),
      );
      
      return apiResponse.data;
    } catch (e) {
      print('[CategoryRemoteDataSource] Categories API call failed: $e');
      rethrow;
    }
  }

  @override
  Future<List<SubcategoryModel>> getSubcategories() async {
    try {
      print('[CategoryRemoteDataSource] Fetching subcategories...');
      final response = await apiClient.get('/subcategories?lang=en');
      
      print('[CategoryRemoteDataSource] Subcategories API call successful');
      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => (data as List<dynamic>)
            .map((item) => SubcategoryModel.fromJson(item))
            .toList(),
      );
      
      return apiResponse.data;
    } catch (e) {
      print('[CategoryRemoteDataSource] Subcategories API call failed: $e');
      rethrow;
    }
  }
}