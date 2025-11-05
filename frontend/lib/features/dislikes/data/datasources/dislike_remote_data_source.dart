import '../../../../../core/api/api_client.dart';
import '../../../../../core/utils/logger.dart';
import '../models/dislike_model.dart';

abstract class DislikeRemoteDataSource {
  Future<void> addDislike({required int menuId, String? reason});
  Future<void> removeDislike({required int menuId});
  Future<List<DislikeModel>> getUserDislikes({String language = 'th'});
  Future<void> removeBulkDislikes({required List<int> menuIds});
}

class DislikeRemoteDataSourceImpl implements DislikeRemoteDataSource {
  final ApiClient _apiClient;

  DislikeRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<void> addDislike({required int menuId, String? reason}) async {
    try {
      AppLogger.info('[DislikeRemoteDataSource] Adding dislike for menu: $menuId');

      final requestData = <String, dynamic>{'menu_id': menuId};
      if (reason != null && reason.isNotEmpty) {
        requestData['reason'] = reason;
      }

      await _apiClient.post(
        '/user-profiles/me/dislikes',
        data: requestData,
      );

      AppLogger.info('[DislikeRemoteDataSource] Dislike added successfully');
    } catch (e) {
      AppLogger.error('[DislikeRemoteDataSource] Failed to add dislike', e);
      rethrow;
    }
  }

  @override
  Future<void> removeDislike({required int menuId}) async {
    try {
      AppLogger.info('[DislikeRemoteDataSource] Removing dislike for menu: $menuId');

      await _apiClient.delete(
        '/user-profiles/me/dislikes',
        data: {'menu_id': menuId},
      );

      AppLogger.info('[DislikeRemoteDataSource] Dislike removed successfully');
    } catch (e) {
      AppLogger.error('[DislikeRemoteDataSource] Failed to remove dislike', e);
      rethrow;
    }
  }

  @override
  Future<List<DislikeModel>> getUserDislikes({String language = 'th'}) async {
    try {
      AppLogger.info('[DislikeRemoteDataSource] Fetching user dislikes');

      final response = await _apiClient.get(
        '/user-profiles/me/dislikes',
        queryParameters: {'language': language},
      );

      AppLogger.info('[DislikeRemoteDataSource] User dislikes fetched successfully');

      final List<dynamic> data = response.data;
      return data.map((json) => DislikeModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('[DislikeRemoteDataSource] Failed to fetch user dislikes', e);
      rethrow;
    }
  }

  @override
  Future<void> removeBulkDislikes({required List<int> menuIds}) async {
    try {
      AppLogger.info('[DislikeRemoteDataSource] Removing bulk dislikes: $menuIds');

      await _apiClient.delete(
        '/user-profiles/me/dislikes/bulk',
        data: {'menu_ids': menuIds},
      );

      AppLogger.info('[DislikeRemoteDataSource] Bulk dislikes removed successfully');
    } catch (e) {
      AppLogger.error('[DislikeRemoteDataSource] Failed to remove bulk dislikes', e);
      rethrow;
    }
  }
}
