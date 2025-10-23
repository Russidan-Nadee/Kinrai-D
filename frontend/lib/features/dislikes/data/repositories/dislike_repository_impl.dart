import '../../../../core/cache/cache_service.dart';
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
    // Cache-first strategy
    try {
      final cachedData = await CacheService.getDislikes();
      if (cachedData != null && cachedData.isNotEmpty) {
        // Background refresh
        _refreshDislikesInBackground(language: language);

        return cachedData
            .map((json) => DislikeEntity.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Cache error: fallback to API
    }

    // Fetch from API
    final models = await remoteDataSource.getUserDislikes(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    // Save to cache
    try {
      final jsonList = entities.map((entity) => entity.toJson()).toList();
      await CacheService.saveDislikes(jsonList);
    } catch (e) {
      // Cache save error: ignore
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
