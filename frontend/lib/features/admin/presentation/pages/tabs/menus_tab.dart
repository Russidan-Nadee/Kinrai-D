import 'package:flutter/material.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/utils/logger.dart';

class MenusTab extends StatefulWidget {
  const MenusTab({super.key});

  @override
  State<MenusTab> createState() => _MenusTabState();
}

class _MenusTabState extends State<MenusTab> {
  List<dynamic> menus = [];
  bool isLoading = false;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 1;
  int totalMenus = 0;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiClient = ApiClient();
      apiClient.initialize();
      final response = await apiClient.get('/menus?page=$currentPage&limit=20');

      setState(() {
        menus = response.data['data'] ?? [];
        final pagination = response.data['pagination'];
        if (pagination != null) {
          totalPages = pagination['total_pages'] ?? 1;
          totalMenus = pagination['total'] ?? 0;
        }
        isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error loading menus', e);
      setState(() {
        errorMessage = 'Failed to load menus: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _getMenuDisplayName(dynamic menu) {
    // Get subcategory name in Thai
    String menuName = 'Unknown Menu';
    final subcategory = menu['Subcategory'];
    if (subcategory != null && subcategory['Translations'] != null) {
      final translations = subcategory['Translations'] as List;
      final thTranslation = translations.firstWhere(
        (t) => t['language'] == 'th',
        orElse: () => translations.isNotEmpty ? translations[0] : null,
      );
      if (thTranslation != null) {
        menuName = thTranslation['name'] ?? 'Unknown Menu';
      }
    }

    // Get protein name in Thai if available
    final proteinType = menu['ProteinType'];
    if (proteinType != null && proteinType['Translations'] != null) {
      final translations = proteinType['Translations'] as List;
      final thTranslation = translations.firstWhere(
        (t) => t['language'] == 'th',
        orElse: () => translations.isNotEmpty ? translations[0] : null,
      );
      if (thTranslation != null) {
        final proteinName = thTranslation['name'];
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
      body: RefreshIndicator(
        onRefresh: _loadMenus,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    return _buildMenuCard(menu);
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

              // Pagination Info
              if (totalPages > 1)
                Card(
                  margin: const EdgeInsets.only(top: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Showing ${menus.length} of $totalMenus menus (Page $currentPage/$totalPages)',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(dynamic menu) {
    final displayName = _getMenuDisplayName(menu);
    final mealTime = menu['meal_time'] ?? 'UNKNOWN';
    final isActive = menu['is_active'] ?? false;
    final contains = menu['contains'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menu Name
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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

            // Contains count
            if (contains.isNotEmpty)
              Text(
                '${contains.length} ingredients',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
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