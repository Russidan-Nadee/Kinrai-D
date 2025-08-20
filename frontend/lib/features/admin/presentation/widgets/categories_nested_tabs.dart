import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/category_remote_data_source.dart';
import '../../domain/entities/category_entities.dart';
import 'category_list_item.dart';

class CategoriesNestedTabs extends StatefulWidget {
  const CategoriesNestedTabs({super.key});

  @override
  State<CategoriesNestedTabs> createState() => _CategoriesNestedTabsState();
}

class _CategoriesNestedTabsState extends State<CategoriesNestedTabs> {
  late CategoryRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    apiClient.initialize();
    _dataSource = CategoryRemoteDataSourceImpl(apiClient: apiClient);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
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
          SizedBox(
            height: 500,
            child: TabBarView(
              children: [
                _buildFoodTypesContent(),
                _buildCategoriesContent(),
                _buildSubcategoriesContent(),
              ],
            ),
          ),
        ],
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
    return FutureBuilder<List<CategoryEntity>>(
      future: _dataSource.getCategories().then(
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
                Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Categories found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryListItem(category: categories[index]);
          },
        );
      },
    );
  }

  Widget _buildSubcategoriesContent() {
    return FutureBuilder<List<SubcategoryEntity>>(
      future: _dataSource.getSubcategories().then(
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

        final subcategories = snapshot.data ?? [];

        if (subcategories.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.subdirectory_arrow_right, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No Subcategories found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: subcategories.length,
          itemBuilder: (context, index) {
            return SubcategoryListItem(subcategory: subcategories[index]);
          },
        );
      },
    );
  }
}