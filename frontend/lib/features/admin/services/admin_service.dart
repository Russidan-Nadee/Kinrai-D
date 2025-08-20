import '../../../core/api/api_client.dart';
import '../models/admin_info_model.dart';

class AdminService {
  late final ApiClient _apiClient;

  AdminService() {
    _apiClient = ApiClient();
    _apiClient.initialize();
  }

  Future<AdminInfoModel> getMenuInfo({int limit = 1000}) async {
    try {
      print('[AdminService] Attempting to fetch menu info...');
      final response = await _apiClient.get(
        '/admin/menus',
        queryParameters: {'limit': limit.toString()},
      );
      
      print('[AdminService] API call successful');
      return AdminInfoModel.fromJson(response.data);
    } catch (e) {
      print('[AdminService] API call failed: $e');
      rethrow;
    }
  }
}