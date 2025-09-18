import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../domain/entities/category_entities.dart';
import 'category_list_item.dart';
import 'add_food_type_dialog.dart';
import 'add_category_dialog.dart';
import 'add_subcategory_dialog.dart';
import '../../../../core/utils/logger.dart';

class CategoriesNestedTabs extends StatefulWidget {
  const CategoriesNestedTabs({super.key});

  @override
  State<CategoriesNestedTabs> createState() => _CategoriesNestedTabsState();
}

class _CategoriesNestedTabsState extends State<CategoriesNestedTabs> {
  late CategoryRemoteDataSource _dataSource;

  // Filter states
  String? _selectedFoodTypeId;
  String? _selectedCategoryId;
  List<FoodTypeEntity> _foodTypes = [];

  // Collapsible filter states
  bool _isCategoryFilterExpanded = false;
  bool _isSubcategoryFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    apiClient.initialize();
    _dataSource = CategoryRemoteDataSourceImpl(apiClient: apiClient);
    _loadFoodTypes();
  }

  Future<void> _loadFoodTypes() async {
    try {
      final models = await _dataSource.getFoodTypes();
      setState(() {
        _foodTypes = models.map((m) => m.toEntity()).toList();
      });
    } catch (e) {
      AppLogger.error('Error loading food types', e);
    }
  }

  void _showAddFoodTypeDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddFoodTypeDialog(),
    );

    if (result != null && mounted) {
      AppLogger.debug('Food Type data: $result');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Food type creation will be implemented soon'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showAddCategoryDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );

    if (result != null && mounted) {
      AppLogger.debug('Category data: $result');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Category creation will be implemented soon'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showAddSubcategoryDialog(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddSubcategoryDialog(),
    );

    if (result != null && mounted) {
      AppLogger.debug('Subcategory data: $result');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Subcategory creation will be implemented soon'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);

          return Column(
            children: [
              TabBar(
                controller: tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: [
                  Tab(text: 'Food Types'),
                  Tab(text: 'Categories'),
                  Tab(text: 'Subcategories'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    TabBarView(
                      controller: tabController,
                      children: [
                        _buildFoodTypesContent(),
                        _buildCategoriesContent(),
                        _buildSubcategoriesContent(),
                      ],
                    ),

                    // Floating Action Buttons
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: tabController,
                        builder: (context, child) {
                          return FloatingActionButton(
                            onPressed: () {
                              switch (tabController.index) {
                                case 0:
                                  _showAddFoodTypeDialog(context);
                                  break;
                                case 1:
                                  _showAddCategoryDialog(context);
                                  break;
                                case 2:
                                  _showAddSubcategoryDialog(context);
                                  break;
                              }
                            },
                            backgroundColor: Colors.orange,
                            child: const Icon(Icons.add),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFoodTypesContent() {
    return FutureBuilder<List<FoodTypeEntity>>(
      future: _dataSource.getFoodTypes().then(
        (models) => models.map((m) => m.toEntity()).toList(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final foodTypes = snapshot.data ?? [];

        if (foodTypes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fastfood, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Food Types found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: foodTypes.length,
          itemBuilder: (context, index) {
            return FoodTypeListItem(foodType: foodTypes[index]);
          },
        );
      },
    );
  }

  Widget _buildCategoriesContent() {
    return Column(
      children: [
        // Collapsible Filter Section
        Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Filter Header
              InkWell(
                onTap: () {
                  setState(() {
                    _isCategoryFilterExpanded = !_isCategoryFilterExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isCategoryFilterExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedFoodTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Food Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    hint: const Text('All Food Types'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Food Types'),
                      ),
                      ..._foodTypes.map((foodType) {
                        return DropdownMenuItem<String>(
                          value: foodType.id.toString(),
                          child: Text('${foodType.key} - ${foodType.name}'),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFoodTypeId = newValue;
                      });
                    },
                  ),
                ),
                crossFadeState: _isCategoryFilterExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),

        // Categories List
        Expanded(
          child: FutureBuilder<List<CategoryEntity>>(
            future: _selectedFoodTypeId == null
                ? _dataSource.getCategories().then(
                    (models) => models.map((m) => m.toEntity()).toList(),
                  )
                : _dataSource
                      .getCategoriesByFoodType(int.parse(_selectedFoodTypeId!))
                      .then(
                        (models) => models.map((m) => m.toEntity()).toList(),
                      ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('No Categories found'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryListItem(category: categories[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubcategoriesContent() {
    return Column(
      children: [
        // Collapsible Filter Section
        Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              // Filter Header
              InkWell(
                onTap: () {
                  setState(() {
                    _isSubcategoryFilterExpanded =
                        !_isSubcategoryFilterExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isSubcategoryFilterExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // Food Type Filter
                      DropdownButtonFormField<String>(
                        value: _selectedFoodTypeId,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Food Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        hint: const Text('All Food Types'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Food Types'),
                          ),
                          ..._foodTypes.map((foodType) {
                            return DropdownMenuItem<String>(
                              value: foodType.id.toString(),
                              child: Text('${foodType.key} - ${foodType.name}'),
                            );
                          }),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFoodTypeId = newValue;
                            _selectedCategoryId =
                                null; // Reset category when food type changes
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category Filter
                      FutureBuilder<List<CategoryEntity>>(
                        future: _selectedFoodTypeId == null
                            ? _dataSource.getCategories().then(
                                (models) =>
                                    models.map((m) => m.toEntity()).toList(),
                              )
                            : _dataSource
                                  .getCategoriesByFoodType(
                                    int.parse(_selectedFoodTypeId!),
                                  )
                                  .then(
                                    (models) => models
                                        .map((m) => m.toEntity())
                                        .toList(),
                                  ),
                        builder: (context, snapshot) {
                          final categories = snapshot.data ?? [];

                          return DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Filter by Category',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.subdirectory_arrow_right),
                            ),
                            hint: const Text('All Categories'),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('All Categories'),
                              ),
                              ...categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id.toString(),
                                  child: Text(
                                    '${category.key} - ${category.name}',
                                  ),
                                );
                              }),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategoryId = newValue;
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                crossFadeState: _isSubcategoryFilterExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),

        // Subcategories List
        Expanded(
          child: FutureBuilder<List<SubcategoryEntity>>(
            future: _getFilteredSubcategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final subcategories = snapshot.data ?? [];

              if (subcategories.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('No Subcategories found'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: subcategories.length,
                itemBuilder: (context, index) {
                  return SubcategoryListItem(subcategory: subcategories[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<SubcategoryEntity>> _getFilteredSubcategories() async {
    if (_selectedCategoryId != null) {
      // Filter by specific category
      final models = await _dataSource.getSubcategoriesByCategory(
        int.parse(_selectedCategoryId!),
      );
      return models.map((m) => m.toEntity()).toList();
    } else if (_selectedFoodTypeId != null) {
      // Get all subcategories for all categories of the selected food type
      final categories = await _dataSource.getCategoriesByFoodType(
        int.parse(_selectedFoodTypeId!),
      );
      final List<SubcategoryEntity> allSubcategories = [];

      for (final category in categories) {
        final subcategoriesModels = await _dataSource
            .getSubcategoriesByCategory(category.id);
        allSubcategories.addAll(subcategoriesModels.map((m) => m.toEntity()));
      }

      return allSubcategories;
    } else {
      // No filters, get all subcategories
      final models = await _dataSource.getSubcategories();
      return models.map((m) => m.toEntity()).toList();
    }
  }
}
