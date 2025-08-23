import '../../../../core/api/api_client.dart';
import '../../models/admin_info_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminInfoModel> getMenus({int limit = 1000});
  Future<bool> createMenu(Map<String, dynamic> menuData);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AdminInfoModel> getMenus({int limit = 1000}) async {
    try {
      print('[AdminRemoteDataSource] Fetching menus with limit: $limit');
      final response = await apiClient.get(
        '/admin/menus',
        queryParameters: {'limit': limit.toString()},
      );
      
      print('[AdminRemoteDataSource] API call successful');
      return AdminInfoModel.fromJson(response.data);
    } catch (e) {
      print('[AdminRemoteDataSource] API call failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> createMenu(Map<String, dynamic> menuData) async {
    try {
      print('[AdminRemoteDataSource] Creating menu: $menuData');
      final response = await apiClient.post(
        '/menus',
        data: menuData,
      );
      
      print('[AdminRemoteDataSource] Menu creation successful');
      return response.statusCode == 201;
    } catch (e) {
      print('[AdminRemoteDataSource] Menu creation failed: $e');
      rethrow;
    }
  }
}