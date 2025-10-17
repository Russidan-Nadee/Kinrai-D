import '../repositories/dislike_repository.dart';

class RemoveDislike {
  final DislikeRepository repository;

  RemoveDislike(this.repository);

  Future<void> call({required int menuId}) async {
    return await repository.removeDislike(menuId: menuId);
  }
}
