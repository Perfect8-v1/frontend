// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/api_exception.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  final VoidCallback? onCartUpdated;

  const ProductListScreen({super.key, this.onCartUpdated});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _authService = AuthService();
  late final ProductService _productService;

  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(_authService);
    _loadProducts();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 0;
        _hasMore = true;
        _products = [];
      });
    }

    if (!_hasMore && !refresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _productService.getProducts(
        page: _currentPage,
        size: 20,
      );

      setState(() {
        _products.addAll(response.content);
        _hasMore = response.hasMore;
        _currentPage++;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte hämta produkter';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produkter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadProducts(refresh: true),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _loadProducts(refresh: true),
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Inga produkter hittades'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(refresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            _loadProducts();
            return const Center(child: CircularProgressIndicator());
          }
          return _ProductCard(
            product: _products[index],
            onCartUpdated: widget.onCartUpdated,
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onCartUpdated;

  const _ProductCard({required this.product, this.onCartUpdated});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                product: product,
                onCartUpdated: onCartUpdated,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: product.smallImageUrl != null
                    ? Image.network(
                        product.smallImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                      )
                    : const _PlaceholderImage(),
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Price
                    if (product.hasDiscount) ...[
                      Text(
                        '${product.price.toStringAsFixed(0)} kr',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${product.discountPrice!.toStringAsFixed(0)} kr',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ] else
                      Text(
                        '${product.price.toStringAsFixed(0)} kr',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    // Stock status
                    const SizedBox(height: 4),
                    Text(
                      product.availability,
                      style: TextStyle(
                        fontSize: 11,
                        color: product.inStock ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }
}
