import 'dart:math';
import '../api/api_client.dart';
import '../models/menu_model.dart';

class MenuService {
  late final ApiClient _apiClient;

  MenuService() {
    _apiClient = ApiClient();
    _apiClient.initialize();
  }

  /// ดึงเมนูทั้งหมด
  Future<List<MenuModel>> getAllMenus({
    String? language = 'th',
    int? limit,
    int? page,
  }) async {
    try {
      print('[MenuService] Attempting to fetch all menus...');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;
      if (limit != null) queryParams['limit'] = limit.toString();
      if (page != null) queryParams['page'] = page.toString();

      final response = await _apiClient.get(
        '/menus',
        queryParameters: queryParams,
      );

      print('[MenuService] Response received: ${response.statusCode}');
      print('[MenuService] Response data type: ${response.data.runtimeType}');

      // ตรวจสอบโครงสร้างข้อมูล
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('[MenuService] Response keys: ${data.keys.toList()}');

        // ลองหาข้อมูลเมนูจากโครงสร้างที่ต่างกัน
        List<dynamic> menuList;
        if (data.containsKey('data') && data['data'] is List) {
          menuList = data['data'] as List<dynamic>;
        } else {
          // หากไม่ใช่ List ให้ใช้ทั้ง Map เป็น List item เดียว
          menuList = [data];
        }

        print('[MenuService] Found ${menuList.length} menus');

        final menus = <MenuModel>[];
        for (int i = 0; i < menuList.length; i++) {
          try {
            final menu = MenuModel.fromJson(menuList[i] as Map<String, dynamic>);
            menus.add(menu);
          } catch (e) {
            print('[MenuService] Error parsing menu at index $i: $e');
            print('[MenuService] Menu data: ${menuList[i]}');
          }
        }

        return menus;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('[MenuService] Menus fetch failed: $e');
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Network error')) {
        throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต');
      }
      rethrow;
    }
  }

  /// ดึงเมนูที่นิยม
  Future<List<MenuModel>> getPopularMenus({
    String? language = 'th',
    int? limit,
  }) async {
    try {
      print('[MenuService] Attempting to fetch popular menus...');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _apiClient.get(
        '/menus/popular',
        queryParameters: queryParams,
      );

      print('[MenuService] Popular menus fetch successful');

      final List<dynamic> menuList = response.data['data'] ?? response.data;
      return menuList.map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      print('[MenuService] Popular menus fetch failed: $e');
      rethrow;
    }
  }

  /// สุ่มเมนู 1 รายการ (ใช้ API endpoint ที่เฉพาะเจาะจง)
  Future<MenuModel> getRandomMenu({String? language = 'th'}) async {
    try {
      print('[MenuService] Attempting to get random menu from API...');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;

      final response = await _apiClient.get(
        '/menus/random',
        queryParameters: queryParams,
      );

      print('[MenuService] Random menu API call successful');

      // สำหรับ single menu response
      final MenuModel randomMenu = MenuModel.fromJson(response.data);
      print('[MenuService] Random menu selected: ${randomMenu.getName(language: language ?? 'th')}');

      return randomMenu;
    } catch (e) {
      print('[MenuService] Random menu fetch failed: $e');
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Network error')) {
        throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต');
      }
      rethrow;
    }
  }

  /// สุ่มเมนูหลายรายการ
  Future<List<MenuModel>> getRandomMenus({
    String? language = 'th',
    int count = 5,
  }) async {
    try {
      print('[MenuService] Attempting to get $count random menus...');

      final allMenus = await getAllMenus(language: language);

      if (allMenus.isEmpty) {
        throw Exception('No menus available');
      }

      final random = Random();
      final selectedMenus = <MenuModel>[];
      final availableMenus = List<MenuModel>.from(allMenus);

      final actualCount = count > availableMenus.length ? availableMenus.length : count;

      for (int i = 0; i < actualCount; i++) {
        final randomIndex = random.nextInt(availableMenus.length);
        selectedMenus.add(availableMenus.removeAt(randomIndex));
      }

      print('[MenuService] $actualCount random menus selected');

      return selectedMenus;
    } catch (e) {
      print('[MenuService] Random menus fetch failed: $e');
      rethrow;
    }
  }

  /// ดึงเมนูตาม ID
  Future<MenuModel> getMenuById(int id, {String? language = 'th'}) async {
    try {
      print('[MenuService] Attempting to fetch menu by ID: $id');

      final queryParams = <String, dynamic>{};
      if (language != null) queryParams['language'] = language;

      final response = await _apiClient.get(
        '/menus/$id',
        queryParameters: queryParams,
      );

      print('[MenuService] Menu fetch by ID successful');

      return MenuModel.fromJson(response.data);
    } catch (e) {
      print('[MenuService] Menu fetch by ID failed: $e');
      rethrow;
    }
  }

  /// ค้นหาเมนู
  Future<List<MenuModel>> searchMenus({
    String? searchTerm,
    String? language = 'th',
    String? mealTime,
    double? minRating,
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('[MenuService] Attempting to search menus...');

      final queryParams = <String, dynamic>{};
      if (searchTerm != null) queryParams['search'] = searchTerm;
      if (language != null) queryParams['language'] = language;
      if (mealTime != null) queryParams['meal_time'] = mealTime;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _apiClient.get(
        '/menus/search',
        queryParameters: queryParams,
      );

      print('[MenuService] Menu search successful');

      final List<dynamic> menuList = response.data['data'] ?? response.data;
      return menuList.map((json) => MenuModel.fromJson(json)).toList();
    } catch (e) {
      print('[MenuService] Menu search failed: $e');
      rethrow;
    }
  }
}