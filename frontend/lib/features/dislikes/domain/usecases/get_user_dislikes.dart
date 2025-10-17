import '../entities/dislike_entity.dart';
import '../repositories/dislike_repository.dart';

class GetUserDislikes {
  final DislikeRepository repository;

  GetUserDislikes(this.repository);

  Future<List<DislikeEntity>> call({String language = 'th'}) async {
    return await repository.getUserDislikes(language: language);
  }
}
