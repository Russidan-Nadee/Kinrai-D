import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetPersonalizedRandomMenu {
  final MenuRepository repository;

  GetPersonalizedRandomMenu(this.repository);

  Future<MenuEntity> call({String? language}) async {
    return await repository.getPersonalizedRandomMenu(language: language);
  }
}
