// lib/screens/categories_page.dart
import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';
import '../state/catalog_provider.dart';
import '../models/category.dart';
import '../screens/category_detail_screen.dart'; // Corrected import path

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cats = catalog.categories.where((c) => c.active).toList();
    if (cats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: cats.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final c = cats[i];
        return ListTile(
          leading: const Icon(Icons.label_outline),
          title: Text(c.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(category: c),
              ),
            );
          },
        );
      },
    );
  }
}