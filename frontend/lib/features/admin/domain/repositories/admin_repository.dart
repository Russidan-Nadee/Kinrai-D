import '../entities/admin_menu_entity.dart';

abstract class AdminRepository {
  Future<AdminMenuListEntity> getMenus({int limit = 1000});
  Future<AdminMenuEntity> getMenuById(int id);
  Future<bool> createMenu(Map<String, dynamic> menuData);
}