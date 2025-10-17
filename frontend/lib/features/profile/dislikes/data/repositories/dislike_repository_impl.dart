import '../../domain/entities/dislike_entity.dart';
import '../../domain/repositories/dislike_repository.dart';
import '../datasources/dislike_remote_data_source.dart';

class DislikeRepositoryImpl implements DislikeRepository {
  final DislikeRemoteDataSource remoteDataSource;

  DislikeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addDislike({required int menuId, String? reason}) async {
    return await remoteDataSource.addDislike(menuId: menuId, reason: reason);
  }

  @override
  Future<void> removeDislike({required int menuId}) async {
    return await remoteDataSource.removeDislike(menuId: menuId);
  }

  @override
  Future<List<DislikeEntity>> getUserDislikes({String language = 'th'}) async {
    final models = await remoteDataSource.getUserDislikes(language: language);
    return models.map((model) => model.toEntity(language: language)).toList();
  }

  @override
  Future<bool> isMenuDisliked(int menuId) async {
    final dislikes = await getUserDislikes();
    return dislikes.any((dislike) => dislike.menuId == menuId);
  }

  @override
  Future<void> removeBulkDislikes({required List<int> menuIds}) async {
    return await remoteDataSource.removeBulkDislikes(menuIds: menuIds);
  }
}
