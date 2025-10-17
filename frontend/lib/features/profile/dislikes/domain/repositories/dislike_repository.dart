import '../entities/dislike_entity.dart';

abstract class DislikeRepository {
  Future<void> addDislike({required int menuId, String? reason});
  Future<void> removeDislike({required int menuId});
  Future<List<DislikeEntity>> getUserDislikes({String language = 'th'});
  Future<bool> isMenuDisliked(int menuId);
  Future<void> removeBulkDislikes({required List<int> menuIds});
}
