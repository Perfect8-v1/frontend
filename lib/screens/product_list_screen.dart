// lib/screens/product_list_screen.dart
import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/product_service.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
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
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = true;
  bool _isCategoriesLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(_authService);
    _loadCategories();
    _loadProducts();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });

    try {
      final categories = await _productService.getCategories();
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
    } on ApiException catch (e) {
      debugPrint('Kunde inte hämta kategorier: ${e.message}');
      setState(() {
        _isCategoriesLoading = false;
      });
    } catch (e) {
      debugPrint('Kunde inte hämta kategorier: $e');
      setState(() {
        _isCategoriesLoading = false;
      });
    }
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
        categoryId: _selectedCategory?.categoryId,
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

  void _onCategorySelected(Category? category) {
    if (_selectedCategory?.categoryId == category?.categoryId) return;

    setState(() {
      _selectedCategory = category;
    });
    _loadProducts(refresh: true);
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
      body: Column(
        children: [
          // Category selector
          _CategorySelector(
            categories: _categories,
            selectedCategory: _selectedCategory,
            isLoading: _isCategoriesLoading,
            onCategorySelected: _onCategorySelected,
          ),

          // Product grid
          Expanded(child: _buildBody()),
        ],
      ),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _selectedCategory != null
                  ? 'Inga produkter i ${_selectedCategory!.name}'
                  : 'Inga produkter hittades',
            ),
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

// ============================================================
// Category Selector Widget
// ============================================================
class _CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final bool isLoading;
  final ValueChanged<Category?> onCategorySelected;

  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.isLoading,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length + 1, // +1 för "Alla"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Alla" chip
            final isSelected = selectedCategory == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('Alla'),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(null),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                checkmarkColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected =
              selectedCategory?.categoryId == category.categoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// Product Card Widget
// ============================================================
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
                        color: product.inStock
                            ? Colors.green[700]
                            : Colors.red[700],
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

// ============================================================
// Placeholder Image Widget
// ============================================================
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
