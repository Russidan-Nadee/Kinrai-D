import 'package:flutter/material.dart';

class CategoriesNestedTabs extends StatelessWidget {
  const CategoriesNestedTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Food Types'),
              Tab(text: 'Categories'),
              Tab(text: 'Subcategories'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
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
    return const Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fastfood, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Food Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage main food categories (Thai, Japanese, etc.)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesContent() {
    return const Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage food categories within each type',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoriesContent() {
    return const Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.subdirectory_arrow_right, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Subcategories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage detailed subcategories for each category',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}