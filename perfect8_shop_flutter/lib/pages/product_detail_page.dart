import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../state/cart_provider.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16/9,
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, fit: BoxFit.cover)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${product.price.toStringAsFixed(2)} \$',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(product.description),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<CartProvider>().add(product),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Lägg i kundvagn'),
          ),
        ],
      ),
    );
  }
}
