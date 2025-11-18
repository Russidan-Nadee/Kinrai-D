import '../../../../core/api/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/admin_info_model.dart';

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
      AppLogger.info('[AdminRemoteDataSource] Fetching menus with limit: $limit');
      final response = await apiClient.get(
        '/admin/menus',
        queryParameters: {'limit': limit.toString()},
      );
      
      AppLogger.info('[AdminRemoteDataSource] API call successful');
      return AdminInfoModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('[AdminRemoteDataSource] API call failed', e);
      rethrow;
    }
  }

  @override
  Future<bool> createMenu(Map<String, dynamic> menuData) async {
    try {
      AppLogger.info('[AdminRemoteDataSource] Creating menu: $menuData');
      final response = await apiClient.post(
        '/menus',
        data: menuData,
      );
      
      AppLogger.info('[AdminRemoteDataSource] Menu creation successful');
      return response.statusCode == 201;
    } catch (e) {
      AppLogger.error('[AdminRemoteDataSource] Menu creation failed', e);
      rethrow;
    }
  }
}