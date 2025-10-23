import '../../../../core/cache/cache_service.dart';
import '../../domain/entities/menu_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';
import '../models/menu_model.dart';

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
    // Cache-first strategy: Try cache first, then API
    try {
      // Check cache first (instant!)
      final cachedData = await CacheService.getMenus();
      if (cachedData != null && cachedData.isNotEmpty) {
        // Convert cached data to entities
        final menuModels = cachedData
            .map((json) => MenuModel.fromJson(json))
            .toList();

        // Background sync: Refresh cache in background
        _refreshMenusInBackground(language: language, limit: limit, page: page);

        return menuModels
            .map((model) => model.toEntity(language: language ?? 'th'))
            .toList();
      }
    } catch (e) {
      // Cache error: fallback to API
    }

    // Cache miss or error: Fetch from API
    final menuModels = await remoteDataSource.getAllMenus(
      language: language,
      limit: limit,
      page: page,
    );

    // Save to cache for next time
    try {
      final jsonList = menuModels.map((model) => model.toJson()).toList();
      await CacheService.saveMenus(jsonList);
    } catch (e) {
      // Cache save error: ignore, API data still works
    }

    return menuModels
        .map((model) => model.toEntity(language: language ?? 'th'))
        .toList();
  }

  /// Background refresh: Update cache without blocking UI
  Future<void> _refreshMenusInBackground({
    String? language,
    int? limit,
    int? page,
  }) async {
    try {
      final menuModels = await remoteDataSource.getAllMenus(
        language: language,
        limit: limit,
        page: page,
      );
      final jsonList = menuModels.map((model) => model.toJson()).toList();
      await CacheService.saveMenus(jsonList);
    } catch (e) {
      // Background refresh failed: ignore, cached data still valid
    }
  }

  @override
  Future<MenuEntity> getMenuById(int id, {String? language}) async {
    final menuModel = await remoteDataSource.getMenuById(id, language: language);
    return menuModel.toEntity(language: language ?? 'th');
  }
}
