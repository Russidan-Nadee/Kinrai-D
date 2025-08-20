import 'package:flutter/material.dart';
import '../../widgets/categories_nested_tabs.dart';

class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: CategoriesNestedTabs(),
    );
  }
}