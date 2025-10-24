import 'package:hive_flutter/hive_flutter.dart';

/// Cache service for managing local data storage using Hive
class CacheService {
  static const String _menusBox = 'menus';
  static const String _favoritesBox = 'favorites';
  static const String _dislikesBox = 'dislikes';
  static const String _categoriesBox = 'categories';
  static const String _proteinPreferencesBox = 'protein_preferences';
  static const String _metadataBox = 'metadata';

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(_menusBox);
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_dislikesBox);
    await Hive.openBox(_categoriesBox);
    await Hive.openBox(_proteinPreferencesBox);
    await Hive.openBox(_metadataBox);
  }

  /// Check if cache is expired
  static bool _isExpired(String key, Duration ttl) {
    final box = Hive.box(_metadataBox);
    final timestamp = box.get('${key}_timestamp');

    if (timestamp == null) return true;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp as int);
    return DateTime.now().difference(cachedTime) > ttl;
  }

  /// Update cache timestamp
  static Future<void> _updateTimestamp(String key) async {
    final box = Hive.box(_metadataBox);
    await box.put('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // ==================== MENUS ====================

  /// Get cached menus list
  static Future<List<Map<String, dynamic>>?> getMenus() async {
    try {
      final box = Hive.box(_menusBox);
      final data = box.get('menus_list');

      if (data == null) return null;

      // Check if expired (1 day)
      if (_isExpired('menus_list', const Duration(days: 1))) {
        return null;
      }

      // Convert dynamic list to typed list
      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache menus list
  static Future<void> saveMenus(List<Map<String, dynamic>> menus) async {
    final box = Hive.box(_menusBox);
    await box.put('menus_list', menus);
    await _updateTimestamp('menus_list');
  }

  /// Clear menus cache
  static Future<void> clearMenus() async {
    final box = Hive.box(_menusBox);
    await box.delete('menus_list');
    final metaBox = Hive.box(_metadataBox);
    await metaBox.delete('menus_list_timestamp');
  }

  // ==================== FAVORITES ====================

  /// Get cached favorites
  static Future<List<dynamic>?> getFavorites() async {
    try {
      final box = Hive.box(_favoritesBox);
      final data = box.get('favorites_list');

      if (data == null) return null;

      // Check if expired (1 hour)
      if (_isExpired('favorites_list', const Duration(hours: 1))) {
        return null;
      }

      return data is List ? List.from(data) : null;
    } catch (e) {
      return null;
    }
  }

  /// Cache favorites
  static Future<void> saveFavorites(List<dynamic> favorites) async {
    final box = Hive.box(_favoritesBox);
    await box.put('favorites_list', favorites);
    await _updateTimestamp('favorites_list');
  }

  /// Clear favorites cache
  static Future<void> clearFavorites() async {
    final box = Hive.box(_favoritesBox);
    await box.delete('favorites_list');
    final metaBox = Hive.box(_metadataBox);
    await metaBox.delete('favorites_list_timestamp');
  }

  // ==================== ADMIN MENUS ====================

  /// Get cached admin menus with pagination
  static Future<Map<String, dynamic>?> getAdminMenus({int page = 1}) async {
    try {
      final box = Hive.box(_menusBox);
      final key = 'admin_menus_page_$page';
      final data = box.get(key);

      if (data == null) return null;

      // Check if expired (5 minutes for admin data - fresher than user menus)
      if (_isExpired(key, const Duration(minutes: 5))) {
        return null;
      }

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache admin menus with pagination
  static Future<void> saveAdminMenus(Map<String, dynamic> data, {int page = 1}) async {
    final box = Hive.box(_menusBox);
    final key = 'admin_menus_page_$page';
    await box.put(key, data);
    await _updateTimestamp(key);
  }

  /// Clear all admin menus cache
  static Future<void> clearAdminMenus() async {
    final box = Hive.box(_menusBox);
    final metaBox = Hive.box(_metadataBox);

    // Clear all pages (max 100 pages)
    for (int page = 1; page <= 100; page++) {
      final key = 'admin_menus_page_$page';
      await box.delete(key);
      await metaBox.delete('${key}_timestamp');
    }
  }

  // ==================== CATEGORIES (Food Types, Categories, Subcategories) ====================

  /// Get cached food types
  static Future<List<Map<String, dynamic>>?> getFoodTypes() async {
    try {
      final box = Hive.box(_categoriesBox);
      final data = box.get('food_types');

      if (data == null) return null;

      // Check if expired (10 minutes - master data doesn't change often)
      if (_isExpired('food_types', const Duration(minutes: 10))) {
        return null;
      }

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache food types
  static Future<void> saveFoodTypes(List<Map<String, dynamic>> foodTypes) async {
    final box = Hive.box(_categoriesBox);
    await box.put('food_types', foodTypes);
    await _updateTimestamp('food_types');
  }

  /// Get cached categories (all or by food type)
  static Future<List<Map<String, dynamic>>?> getCategories({int? foodTypeId}) async {
    try {
      final box = Hive.box(_categoriesBox);
      final key = foodTypeId == null ? 'categories_all' : 'categories_ft_$foodTypeId';
      final data = box.get(key);

      if (data == null) return null;

      // Check if expired (10 minutes)
      if (_isExpired(key, const Duration(minutes: 10))) {
        return null;
      }

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache categories
  static Future<void> saveCategories(List<Map<String, dynamic>> categories, {int? foodTypeId}) async {
    final box = Hive.box(_categoriesBox);
    final key = foodTypeId == null ? 'categories_all' : 'categories_ft_$foodTypeId';
    await box.put(key, categories);
    await _updateTimestamp(key);
  }

  /// Get cached subcategories (all, by food type, or by category)
  static Future<List<Map<String, dynamic>>?> getSubcategories({
    int? foodTypeId,
    int? categoryId,
  }) async {
    try {
      final box = Hive.box(_categoriesBox);
      String key;

      if (categoryId != null) {
        key = 'subcategories_cat_$categoryId';
      } else if (foodTypeId != null) {
        key = 'subcategories_ft_$foodTypeId';
      } else {
        key = 'subcategories_all';
      }

      final data = box.get(key);

      if (data == null) return null;

      // Check if expired (10 minutes)
      if (_isExpired(key, const Duration(minutes: 10))) {
        return null;
      }

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache subcategories
  static Future<void> saveSubcategories(
    List<Map<String, dynamic>> subcategories, {
    int? foodTypeId,
    int? categoryId,
  }) async {
    final box = Hive.box(_categoriesBox);
    String key;

    if (categoryId != null) {
      key = 'subcategories_cat_$categoryId';
    } else if (foodTypeId != null) {
      key = 'subcategories_ft_$foodTypeId';
    } else {
      key = 'subcategories_all';
    }

    await box.put(key, subcategories);
    await _updateTimestamp(key);
  }

  /// Clear all categories cache (food types, categories, subcategories)
  static Future<void> clearCategories() async {
    final box = Hive.box(_categoriesBox);
    final metaBox = Hive.box(_metadataBox);

    // Clear all keys in categories box
    await box.clear();

    // Clear metadata for categories
    final keysToDelete = metaBox.keys
        .where((key) => key.toString().startsWith('food_types') ||
                        key.toString().startsWith('categories') ||
                        key.toString().startsWith('subcategories'))
        .toList();

    for (final key in keysToDelete) {
      await metaBox.delete(key);
    }
  }

  // ==================== PROTEIN PREFERENCES ====================

  /// Get cached available protein types
  static Future<List<Map<String, dynamic>>?> getAvailableProteinTypes() async {
    try {
      final box = Hive.box(_proteinPreferencesBox);
      final data = box.get('available_protein_types');

      if (data == null) return null;

      // Check if expired (10 minutes - master data doesn't change often)
      if (_isExpired('available_protein_types', const Duration(minutes: 10))) {
        return null;
      }

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache available protein types
  static Future<void> saveAvailableProteinTypes(List<Map<String, dynamic>> proteinTypes) async {
    final box = Hive.box(_proteinPreferencesBox);
    await box.put('available_protein_types', proteinTypes);
    await _updateTimestamp('available_protein_types');
  }

  /// Get cached user protein preferences
  static Future<List<Map<String, dynamic>>?> getUserProteinPreferences() async {
    try {
      final box = Hive.box(_proteinPreferencesBox);
      final data = box.get('user_protein_preferences');

      if (data == null) return null;

      // Check if expired (5 minutes - user preferences change more often)
      if (_isExpired('user_protein_preferences', const Duration(minutes: 5))) {
        return null;
      }

      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache user protein preferences
  static Future<void> saveUserProteinPreferences(List<Map<String, dynamic>> preferences) async {
    final box = Hive.box(_proteinPreferencesBox);
    await box.put('user_protein_preferences', preferences);
    await _updateTimestamp('user_protein_preferences');
  }

  /// Clear all protein preferences cache
  static Future<void> clearProteinPreferences() async {
    final box = Hive.box(_proteinPreferencesBox);
    final metaBox = Hive.box(_metadataBox);

    await box.delete('available_protein_types');
    await box.delete('user_protein_preferences');
    await metaBox.delete('available_protein_types_timestamp');
    await metaBox.delete('user_protein_preferences_timestamp');
  }

  // ==================== DISLIKES ====================

  /// Get cached dislikes
  static Future<List<dynamic>?> getDislikes() async {
    try {
      final box = Hive.box(_dislikesBox);
      final data = box.get('dislikes_list');

      if (data == null) return null;

      // Check if expired (1 hour)
      if (_isExpired('dislikes_list', const Duration(hours: 1))) {
        return null;
      }

      return data is List ? List.from(data) : null;
    } catch (e) {
      return null;
    }
  }

  /// Cache dislikes
  static Future<void> saveDislikes(List<dynamic> dislikes) async {
    final box = Hive.box(_dislikesBox);
    await box.put('dislikes_list', dislikes);
    await _updateTimestamp('dislikes_list');
  }

  /// Clear dislikes cache
  static Future<void> clearDislikes() async {
    final box = Hive.box(_dislikesBox);
    await box.delete('dislikes_list');
    final metaBox = Hive.box(_metadataBox);
    await metaBox.delete('dislikes_list_timestamp');
  }

  // ==================== UTILITY ====================

  /// Clear all caches
  static Future<void> clearAll() async {
    await clearMenus();
    await clearFavorites();
    await clearAdminMenus();
    await clearCategories();
    await clearProteinPreferences();
    await clearDislikes();
  }

  /// Get cache statistics
  static Map<String, dynamic> getStats() {
    final menusBox = Hive.box(_menusBox);
    final favoritesBox = Hive.box(_favoritesBox);
    final dislikesBox = Hive.box(_dislikesBox);
    final metadataBox = Hive.box(_metadataBox);

    return {
      'menus_cached': menusBox.containsKey('menus_list'),
      'favorites_cached': favoritesBox.containsKey('favorites_list'),
      'dislikes_cached': dislikesBox.containsKey('dislikes_list'),
      'total_keys': menusBox.length + favoritesBox.length + dislikesBox.length,
      'metadata_keys': metadataBox.length,
    };
  }

  /// Close all boxes (call when app is closed)
  static Future<void> close() async {
    await Hive.close();
  }
}
