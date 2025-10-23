import 'package:hive_flutter/hive_flutter.dart';

/// Cache service for managing local data storage using Hive
class CacheService {
  static const String _menusBox = 'menus';
  static const String _favoritesBox = 'favorites';
  static const String _dislikesBox = 'dislikes';
  static const String _metadataBox = 'metadata';

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes
    await Hive.openBox(_menusBox);
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_dislikesBox);
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
