import '../entities/admin_menu_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminMenus {
  final AdminRepository repository;

  const GetAdminMenus({required this.repository});

  Future<AdminMenuListEntity> call({int limit = 1000}) async {
    return await repository.getMenus(limit: limit);
  }
}