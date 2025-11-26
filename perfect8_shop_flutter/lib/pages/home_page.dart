import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/catalog_provider.dart';
import '../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    if (catalog.loading && catalog.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (catalog.error != null) {
      return Center(child: Text('Fel: ${catalog.error}'));
    }
    final products = catalog.products;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .72,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductCard(product: products[i]),
      ),
    );
  }
}
