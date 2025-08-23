import '../../domain/entities/admin_menu_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  const AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AdminMenuListEntity> getMenus({int limit = 1000}) async {
    final model = await remoteDataSource.getMenus(limit: limit);
    
    return AdminMenuListEntity(
      menus: model.menus.map((menu) => AdminMenuEntity(
        id: menu.id,
        key: menu.key,
        imageUrl: menu.imageUrl,
        mealTime: menu.mealTime,
        isActive: menu.isActive,
        name: menu.name,
        createdAt: DateTime.now(), // TODO: Add from model when available
        updatedAt: DateTime.now(), // TODO: Add from model when available
      )).toList(),
      pagination: PaginationEntity(
        page: model.pagination.page,
        limit: model.pagination.limit,
        total: model.pagination.total,
        totalPages: model.pagination.totalPages,
      ),
    );
  }

  @override
  Future<AdminMenuEntity> getMenuById(int id) async {
    // TODO: Implement when needed
    throw UnimplementedError();
  }

  @override
  Future<bool> createMenu(Map<String, dynamic> menuData) async {
    return await remoteDataSource.createMenu(menuData);
  }
}