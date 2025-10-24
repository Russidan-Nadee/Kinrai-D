import '../../../../core/cache/cache_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/dislike_entity.dart';
import '../../domain/repositories/dislike_repository.dart';
import '../datasources/dislike_remote_data_source.dart';

class DislikeRepositoryImpl implements DislikeRepository {
  final DislikeRemoteDataSource remoteDataSource;

  DislikeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addDislike({required int menuId, String? reason}) async {
    await remoteDataSource.addDislike(menuId: menuId, reason: reason);
    // Invalidate cache after adding dislike
    await CacheService.clearDislikes();
  }

  @override
  Future<void> removeDislike({required int menuId}) async {
    await remoteDataSource.removeDislike(menuId: menuId);
    // Invalidate cache after removing dislike
    await CacheService.clearDislikes();
  }

  @override
  Future<List<DislikeEntity>> getUserDislikes({String language = 'th'}) async {
    AppLogger.info('🔍 [DislikeRepo] Checking cache for user dislikes...');

    // Cache-first strategy
    try {
      final cachedData = await CacheService.getDislikes();
      AppLogger.info('🔍 [DislikeRepo] Cache result: ${cachedData?.length ?? 0} items');

      if (cachedData != null && cachedData.isNotEmpty) {
        AppLogger.info('🎯 [CACHE HIT] Dislikes loaded from cache (${cachedData.length} items)');
        // Background refresh
        _refreshDislikesInBackground(language: language);

        return cachedData
            .map((json) => DislikeEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.error('❌ [CACHE ERROR] Failed to load dislikes from cache', e);
    }

    // Fetch from API
    AppLogger.info('❌ [CACHE MISS] Fetching dislikes from API...');
    final models = await remoteDataSource.getUserDislikes(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    // Save to cache
    try {
      final jsonList = entities.map((entity) => entity.toJson()).toList();
      AppLogger.info('💾 [CACHE SAVE] Saving ${jsonList.length} dislikes to cache...');
      await CacheService.saveDislikes(jsonList);
      AppLogger.info('✅ [CACHE SAVE] Successfully saved dislikes to cache');
    } catch (e) {
      AppLogger.error('❌ [CACHE SAVE ERROR] Failed to save dislikes to cache', e);
    }

    return entities;
  }

  /// Background refresh dislikes
  Future<void> _refreshDislikesInBackground({String language = 'th'}) async {
    try {
      final models = await remoteDataSource.getUserDislikes(language: language);
      final entities = models.map((model) => model.toEntity(language: language)).toList();
      final jsonList = entities.map((entity) => entity.toJson()).toList();
      await CacheService.saveDislikes(jsonList);
    } catch (e) {
      // Background refresh failed: ignore
    }
  }

  @override
  Future<bool> isMenuDisliked(int menuId) async {
    final dislikes = await getUserDislikes();
    return dislikes.any((dislike) => dislike.menuId == menuId);
  }

  @override
  Future<void> removeBulkDislikes({required List<int> menuIds}) async {
    await remoteDataSource.removeBulkDislikes(menuIds: menuIds);
    // Invalidate cache after bulk removal
    await CacheService.clearDislikes();
  }
}
