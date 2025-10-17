import '../repositories/dislike_repository.dart';

class AddDislike {
  final DislikeRepository repository;

  AddDislike(this.repository);

  Future<void> call({required int menuId, String? reason}) async {
    return await repository.addDislike(menuId: menuId, reason: reason);
  }
}
