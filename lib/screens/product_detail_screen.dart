// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product_models.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.grey[200],
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Brand
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Price section
                  _buildPriceSection(context),
                  const SizedBox(height: 16),

                  // Availability
                  _buildAvailability(),
                  const SizedBox(height: 24),

                  // Description
                  if (product.description != null) ...[
                    Text(
                      'Beskrivning',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Product details
                  _buildDetails(context),
                  const SizedBox(height: 24),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: product.inStock ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kundvagn kommer snart!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } : null,
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(product.inStock ? 'Lägg i kundvagn' : 'Slut i lager'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 80,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (product.hasDiscount) ...[
          Text(
            '${product.discountPrice!.toStringAsFixed(0)} kr',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${product.price.toStringAsFixed(0)} kr',
            style: TextStyle(
              fontSize: 18,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-${product.discountPercentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] else
          Text(
            '${product.price.toStringAsFixed(0)} kr',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  Widget _buildAvailability() {
    final color = product.inStock ? Colors.green[700] : Colors.red[700];
    final bgColor = product.inStock ? Colors.green[50] : Colors.red[50];
    final icon = product.inStock ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            product.availability,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (product.inStock && product.stockQuantity <= 10) ...[
            const SizedBox(width: 8),
            Text(
              '(${product.stockQuantity} kvar)',
              style: TextStyle(color: color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final details = <MapEntry<String, String>>[];

    if (product.sku != null) {
      details.add(MapEntry('Artikelnummer', product.sku!));
    }
    if (product.category != null) {
      details.add(MapEntry('Kategori', product.category!));
    }
    if (product.weight != null) {
      details.add(MapEntry('Vikt', '${product.weight} kg'));
    }
    if (product.dimensions != null) {
      details.add(MapEntry('Mått', product.dimensions!));
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaljer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...details.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  entry.key,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Expanded(child: Text(entry.value)),
            ],
          ),
        )),
      ],
    );
  }
}
