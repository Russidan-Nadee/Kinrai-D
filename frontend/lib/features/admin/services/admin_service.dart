import '../../../core/api/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/admin_info_model.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  Future<AdminInfoModel> getMenuInfo({int limit = 1000}) async {
    try {
      AppLogger.info('[AdminService] Attempting to fetch menu info...');
      final response = await _apiClient.get(
        '/admin/menus',
        queryParameters: {'limit': limit.toString()},
      );
      
      AppLogger.info('[AdminService] API call successful');
      return AdminInfoModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('[AdminService] API call failed', e);
      rethrow;
    }
  }

  Future<bool> createMenu(Map<String, dynamic> menuData) async {
    try {
      AppLogger.info('[AdminService] Attempting to create menu...');
      final response = await _apiClient.post(
        '/menus',
        data: menuData,
      );
      
      AppLogger.info('[AdminService] Menu creation successful');
      return response.statusCode == 201;
    } catch (e) {
      AppLogger.error('[AdminService] Menu creation failed', e);
      rethrow;
    }
  }
}