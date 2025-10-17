import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MenuEntity> getRandomMenu({String? language}) async {
    final menuModel = await remoteDataSource.getRandomMenu(language: language);
    return menuModel.toEntity(language: language ?? 'th');
  }

  @override
  Future<MenuEntity> getPersonalizedRandomMenu({String? language}) async {
    final menuModel = await remoteDataSource.getPersonalizedRandomMenu(language: language);
    return menuModel.toEntity(language: language ?? 'th');
  }

  @override
  Future<List<MenuEntity>> getAllMenus({
    String? language,
    int? limit,
    int? page,
  }) async {
    final menuModels = await remoteDataSource.getAllMenus(
      language: language,
      limit: limit,
      page: page,
    );
    return menuModels.map((model) => model.toEntity(language: language ?? 'th')).toList();
  }

  @override
  Future<MenuEntity> getMenuById(int id, {String? language}) async {
    final menuModel = await remoteDataSource.getMenuById(id, language: language);
    return menuModel.toEntity(language: language ?? 'th');
  }
}
