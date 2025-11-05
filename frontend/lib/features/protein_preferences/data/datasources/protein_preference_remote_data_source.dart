import '../../../../../core/api/api_client.dart';
import '../../../../../core/utils/logger.dart';
import '../models/protein_preference_model.dart';

abstract class ProteinPreferenceRemoteDataSource {
  Future<List<ProteinTypeModel>> getAvailableProteinTypes({String language = 'th'});
  Future<List<ProteinPreferenceModel>> getUserProteinPreferences({String language = 'th'});
  Future<void> setProteinPreference({required int proteinTypeId, required bool exclude});
  Future<void> removeProteinPreference({required int proteinTypeId});
}

class ProteinPreferenceRemoteDataSourceImpl implements ProteinPreferenceRemoteDataSource {
  final ApiClient _apiClient;

  ProteinPreferenceRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<ProteinTypeModel>> getAvailableProteinTypes({String language = 'th'}) async {
    try {
      AppLogger.info('[ProteinPreferenceRemoteDataSource] Fetching available protein types');

      final response = await _apiClient.get(
        '/protein-preferences/available',
        queryParameters: {'language': language},
      );

      AppLogger.info('[ProteinPreferenceRemoteDataSource] Available protein types fetched successfully');

      final List<dynamic> data = response.data;
      return data.map((json) => ProteinTypeModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('[ProteinPreferenceRemoteDataSource] Failed to fetch available protein types', e);
      rethrow;
    }
  }

  @override
  Future<List<ProteinPreferenceModel>> getUserProteinPreferences({String language = 'th'}) async {
    try {
      AppLogger.info('[ProteinPreferenceRemoteDataSource] Fetching user protein preferences');

      final response = await _apiClient.get(
        '/protein-preferences/me',
        queryParameters: {'language': language},
      );

      AppLogger.info('[ProteinPreferenceRemoteDataSource] User protein preferences fetched successfully');

      final List<dynamic> data = response.data;
      return data.map((json) => ProteinPreferenceModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('[ProteinPreferenceRemoteDataSource] Failed to fetch user protein preferences', e);
      rethrow;
    }
  }

  @override
  Future<void> setProteinPreference({required int proteinTypeId, required bool exclude}) async {
    try {
      AppLogger.info('[ProteinPreferenceRemoteDataSource] Setting protein preference: $proteinTypeId, exclude: $exclude');

      await _apiClient.post(
        '/protein-preferences/me',
        data: {
          'protein_type_id': proteinTypeId,
          'exclude': exclude,
        },
      );

      AppLogger.info('[ProteinPreferenceRemoteDataSource] Protein preference set successfully');
    } catch (e) {
      AppLogger.error('[ProteinPreferenceRemoteDataSource] Failed to set protein preference', e);
      rethrow;
    }
  }

  @override
  Future<void> removeProteinPreference({required int proteinTypeId}) async {
    try {
      AppLogger.info('[ProteinPreferenceRemoteDataSource] Removing protein preference: $proteinTypeId');

      await _apiClient.delete(
        '/protein-preferences/me',
        data: {'protein_type_id': proteinTypeId},
      );

      AppLogger.info('[ProteinPreferenceRemoteDataSource] Protein preference removed successfully');
    } catch (e) {
      AppLogger.error('[ProteinPreferenceRemoteDataSource] Failed to remove protein preference', e);
      rethrow;
    }
  }
}
