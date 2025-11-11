import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/cache/cache_service.dart';
import '../../../../../core/providers/language_provider.dart';
import '../../../../../core/utils/logger.dart';
import '../../widgets/add_menu_dialog.dart';
import '../../widgets/bulk_add_menu_dialog.dart';

class MenusTab extends StatefulWidget {
  const MenusTab({super.key});

  @override
  State<MenusTab> createState() => _MenusTabState();
}

class _MenusTabState extends State<MenusTab> {
  List<dynamic> menus = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 1;
  int totalMenus = 0;
  bool hasMore = true;

  // Bulk delete
  Set<int> selectedMenuIds = {};
  bool isSelectionMode = false;

  // Scroll controller for lazy loading
  final ScrollController _scrollController = ScrollController();

  // Track current language to detect changes
  String? _currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadMenus();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if language has changed
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final newLanguage = languageProvider.currentLanguageCode;

    if (_currentLanguage != null && _currentLanguage != newLanguage) {
      // Language changed - reload menus to refresh display
      _loadMenus(refresh: true);
    }
    _currentLanguage = newLanguage;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when 200px from bottom
      if (!isLoadingMore && hasMore && !isLoading) {
        _loadMoreMenus();
      }
    }
  }

  Future<void> _loadMenus({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        currentPage = 1;
        menus.clear();
        hasMore = true;
      }
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Cache-first strategy: Check cache first
      if (!refresh) {
        final cachedData = await CacheService.getAdminMenus(page: currentPage);
        if (cachedData != null) {
          // Load from cache instantly
          if (mounted) {
            setState(() {
              menus = cachedData['data'] ?? [];
              final pagination = cachedData['pagination'];
              if (pagination != null) {
                totalPages = pagination['total_pages'] ?? 1;
                totalMenus = pagination['total'] ?? 0;
                hasMore = pagination['has_next'] ?? false;
              }
              isLoading = false;
            });
          }

          // Background refresh: Update cache in background
          _refreshMenusInBackground(page: currentPage);
          return;
        }
      }

      // Cache miss or refresh: Fetch from API
      final response = await ApiClient().get('/menus?page=$currentPage&limit=20');

      final responseData = {
        'data': response.data['data'],
        'pagination': response.data['pagination'],
      };

      // Save to cache
      await CacheService.saveAdminMenus(responseData, page: currentPage);

      if (mounted) {
        setState(() {
          menus = response.data['data'] ?? [];
          final pagination = response.data['pagination'];
          if (pagination != null) {
            totalPages = pagination['total_pages'] ?? 1;
            totalMenus = pagination['total'] ?? 0;
            hasMore = pagination['has_next'] ?? false;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading menus', e);
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load menus: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  /// Background refresh: Update cache without blocking UI
  Future<void> _refreshMenusInBackground({required int page}) async {
    try {
      final response = await ApiClient().get('/menus?page=$page&limit=20');

      final responseData = {
        'data': response.data['data'],
        'pagination': response.data['pagination'],
      };

      await CacheService.saveAdminMenus(responseData, page: page);

      // Update UI if data changed
      if (mounted && page == currentPage) {
        final newMenus = response.data['data'] ?? [];
        if (newMenus.length != menus.length) {
          setState(() {
            menus = newMenus;
            final pagination = response.data['pagination'];
            if (pagination != null) {
              totalPages = pagination['total_pages'] ?? 1;
              totalMenus = pagination['total'] ?? 0;
              hasMore = pagination['has_next'] ?? false;
            }
          });
        }
      }
    } catch (e) {
      // Background refresh failed: ignore, cached data still valid
      AppLogger.error('Background refresh failed', e);
    }
  }

  Future<void> _loadMoreMenus() async {
    if (isLoadingMore || !hasMore) return;

    final nextPage = currentPage + 1;

    setState(() {
      isLoadingMore = true;
    });

    try {
      // Check cache for next page first
      final cachedData = await CacheService.getAdminMenus(page: nextPage);
      if (cachedData != null) {
        if (mounted) {
          setState(() {
            currentPage = nextPage;
            final newMenus = cachedData['data'] ?? [];
            menus.addAll(newMenus);

            final pagination = cachedData['pagination'];
            if (pagination != null) {
              totalPages = pagination['total_pages'] ?? 1;
              totalMenus = pagination['total'] ?? 0;
              hasMore = pagination['has_next'] ?? false;
            }
            isLoadingMore = false;
          });
        }

        // Background refresh for this page
        _refreshMenusInBackground(page: nextPage);
        return;
      }

      // Cache miss: Fetch from API
      final response = await ApiClient().get('/menus?page=$nextPage&limit=20');

      final responseData = {
        'data': response.data['data'],
        'pagination': response.data['pagination'],
      };

      // Save to cache
      await CacheService.saveAdminMenus(responseData, page: nextPage);

      if (mounted) {
        setState(() {
          currentPage = nextPage;
          final newMenus = response.data['data'] ?? [];
          menus.addAll(newMenus);

          final pagination = response.data['pagination'];
          if (pagination != null) {
            totalPages = pagination['total_pages'] ?? 1;
            totalMenus = pagination['total'] ?? 0;
            hasMore = pagination['has_next'] ?? false;
          }
          isLoadingMore = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading more menus', e);
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _showAddMenuDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const AddMenuDialog();
      },
    );

    if (result != null) {
      // Menu data returned from dialog, now create it
      await _createMenu(result);
    }
  }

  Future<void> _showBulkAddMenuDialog() async {
    final result = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (BuildContext context) {
        return const BulkAddMenuDialog();
      },
    );

    if (result != null && result.isNotEmpty) {
      // Multiple menu data returned from dialog, create them all
      await _createBulkMenus(result);
    }
  }

  Future<void> _createMenu(Map<String, dynamic> menuData) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating menu...')),
        );
      }

      await ApiClient().post('/menus', data: menuData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear cache since data changed
      await CacheService.clearAdminMenus();

      // Reload menus
      await _loadMenus(refresh: true);
    } catch (e) {
      AppLogger.error('Error creating menu', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create menu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createBulkMenus(List<Map<String, dynamic>> menusData) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Creating ${menusData.length} menus...')),
        );
      }

      // Use batch endpoint instead of sequential calls
      final response = await ApiClient().post('/menus/batch', data: {
        'menus': menusData,
      });

      final successCount = response.data['created'] ?? 0;
      final failCount = response.data['failed'] ?? 0;

      if (mounted) {
        if (failCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All $successCount menus created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Created $successCount menus, $failCount failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Clear cache since data changed
      await CacheService.clearAdminMenus();

      // Reload menus
      await _loadMenus(refresh: true);
    } catch (e) {
      AppLogger.error('Error creating bulk menus', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create menus: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(dynamic menu) async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final menuName = _getMenuDisplayName(menu, languageProvider.currentLanguageCode);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Menu'),
          content: Text('Are you sure you want to delete "$menuName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteMenu(menu['id']);
    }
  }

  Future<void> _deleteMenu(int menuId) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleting menu...')),
        );
      }

      await ApiClient().delete('/menus/$menuId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Clear cache since data changed
      await CacheService.clearAdminMenus();

      // Reload menus
      await _loadMenus(refresh: true);
    } catch (e) {
      AppLogger.error('Error deleting menu', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete menu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      if (!isSelectionMode) {
        selectedMenuIds.clear();
      }
    });
  }

  void _toggleMenuSelection(int menuId) {
    setState(() {
      if (selectedMenuIds.contains(menuId)) {
        selectedMenuIds.remove(menuId);
      } else {
        selectedMenuIds.add(menuId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      selectedMenuIds.clear();
      for (var menu in menus) {
        selectedMenuIds.add(menu['id']);
      }
    });
  }

  void _deselectAll() {
    setState(() {
      selectedMenuIds.clear();
    });
  }

  Future<void> _bulkDelete() async {
    if (selectedMenuIds.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Multiple Menus'),
          content: Text(
            'Are you sure you want to delete ${selectedMenuIds.length} menu(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteBulkMenus(selectedMenuIds.toList());
    }
  }

  Future<void> _deleteBulkMenus(List<int> menuIds) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleting ${menuIds.length} menus...')),
        );
      }

      // Use batch endpoint instead of sequential calls
      final response = await ApiClient().delete('/menus/batch', data: {
        'ids': menuIds,
      });

      final successCount = response.data['deleted'] ?? 0;
      final failCount = response.data['failed'] ?? 0;

      if (mounted) {
        if (failCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('All $successCount menus deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted $successCount menus, $failCount failed'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Clear selection and exit selection mode
      setState(() {
        selectedMenuIds.clear();
        isSelectionMode = false;
      });

      // Clear cache since data changed
      await CacheService.clearAdminMenus();

      // Reload menus
      await _loadMenus(refresh: true);
    } catch (e) {
      AppLogger.error('Error bulk deleting menus', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete menus: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getMenuDisplayName(dynamic menu, String language) {
    // Get subcategory name in selected language
    String menuName = 'Unknown Menu';
    final subcategory = menu['Subcategory'];
    if (subcategory != null && subcategory['Translations'] != null) {
      final translations = subcategory['Translations'] as List;
      final translation = translations.firstWhere(
        (t) => t['language'] == language,
        orElse: () => translations.firstWhere(
          (t) => t['language'] == 'th',
          orElse: () => translations.isNotEmpty ? translations[0] : null,
        ),
      );
      if (translation != null) {
        menuName = translation['name'] ?? 'Unknown Menu';
      }
    }

    // Get protein name in selected language if available
    final proteinType = menu['ProteinType'];
    if (proteinType != null && proteinType['Translations'] != null) {
      final translations = proteinType['Translations'] as List;
      final translation = translations.firstWhere(
        (t) => t['language'] == language,
        orElse: () => translations.firstWhere(
          (t) => t['language'] == 'th',
          orElse: () => translations.isNotEmpty ? translations[0] : null,
        ),
      );
      if (translation != null) {
        final proteinName = translation['name'];
        if (proteinName != null && proteinName.isNotEmpty) {
          return '$menuName$proteinName';
        }
      }
    }

    return menuName;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMenus,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => _loadMenus(refresh: true),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant_menu,
                        size: 40,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menu Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Total: $totalMenus menus',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menus Section
              const Text(
                'All Menus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Menu Grid
              if (menus.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getCrossAxisCount(context),
                    crossAxisSpacing: _getCrossAxisCount(context) == 2 ? 12 : 16,
                    mainAxisSpacing: _getCrossAxisCount(context) == 2 ? 12 : 16,
                    childAspectRatio: _getChildAspectRatio(context),
                  ),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    final menuId = menu['id'] as int;
                    return _buildMenuCard(menu, key: ValueKey(menuId));
                  },
                )
              else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No menus found',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              // Loading More Indicator
              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              // End of list indicator
              if (!hasMore && menus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'All ${menus.length} menus loaded',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

              // Space for FAB
              const SizedBox(height: 80),
            ],
          ),
        ),

        // Floating Action Buttons
        if (isSelectionMode)
          // Selection mode toolbar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: _selectAll,
                      icon: const Icon(Icons.select_all, size: 18),
                      label: const Text('Select All'),
                    ),
                    TextButton.icon(
                      onPressed: _deselectAll,
                      icon: const Icon(Icons.deselect, size: 18),
                      label: const Text('Deselect'),
                    ),
                    ElevatedButton.icon(
                      onPressed: selectedMenuIds.isEmpty ? null : _bulkDelete,
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: Text('Delete (${selectedMenuIds.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: _toggleSelectionMode,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          // Normal mode FABs
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Bulk Delete Mode Button
                FloatingActionButton(
                  heroTag: 'bulk_delete',
                  onPressed: _toggleSelectionMode,
                  backgroundColor: Colors.red,
                  tooltip: 'Bulk Delete Mode',
                  child: const Icon(Icons.checklist),
                ),
                const SizedBox(height: 12),
                // Bulk Add Button
                FloatingActionButton(
                  heroTag: 'bulk_add',
                  onPressed: _showBulkAddMenuDialog,
                  backgroundColor: Colors.orange.shade300,
                  foregroundColor: Colors.white,
                  tooltip: 'Bulk Add Menus',
                  child: const Icon(Icons.library_add),
                ),
                const SizedBox(height: 12),
                // Add Menu Button
                FloatingActionButton(
                  heroTag: 'add_menu',
                  onPressed: _showAddMenuDialog,
                  backgroundColor: Colors.orange,
                  tooltip: 'Add Menu',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(dynamic menu, {Key? key}) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final displayName = _getMenuDisplayName(menu, languageProvider.currentLanguageCode);
    final mealTime = menu['meal_time'] ?? 'UNKNOWN';
    final isActive = menu['is_active'] ?? false;
    final menuId = menu['id'] as int;
    final isSelected = selectedMenuIds.contains(menuId);

    // Handle contains - can be Map or List (legacy data)
    String? containsText;
    try {
      final containsData = menu['contains'];
      if (containsData is Map<String, dynamic>) {
        containsText = containsData['description']?.toString();
      } else if (containsData is List) {
        containsText = '${containsData.length} ingredients';
      }
    } catch (e) {
      containsText = null;
    }

    return Card(
      key: key,
      elevation: isSelected ? 4 : 2,
      color: isSelected ? Colors.orange.shade50 : null,
      child: InkWell(
        onTap: isSelectionMode ? () => _toggleMenuSelection(menuId) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Checkbox/Menu Name and Delete Button
              Row(
                children: [
                  // Checkbox in selection mode
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (bool? value) => _toggleMenuSelection(menuId),
                      activeColor: Colors.orange,
                    ),
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Delete button only when not in selection mode
                  if (!isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showDeleteConfirmation(menu),
                    ),
                ],
              ),
            const SizedBox(height: 8),

            // Meal Time
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getMealTimeColor(mealTime),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mealTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Status
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Contains info
            if (containsText != null && containsText.isNotEmpty)
              Text(
                containsText,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMealTimeColor(String mealTime) {
    switch (mealTime.toUpperCase()) {
      case 'BREAKFAST':
        return Colors.orange;
      case 'LUNCH':
        return Colors.blue;
      case 'DINNER':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
    if (width > 2000) {
      return 7; // Ultra wide monitor
    } else if (width > 1600) {
      return 6; // Large monitor
    } else if (width > 1024) {
      return 5; // Laptop
    } else if (width > 800) {
      return 3; // Tablet landscape
    } else if (width > 600) {
      return 2; // Tablet portrait
    } else {
      return 2; // Mobile (2 columns)
    }
  }

  double _getChildAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
    if (width > 800) {
      return 0.85; // Desktop/Tablet
    } else {
      return 0.75; // Mobile - slightly taller cards
    }
  }
}