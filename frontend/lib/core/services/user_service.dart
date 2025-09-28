import '../api/api_client.dart';
import '../utils/logger.dart';

class UserService {
  late final ApiClient _apiClient;

  UserService() {
    _apiClient = ApiClient();
    _apiClient.initialize();
  }

  /// เพิ่ม dislike สำหรับ menu
  Future<Map<String, dynamic>> addDislike({
    required int menuId,
    String? reason,
  }) async {
    try {
      AppLogger.info('[UserService] Adding dislike for menu: $menuId');

      final requestData = <String, dynamic>{
        'menu_id': menuId,
      };

      if (reason != null && reason.isNotEmpty) {
        requestData['reason'] = reason;
      }

      final response = await _apiClient.post(
        '/user-profiles/me/dislikes',
        data: requestData,
      );

      AppLogger.info('[UserService] Dislike added successfully');
      return response.data;
    } catch (e) {
      AppLogger.error('[UserService] Failed to add dislike', e);
      rethrow;
    }
  }

  /// ลบ dislike สำหรับ menu
  Future<void> removeDislike({required int menuId}) async {
    try {
      AppLogger.info('[UserService] Removing dislike for menu: $menuId');

      await _apiClient.delete(
        '/user-profiles/me/dislikes',
        data: {'menu_id': menuId},
      );

      AppLogger.info('[UserService] Dislike removed successfully');
    } catch (e) {
      AppLogger.error('[UserService] Failed to remove dislike', e);
      rethrow;
    }
  }

  /// ดึงรายการ dislikes ของ user
  Future<List<Map<String, dynamic>>> getUserDislikes({
    String language = 'th',
  }) async {
    try {
      AppLogger.info('[UserService] Fetching user dislikes');

      final response = await _apiClient.get(
        '/user-profiles/me/dislikes',
        queryParameters: {'language': language},
      );

      AppLogger.info('[UserService] User dislikes fetched successfully');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      AppLogger.error('[UserService] Failed to fetch user dislikes', e);
      rethrow;
    }
  }

  /// ตรวจสอบว่า menu นี้อยู่ใน dislike list หรือไม่
  Future<bool> isMenuDisliked(int menuId) async {
    try {
      final dislikes = await getUserDislikes();
      return dislikes.any((dislike) => dislike['menu_id'] == menuId);
    } catch (e) {
      AppLogger.error('[UserService] Failed to check if menu is disliked', e);
      return false;
    }
  }

  /// ลบ dislike หลายรายการพร้อมกัน
  Future<Map<String, dynamic>> removeBulkDislikes({required List<int> menuIds}) async {
    try {
      AppLogger.info('[UserService] Attempting to remove bulk dislikes for menu IDs: $menuIds');

      final requestData = {'menu_ids': menuIds};

      final response = await _apiClient.delete(
        '/user-profiles/me/dislikes/bulk',
        data: requestData,
      );

      AppLogger.info('[UserService] Bulk dislikes removal successful');
      return response.data;
    } catch (e) {
      AppLogger.error('[UserService] Bulk dislikes removal failed', e);
      rethrow;
    }
  }

  // === PROTEIN PREFERENCES METHODS ===

  /// ดึงรายการ protein types ทั้งหมด
  Future<List<Map<String, dynamic>>> getAvailableProteinTypes({
    String language = 'th',
  }) async {
    try {
      AppLogger.info('[UserService] Fetching available protein types');

      final response = await _apiClient.get(
        '/protein-preferences/available',
        queryParameters: {'language': language},
      );

      AppLogger.info('[UserService] Available protein types fetched successfully');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      AppLogger.error('[UserService] Failed to fetch available protein types', e);
      rethrow;
    }
  }

  /// ดึงรายการ protein preferences ของ user (อันที่ไม่กิน)
  Future<List<Map<String, dynamic>>> getUserProteinPreferences({
    String language = 'th',
  }) async {
    try {
      AppLogger.info('[UserService] Fetching user protein preferences');

      final response = await _apiClient.get(
        '/protein-preferences/me',
        queryParameters: {'language': language},
      );

      AppLogger.info('[UserService] User protein preferences fetched successfully');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      AppLogger.error('[UserService] Failed to fetch user protein preferences', e);
      rethrow;
    }
  }

  /// ตั้งค่าไม่กิน protein type นี้
  Future<Map<String, dynamic>> setProteinPreference({
    required int proteinTypeId,
    bool exclude = true,
  }) async {
    try {
      AppLogger.info('[UserService] Setting protein preference: $proteinTypeId, exclude: $exclude');

      final response = await _apiClient.post(
        '/protein-preferences/me',
        data: {
          'protein_type_id': proteinTypeId,
          'exclude': exclude,
        },
      );

      AppLogger.info('[UserService] Protein preference set successfully');
      return response.data;
    } catch (e) {
      AppLogger.error('[UserService] Failed to set protein preference', e);
      rethrow;
    }
  }

  /// ลบ protein preference (กลับไปกินได้)
  Future<void> removeProteinPreference({
    required int proteinTypeId,
  }) async {
    try {
      AppLogger.info('[UserService] Removing protein preference: $proteinTypeId');

      await _apiClient.delete(
        '/protein-preferences/me',
        data: {'protein_type_id': proteinTypeId},
      );

      AppLogger.info('[UserService] Protein preference removed successfully');
    } catch (e) {
      AppLogger.error('[UserService] Failed to remove protein preference', e);
      rethrow;
    }
  }
}