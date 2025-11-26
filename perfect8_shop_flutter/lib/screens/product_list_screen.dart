// =============================================================
// File: lib/screens/product_list_screen.dart
// Purpose: Browsing products with pagination, sorting, filters.
// Endpoints: GET /api/products, /api/products/active, /api/products/search
// =============================================================
import 'package:flutter/material.dart';
import '../../app_router.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(spacing: 8, runSpacing: 8, children: [
              FilterChip(label: const Text('Active'), selected: true, onSelected: (_) {}),
              FilterChip(label: const Text('On Sale'), selected: false, onSelected: (_) {}),
              FilterChip(label: const Text('Price < \$50'), selected: false, onSelected: (_) {}),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .74,
            ),
            itemBuilder: (_, i) => _ProductCard(onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.productDetail, arguments: {'id': i});
            }),
            itemCount: 12,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ProductCard({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 1, child: Container(color: Theme.of(context).colorScheme.surfaceVariant)),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product name', maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text('\$ 49.00'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}