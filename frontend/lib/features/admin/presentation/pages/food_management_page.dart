import 'package:flutter/material.dart';

class FoodManagementPage extends StatefulWidget {
  const FoodManagementPage({super.key});

  @override
  State<FoodManagementPage> createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Food Types'),
              Tab(text: 'Categories'),
              Tab(text: 'Subcategories'),
              Tab(text: 'Protein Types'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodTypesList(),
          _buildCategoriesList(),
          _buildSubcategoriesList(),
          _buildProteinTypesList(),
        ],
      ),
    );
  }

  Widget _buildFoodTypesList() {
    return _buildEmptyState(
      icon: Icons.category,
      title: 'No food types available',
      subtitle: 'Add your first food type using the + button',
      onAdd: () => _showAddDialog('Food Type'),
    );
  }

  Widget _buildCategoriesList() {
    return _buildEmptyState(
      icon: Icons.list_alt,
      title: 'No categories available',
      subtitle: 'Add your first category using the + button',
      onAdd: () => _showAddDialog('Category'),
    );
  }

  Widget _buildSubcategoriesList() {
    return _buildEmptyState(
      icon: Icons.subdirectory_arrow_right,
      title: 'No subcategories available',
      subtitle: 'Add your first subcategory using the + button',
      onAdd: () => _showAddDialog('Subcategory'),
    );
  }

  Widget _buildProteinTypesList() {
    return _buildEmptyState(
      icon: Icons.set_meal,
      title: 'No protein types available',
      subtitle: 'Add your first protein type using the + button',
      onAdd: () => _showAddDialog('Protein Type'),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onAdd,
  }) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddDialog(String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New $type'),
          content: Text('$type creation form will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Add $type functionality coming soon!')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

}