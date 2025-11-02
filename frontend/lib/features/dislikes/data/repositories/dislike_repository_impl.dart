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
    // Always fetch from API to ensure fresh data
    // This ensures dislike list is always up-to-date
    AppLogger.info('🔄 [DislikeRepo] Fetching fresh dislikes from API...');

    final models = await remoteDataSource.getUserDislikes(language: language);
    final entities = models.map((model) => model.toEntity(language: language)).toList();

    AppLogger.info('✅ [DislikeRepo] Fetched ${entities.length} dislikes from API');
    return entities;
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
