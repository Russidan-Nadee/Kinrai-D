import '../../../../core/api/api_client.dart';
import '../../models/admin_info_model.dart';

abstract class AdminRemoteDataSource {
  Future<AdminInfoModel> getMenus({int limit = 1000});
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
}