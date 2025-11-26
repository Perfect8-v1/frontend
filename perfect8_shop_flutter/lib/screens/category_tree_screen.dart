import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/catalog_provider.dart';
import './category_detail_screen.dart';

class CategoryTreeScreen extends StatelessWidget {
  const CategoryTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalogProvider, child) {
        if (catalogProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (catalogProvider.error != null) {
          return Center(child: Text('Error: ${catalogProvider.error}'));
        }

        final categories = catalogProvider.categories;

        if (categories.isEmpty) {
          return const Center(child: Text('No categories found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryCard(category: category);
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(category: category),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(category.name),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}