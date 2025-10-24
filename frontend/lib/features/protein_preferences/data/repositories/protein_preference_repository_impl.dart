import '../../../../core/cache/cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/protein_preference_entity.dart';
import '../../domain/repositories/protein_preference_repository.dart';
import '../datasources/protein_preference_remote_data_source.dart';

class ProteinPreferenceRepositoryImpl implements ProteinPreferenceRepository {
  final ProteinPreferenceRemoteDataSource remoteDataSource;

  ProteinPreferenceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProteinTypeEntity>> getAvailableProteinTypes({String language = 'th'}) async {
    AppLogger.info('🔍 [ProteinRepo] Checking cache for available protein types...');

    // Cache-first strategy: Try cache first, then API
    try {
      final cachedData = await CacheService.getAvailableProteinTypes();
      AppLogger.info('🔍 [ProteinRepo] Cache result: ${cachedData?.length ?? 0} items');

      if (cachedData != null && cachedData.isNotEmpty) {
        AppLogger.info('🎯 [CACHE HIT] Available protein types loaded from cache (${cachedData.length} items)');
        // Background sync: Refresh cache in background
        _refreshProteinTypesInBackground(language: language);

        return cachedData.map((json) {
          return ProteinTypeEntity(
            id: json['id'] as int,
            key: json['key'] as String,
            name: json['name'] as String,
          );
        }).toList();
      }
    } catch (e) {
      AppLogger.error('❌ [CACHE ERROR] Failed to load from cache', e);
    }

    // Cache miss: Fetch from API
    AppLogger.info('❌ [CACHE MISS] Fetching from API...');
    final models = await remoteDataSource.getAvailableProteinTypes(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    // Save to cache for next time
    try {
      final jsonList = entities.map((entity) => {
        'id': entity.id,
        'key': entity.key,
        'name': entity.name,
      }).toList();
      AppLogger.info('💾 [CACHE SAVE] Saving ${jsonList.length} protein types to cache...');
      await CacheService.saveAvailableProteinTypes(jsonList);
      AppLogger.info('✅ [CACHE SAVE] Successfully saved to cache');
    } catch (e) {
      AppLogger.error('❌ [CACHE SAVE ERROR] Failed to save to cache', e);
    }

    return entities;
  }

  /// Background refresh: Update cache without blocking UI
  Future<void> _refreshProteinTypesInBackground({required String language}) async {
    try {
      final models = await remoteDataSource.getAvailableProteinTypes(language: language);
      final entities = models.map((model) => model.toEntity(language: language)).toList();
      final jsonList = entities.map((entity) => {
        'id': entity.id,
        'key': entity.key,
        'name': entity.name,
      }).toList();
      await CacheService.saveAvailableProteinTypes(jsonList);
    } catch (e) {
      // Background refresh failed: ignore, cached data still valid
    }
  }

  @override
  Future<List<ProteinPreferenceEntity>> getUserProteinPreferences({String language = 'th'}) async {
    // Cache-first strategy
    try {
      final cachedData = await CacheService.getUserProteinPreferences();
      if (cachedData != null && cachedData.isNotEmpty) {
        // Background sync
        _refreshUserPreferencesInBackground(language: language);

        return cachedData.map((json) {
          return ProteinPreferenceEntity(
            proteinTypeId: json['protein_type_id'] as int,
            proteinTypeName: json['protein_type_name'] as String,
            exclude: json['exclude'] as bool,
          );
        }).toList();
      }
    } catch (e) {
      // Cache error: fallback to API
    }

    // Cache miss: Fetch from API
    final models = await remoteDataSource.getUserProteinPreferences(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    // Save to cache
    try {
      final jsonList = entities.map((entity) => {
        'protein_type_id': entity.proteinTypeId,
        'protein_type_name': entity.proteinTypeName,
        'exclude': entity.exclude,
      }).toList();
      await CacheService.saveUserProteinPreferences(jsonList);
    } catch (e) {
      // Cache save error: ignore
    }

    return entities;
  }

  /// Background refresh for user preferences
  Future<void> _refreshUserPreferencesInBackground({required String language}) async {
    try {
      final models = await remoteDataSource.getUserProteinPreferences(language: language);
      final entities = models.map((model) => model.toEntity(language: language)).toList();
      final jsonList = entities.map((entity) => {
        'protein_type_id': entity.proteinTypeId,
        'protein_type_name': entity.proteinTypeName,
        'exclude': entity.exclude,
      }).toList();
      await CacheService.saveUserProteinPreferences(jsonList);
    } catch (e) {
      // Background refresh failed: ignore
    }
  }

  @override
  Future<void> setProteinPreference({required int proteinTypeId, required bool exclude}) async {
    await remoteDataSource.setProteinPreference(
      proteinTypeId: proteinTypeId,
      exclude: exclude,
    );
    // Invalidate cache after mutation
    await CacheService.clearProteinPreferences();
  }

  @override
  Future<void> removeProteinPreference({required int proteinTypeId}) async {
    await remoteDataSource.removeProteinPreference(proteinTypeId: proteinTypeId);
    // Invalidate cache after mutation
    await CacheService.clearProteinPreferences();
  }
}
