import 'package:flutter/material.dart';
import '../../../domain/entities/admin_menu_entity.dart';
import '../../widgets/menu_grid_item.dart';

class MenusTab extends StatelessWidget {
  final AdminMenuListEntity? adminInfo;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const MenusTab({
    super.key,
    this.adminInfo,
    required this.isLoading,
    this.errorMessage,
    required this.onRefresh,
  });

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
              onPressed: onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (adminInfo == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SingleChildScrollView(
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
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total: ${adminInfo!.pagination.total} menus',
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
            'Recent Menus',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Menu Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: _getCrossAxisCount(context) == 2 ? 12 : 16,
              mainAxisSpacing: _getCrossAxisCount(context) == 2 ? 12 : 16,
              childAspectRatio: _getChildAspectRatio(context),
            ),
            itemCount: adminInfo!.menus.length,
            itemBuilder: (context, index) {
              final menu = adminInfo!.menus[index];
              return MenuGridItem(menu: menu);
            },
          ),
          
          // Pagination Info
          if (adminInfo!.pagination.totalPages > 1)
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Showing ${adminInfo!.menus.length} of ${adminInfo!.pagination.total} menus (Page ${adminInfo!.pagination.page}/${adminInfo!.pagination.totalPages})',
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
    );
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