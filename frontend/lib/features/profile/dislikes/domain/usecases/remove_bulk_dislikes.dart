import '../repositories/dislike_repository.dart';

class RemoveBulkDislikes {
  final DislikeRepository repository;

  RemoveBulkDislikes(this.repository);

  Future<void> call({required List<int> menuIds}) async {
    return await repository.removeBulkDislikes(menuIds: menuIds);
  }
}
