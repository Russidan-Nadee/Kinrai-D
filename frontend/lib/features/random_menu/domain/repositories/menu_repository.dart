import '../entities/menu_entity.dart';

abstract class MenuRepository {
  Future<MenuEntity> getRandomMenu({String? language});
  Future<MenuEntity> getPersonalizedRandomMenu({String? language});
  Future<List<MenuEntity>> getAllMenus({String? language, int? limit, int? page});
  Future<MenuEntity> getMenuById(int id, {String? language});
}
