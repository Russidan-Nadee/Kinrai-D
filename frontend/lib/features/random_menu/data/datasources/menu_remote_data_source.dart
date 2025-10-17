import '../../../../core/api/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/menu_model.dart';

abstract class MenuRemoteDataSource {
  Future<MenuModel> getRandomMenu({String? language});
  Future<MenuModel> getPersonalizedRandomMenu({String? language});
  Future<List<MenuModel>> getAllMenus({String? language, int? limit, int? page});
  Future<MenuModel> getMenuById(int id, {String? language});
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final ApiClient _apiClient;

  MenuRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient() {
    _apiClient.initialize();
  }

  @override
  Future<MenuModel> getRandomMenu({String? language}) async {
    try {
      AppLogger.info('[MenuRemoteDataSource] Fetching random menu...');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;

      final response = await _apiClient.get(
        '/menus/random',
        queryParameters: queryParams,
      );

      AppLogger.info('[MenuRemoteDataSource] Random menu fetched successfully');
      return MenuModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('[MenuRemoteDataSource] Failed to fetch random menu', e);
      rethrow;
    }
  }

  @override
  Future<MenuModel> getPersonalizedRandomMenu({String? language}) async {
    try {
      AppLogger.info('[MenuRemoteDataSource] Fetching personalized random menu...');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;

      final response = await _apiClient.get(
        '/menus/random/personalized',
        queryParameters: queryParams,
      );

      AppLogger.info('[MenuRemoteDataSource] Personalized random menu fetched successfully');
      return MenuModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('[MenuRemoteDataSource] Failed to fetch personalized random menu', e);
      rethrow;
    }
  }

  @override
  Future<List<MenuModel>> getAllMenus({
    String? language,
    int? limit,
    int? page,
  }) async {
    try {
      AppLogger.info('[MenuRemoteDataSource] Fetching all menus...');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (page != null) queryParams['page'] = page.toString();

      final response = await _apiClient.get(
        '/menus',
        queryParameters: queryParams,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        List<dynamic> menuList;
        if (data.containsKey('data') && data['data'] is List) {
          menuList = data['data'] as List<dynamic>;
        } else {
          menuList = [data];
        }

        final menus = <MenuModel>[];
        for (int i = 0; i < menuList.length; i++) {
          try {
            final menu = MenuModel.fromJson(menuList[i] as Map<String, dynamic>);
            menus.add(menu);
          } catch (e) {
            AppLogger.error('[MenuRemoteDataSource] Error parsing menu at index $i', e);
          }
        }

        AppLogger.info('[MenuRemoteDataSource] ${menus.length} menus fetched successfully');
        return menus;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      AppLogger.error('[MenuRemoteDataSource] Failed to fetch menus', e);
      rethrow;
    }
  }

  @override
  Future<MenuModel> getMenuById(int id, {String? language}) async {
    try {
      AppLogger.info('[MenuRemoteDataSource] Fetching menu by ID: $id');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;

      final response = await _apiClient.get(
        '/menus/$id',
        queryParameters: queryParams,
      );

      AppLogger.info('[MenuRemoteDataSource] Menu fetched successfully');
      return MenuModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('[MenuRemoteDataSource] Failed to fetch menu by ID', e);
      rethrow;
    }
  }
}
