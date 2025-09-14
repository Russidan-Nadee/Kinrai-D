import 'package:flutter/material.dart';

class AdminTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;

  const AdminTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(
          icon: Icon(Icons.restaurant_menu),
          text: 'Menus',
        ),
        Tab(
          icon: Icon(Icons.category),
          text: 'Configuration',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}