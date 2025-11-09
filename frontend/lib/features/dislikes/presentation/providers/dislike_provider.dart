import 'package:flutter/material.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/dislike_entity.dart';
import '../../domain/usecases/get_user_dislikes.dart';
import '../../domain/usecases/remove_dislike.dart';
import '../../domain/usecases/remove_bulk_dislikes.dart';

/// Provider to manage dislike-related state and operations
class DislikeProvider extends ChangeNotifier {
  // Dependencies
  final GetUserDislikes _getUserDislikes;
  final RemoveDislike _removeDislike;
  final RemoveBulkDislikes _removeBulkDislikes;

  // State
  List<DislikeEntity> _dislikes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Bulk mode state
  bool _isBulkMode = false;
  Set<int> _selectedMenuIds = {};

  // Filtering & Search
  String _searchQuery = '';

  // Getters
  List<DislikeEntity> get dislikes => _filteredDislikes;
  List<DislikeEntity> get allDislikes => _dislikes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBulkMode => _isBulkMode;
  Set<int> get selectedMenuIds => _selectedMenuIds;
  int get selectedCount => _selectedMenuIds.length;
  int get totalCount => _dislikes.length;
  String get searchQuery => _searchQuery;

  // Filtered dislikes based on search query
  List<DislikeEntity> get _filteredDislikes {
    if (_searchQuery.isEmpty) {
      return _dislikes;
    }

    final query = _searchQuery.toLowerCase();
    return _dislikes.where((dislike) {
      final menuName = dislike.menuName.toLowerCase();
      final description = dislike.menuDescription?.toLowerCase() ?? '';
      final reason = dislike.reason?.toLowerCase() ?? '';

      return menuName.contains(query) ||
          description.contains(query) ||
          reason.contains(query);
    }).toList();
  }

  DislikeProvider({
    required GetUserDislikes getUserDislikes,
    required RemoveDislike removeDislike,
    required RemoveBulkDislikes removeBulkDislikes,
  })  : _getUserDislikes = getUserDislikes,
        _removeDislike = removeDislike,
        _removeBulkDislikes = removeBulkDislikes;

  /// Load all dislikes with cache-first strategy
  Future<void> loadDislikes({required String language}) async {
    try {
      AppLogger.info('🚀 [DislikeProvider] Loading dislikes...');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _dislikes = await _getUserDislikes(language: language);

      // Sort alphabetically by menu name
      _dislikes.sort((a, b) => a.menuName.toLowerCase().compareTo(b.menuName.toLowerCase()));

      AppLogger.info('✅ [DislikeProvider] Loaded ${_dislikes.length} dislikes');
    } catch (e) {
      AppLogger.error('❌ [DislikeProvider] Error loading dislikes', e);
      _errorMessage = 'Failed to load dislikes';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove a single dislike
  Future<bool> removeDislike(int menuId, String language) async {
    try {
      AppLogger.info('🗑️ [DislikeProvider] Removing dislike: $menuId');

      // Optimistic update
      _dislikes = _dislikes.where((d) => d.menuId != menuId).toList();
      notifyListeners();

      // API call
      await _removeDislike(menuId: menuId);

      // Reload to ensure consistency
      await loadDislikes(language: language);

      AppLogger.info('✅ [DislikeProvider] Removed dislike successfully');
      return true;
    } catch (e) {
      AppLogger.error('❌ [DislikeProvider] Error removing dislike', e);

      // Reload on error to restore correct state
      await loadDislikes(language: language);
      return false;
    }
  }

  /// Remove multiple dislikes at once
  Future<bool> removeBulkDislikes(List<int> menuIds, String language) async {
    if (menuIds.isEmpty) return false;

    try {
      AppLogger.info('🗑️ [DislikeProvider] Removing ${menuIds.length} dislikes');

      // Optimistic update
      _dislikes = _dislikes.where((d) => !menuIds.contains(d.menuId)).toList();
      notifyListeners();

      // API call
      await _removeBulkDislikes(menuIds: menuIds);

      // Clear selection and exit bulk mode
      _selectedMenuIds.clear();
      _isBulkMode = false;

      // Reload to ensure consistency
      await loadDislikes(language: language);

      AppLogger.info('✅ [DislikeProvider] Removed ${menuIds.length} dislikes successfully');
      return true;
    } catch (e) {
      AppLogger.error('❌ [DislikeProvider] Error removing bulk dislikes', e);

      // Reload on error to restore correct state
      await loadDislikes(language: language);
      return false;
    }
  }

  /// Toggle bulk mode
  void toggleBulkMode() {
    _isBulkMode = !_isBulkMode;
    if (!_isBulkMode) {
      _selectedMenuIds.clear();
    }
    notifyListeners();
  }

  /// Toggle menu selection in bulk mode
  void toggleMenuSelection(int menuId) {
    if (_selectedMenuIds.contains(menuId)) {
      _selectedMenuIds.remove(menuId);
    } else {
      _selectedMenuIds.add(menuId);
    }
    notifyListeners();
  }

  /// Select all dislikes
  void selectAll() {
    _selectedMenuIds = _dislikes.map((d) => d.menuId).toSet();
    notifyListeners();
  }

  /// Deselect all dislikes
  void deselectAll() {
    _selectedMenuIds.clear();
    notifyListeners();
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Check if a menu is selected
  bool isMenuSelected(int menuId) {
    return _selectedMenuIds.contains(menuId);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
