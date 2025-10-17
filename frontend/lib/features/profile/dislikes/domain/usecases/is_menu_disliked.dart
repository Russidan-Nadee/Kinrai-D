import '../repositories/dislike_repository.dart';

class IsMenuDisliked {
  final DislikeRepository repository;

  IsMenuDisliked(this.repository);

  Future<bool> call(int menuId) async {
    return await repository.isMenuDisliked(menuId);
  }
}
