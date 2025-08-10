import 'package:flutter/foundation.dart';
import '../../domain/entities/admin_menu_entity.dart';
import '../../domain/entities/food_management_entity.dart';
import '../../domain/usecases/menu_management_usecase.dart';
import '../../domain/usecases/food_management_usecase.dart';

enum AdminState { initial, loading, loaded, error }

class AdminProvider extends ChangeNotifier {
  final MenuManagementUseCase _menuManagementUseCase;
  final FoodManagementUseCase _foodManagementUseCase;

  AdminProvider({
    required MenuManagementUseCase menuManagementUseCase,
    required FoodManagementUseCase foodManagementUseCase,
  })  : _menuManagementUseCase = menuManagementUseCase,
        _foodManagementUseCase = foodManagementUseCase;

  // State
  AdminState _state = AdminState.initial;
  String? _errorMessage;

  // Menu Management
  List<AdminMenuEntity> _menus = [];
  AdminMenuEntity? _selectedMenu;
  int _currentMenuPage = 1;
  bool _hasMoreMenus = true;

  // Food Management
  List<FoodTypeEntity> _foodTypes = [];
  List<CategoryEntity> _categories = [];
  List<SubcategoryEntity> _subcategories = [];
  List<ProteinTypeEntity> _proteinTypes = [];

  // Getters
  AdminState get state => _state;
  String? get errorMessage => _errorMessage;
  List<AdminMenuEntity> get menus => _menus;
  AdminMenuEntity? get selectedMenu => _selectedMenu;
  List<FoodTypeEntity> get foodTypes => _foodTypes;
  List<CategoryEntity> get categories => _categories;
  List<SubcategoryEntity> get subcategories => _subcategories;
  List<ProteinTypeEntity> get proteinTypes => _proteinTypes;
  bool get hasMoreMenus => _hasMoreMenus;

  void _setState(AdminState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AdminState.error);
  }

  // Menu Management Methods
  Future<void> loadMenus({
    int page = 1,
    int limit = 10,
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
    bool refresh = false,
  }) async {
    if (refresh || page == 1) {
      _setState(AdminState.loading);
      _menus.clear();
      _currentMenuPage = 1;
    }

    try {
      final newMenus = await _menuManagementUseCase.getMenus(
        page: page,
        limit: limit,
        search: search,
        subcategoryId: subcategoryId,
        mealTime: mealTime,
        isActive: isActive,
      );

      if (page == 1) {
        _menus = newMenus;
      } else {
        _menus.addAll(newMenus);
      }

      _hasMoreMenus = newMenus.length == limit;
      _currentMenuPage = page;
      _setState(AdminState.loaded);
    } catch (e) {
      _setError('Failed to load menus: ${e.toString()}');
    }
  }

  Future<void> loadMoreMenus({
    String? search,
    int? subcategoryId,
    String? mealTime,
    bool? isActive,
  }) async {
    if (!_hasMoreMenus || _state == AdminState.loading) return;

    await loadMenus(
      page: _currentMenuPage + 1,
      search: search,
      subcategoryId: subcategoryId,
      mealTime: mealTime,
      isActive: isActive,
    );
  }

  Future<void> getMenuById(int id) async {
    _setState(AdminState.loading);
    try {
      _selectedMenu = await _menuManagementUseCase.getMenuById(id);
      _setState(AdminState.loaded);
    } catch (e) {
      _setError('Failed to load menu: ${e.toString()}');
    }
  }

  Future<bool> createMenu(AdminMenuEntity menu) async {
    _setState(AdminState.loading);
    try {
      final createdMenu = await _menuManagementUseCase.createMenu(menu);
      _menus.insert(0, createdMenu);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to create menu: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateMenu(int id, AdminMenuEntity menu) async {
    _setState(AdminState.loading);
    try {
      final updatedMenu = await _menuManagementUseCase.updateMenu(id, menu);
      final index = _menus.indexWhere((m) => m.id == id);
      if (index != -1) {
        _menus[index] = updatedMenu;
      }
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to update menu: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteMenu(int id) async {
    _setState(AdminState.loading);
    try {
      await _menuManagementUseCase.deleteMenu(id);
      _menus.removeWhere((m) => m.id == id);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to delete menu: ${e.toString()}');
      return false;
    }
  }

  Future<bool> toggleMenuStatus(int id, bool isActive) async {
    try {
      await _menuManagementUseCase.toggleMenuStatus(id, isActive);
      final index = _menus.indexWhere((m) => m.id == id);
      if (index != -1) {
        final menu = _menus[index];
        _menus[index] = AdminMenuEntity(
          id: menu.id,
          subcategoryId: menu.subcategoryId,
          proteinTypeId: menu.proteinTypeId,
          key: menu.key,
          imageUrl: menu.imageUrl,
          contains: menu.contains,
          mealTime: menu.mealTime,
          isActive: isActive,
          createdAt: menu.createdAt,
          updatedAt: menu.updatedAt,
          translations: menu.translations,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Failed to toggle menu status: ${e.toString()}');
      return false;
    }
  }

  // Food Management Methods
  Future<void> loadFoodTypes({int page = 1}) async {
    _setState(AdminState.loading);
    try {
      _foodTypes = await _foodManagementUseCase.getFoodTypes(page: page);
      _setState(AdminState.loaded);
    } catch (e) {
      _setError('Failed to load food types: ${e.toString()}');
    }
  }

  Future<bool> createFoodType(FoodTypeEntity foodType) async {
    _setState(AdminState.loading);
    try {
      final createdFoodType = await _foodManagementUseCase.createFoodType(foodType);
      _foodTypes.insert(0, createdFoodType);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to create food type: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateFoodType(int id, FoodTypeEntity foodType) async {
    _setState(AdminState.loading);
    try {
      final updatedFoodType = await _foodManagementUseCase.updateFoodType(id, foodType);
      final index = _foodTypes.indexWhere((f) => f.id == id);
      if (index != -1) {
        _foodTypes[index] = updatedFoodType;
      }
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to update food type: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteFoodType(int id) async {
    _setState(AdminState.loading);
    try {
      await _foodManagementUseCase.deleteFoodType(id);
      _foodTypes.removeWhere((f) => f.id == id);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to delete food type: ${e.toString()}');
      return false;
    }
  }

  // Categories
  Future<void> loadCategories({int page = 1}) async {
    _setState(AdminState.loading);
    try {
      _categories = await _foodManagementUseCase.getCategories(page: page);
      _setState(AdminState.loaded);
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    }
  }

  Future<bool> createCategory(CategoryEntity category) async {
    _setState(AdminState.loading);
    try {
      final createdCategory = await _foodManagementUseCase.createCategory(category);
      _categories.insert(0, createdCategory);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to create category: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateCategory(int id, CategoryEntity category) async {
    _setState(AdminState.loading);
    try {
      final updatedCategory = await _foodManagementUseCase.updateCategory(id, category);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to update category: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _setState(AdminState.loading);
    try {
      await _foodManagementUseCase.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to delete category: ${e.toString()}');
      return false;
    }
  }

  // Subcategories
  Future<void> loadSubcategories({int page = 1}) async {
    _setState(AdminState.loading);
    try {
      _subcategories = await _foodManagementUseCase.getSubcategories(page: page);
      _setState(AdminState.loaded);
    } catch (e) {
      _setError('Failed to load subcategories: ${e.toString()}');
    }
  }

  Future<bool> createSubcategory(SubcategoryEntity subcategory) async {
    _setState(AdminState.loading);
    try {
      final createdSubcategory = await _foodManagementUseCase.createSubcategory(subcategory);
      _subcategories.insert(0, createdSubcategory);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to create subcategory: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateSubcategory(int id, SubcategoryEntity subcategory) async {
    _setState(AdminState.loading);
    try {
      final updatedSubcategory = await _foodManagementUseCase.updateSubcategory(id, subcategory);
      final index = _subcategories.indexWhere((s) => s.id == id);
      if (index != -1) {
        _subcategories[index] = updatedSubcategory;
      }
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to update subcategory: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteSubcategory(int id) async {
    _setState(AdminState.loading);
    try {
      await _foodManagementUseCase.deleteSubcategory(id);
      _subcategories.removeWhere((s) => s.id == id);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to delete subcategory: ${e.toString()}');
      return false;
    }
  }

  // Protein Types
  Future<void> loadProteinTypes({int page = 1}) async {
    _setState(AdminState.loading);
    try {
      _proteinTypes = await _foodManagementUseCase.getProteinTypes(page: page);
      _setState(AdminState.loaded);
    } catch (e) {
      _setError('Failed to load protein types: ${e.toString()}');
    }
  }

  Future<bool> createProteinType(ProteinTypeEntity proteinType) async {
    _setState(AdminState.loading);
    try {
      final createdProteinType = await _foodManagementUseCase.createProteinType(proteinType);
      _proteinTypes.insert(0, createdProteinType);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to create protein type: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateProteinType(int id, ProteinTypeEntity proteinType) async {
    _setState(AdminState.loading);
    try {
      final updatedProteinType = await _foodManagementUseCase.updateProteinType(id, proteinType);
      final index = _proteinTypes.indexWhere((p) => p.id == id);
      if (index != -1) {
        _proteinTypes[index] = updatedProteinType;
      }
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to update protein type: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteProteinType(int id) async {
    _setState(AdminState.loading);
    try {
      await _foodManagementUseCase.deleteProteinType(id);
      _proteinTypes.removeWhere((p) => p.id == id);
      _setState(AdminState.loaded);
      return true;
    } catch (e) {
      _setError('Failed to delete protein type: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}