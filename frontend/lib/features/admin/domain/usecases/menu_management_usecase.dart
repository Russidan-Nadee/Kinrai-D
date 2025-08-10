import '../entities/admin_menu_entity.dart';
import '../repositories/admin_repository.dart';

class MenuManagementUseCase {
  final AdminRepository repository;

  MenuManagementUseCase(this.repository);

  Future<List<AdminMenuEntity>> getMenus({
    int page = 1,
    int limit = 10,
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
  }) {
    return repository.getMenus(
      page: page,
      limit: limit,
      search: search,
      subcategoryId: subcategoryId,
      mealTime: mealTime,
      isActive: isActive,
    );
  }

  Future<AdminMenuEntity> getMenuById(int id) {
    return repository.getMenuById(id);
  }

  Future<AdminMenuEntity> createMenu(AdminMenuEntity menu) {
    return repository.createMenu(menu);
  }

  Future<AdminMenuEntity> updateMenu(int id, AdminMenuEntity menu) {
    return repository.updateMenu(id, menu);
  }

  Future<void> deleteMenu(int id) {
    return repository.deleteMenu(id);
  }

  Future<void> toggleMenuStatus(int id, bool isActive) {
    if (isActive) {
      return repository.activateMenu(id);
    } else {
      return repository.deactivateMenu(id);
    }
  }
}