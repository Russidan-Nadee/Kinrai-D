import '../../../core/api/api_client.dart';
import '../models/admin_info_model.dart';

class AdminService {
  late final ApiClient _apiClient;

  AdminService() {
    _apiClient = ApiClient();
    _apiClient.initialize();
  }

  Future<AdminInfoModel> getMenuInfo({int limit = 5}) async {
    try {
      final response = await _apiClient.get(
        '/admin/menus',
        queryParameters: {'limit': limit.toString()},
      );
      
      return AdminInfoModel.fromJson(response.data);
    } catch (e) {
      print('[AdminService] Error getting menu info: $e');
      rethrow;
    }
  }
}