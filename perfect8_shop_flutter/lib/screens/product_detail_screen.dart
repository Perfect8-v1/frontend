// =============================================================
// File: lib/screens/product_detail_screen.dart
// Purpose: Product info, images, variants, add to cart, stock.
// Endpoints: GET /api/products/{id}, PUT /api/products/{id}/stock
// =============================================================
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final int id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(aspectRatio: 1.3, child: Container(color: Theme.of(context).colorScheme.surfaceVariant)),
          const SizedBox(height: 16),
          Text('Product name', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Short description…'),
          const SizedBox(height: 12),
          Row(children: [
            FilledButton(onPressed: () {}, child: const Text('Add to cart')),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Buy now')),
          ]),
          const SizedBox(height: 24),
          const Text('Details'),
          const SizedBox(height: 8),
          const Text('• Spec A\n• Spec B\n• Spec C'),
        ],
      ),
    );
  }
}