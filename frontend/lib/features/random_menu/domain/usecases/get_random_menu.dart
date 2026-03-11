import '../entities/menu_entity.dart';
import '../repositories/menu_repository.dart';

class GetRandomMenu {
  final MenuRepository repository;

  GetRandomMenu(this.repository);

  Future<MenuEntity> call({String? language}) async {
    return await repository.getRandomMenu(language: language);
  }
}
