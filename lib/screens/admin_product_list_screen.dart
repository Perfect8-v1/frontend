// lib/screens/admin_product_list_screen.dart
import 'package:flutter/material.dart';
import '../models/product_models.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/api_exception.dart';
import 'admin_product_edit_screen.dart';

/// Admin screen for managing products with category tabs and sorting
class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late ProductService _productService;

  TabController? _tabController;
  List<Category> _categories = [];
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Sorting
  String _sortBy = 'name';
  String _sortDir = 'asc';
  final List<Map<String, String>> _sortOptions = [
    {'value': 'name_asc', 'label': 'Namn A-Ö'},
    {'value': 'name_desc', 'label': 'Namn Ö-A'},
    {'value': 'price_asc', 'label': 'Pris lågt → högt'},
    {'value': 'price_desc', 'label': 'Pris högt → lågt'},
    {'value': 'stockQuantity_asc', 'label': 'Lager lågt → högt'},
    {'value': 'stockQuantity_desc', 'label': 'Lager högt → lågt'},
  ];
  String _selectedSort = 'name_asc';

  // Current selected category
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(_authService);
    _loadData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load categories first
      final categories = await _productService.getCategories();

      setState(() {
        _categories = categories;
        _tabController = TabController(
          length: categories.length + 1, // +1 for "Alla"
          vsync: this,
        );
        _tabController!.addListener(_onTabChanged);
      });

      // Load products
      await _loadProducts();
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda data: $e';
        _isLoading = false;
      });
    }
  }

  void _onTabChanged() {
    if (!_tabController!.indexIsChanging) {
      final index = _tabController!.index;
      setState(() {
        _selectedCategoryId = index == 0 ? null : _categories[index - 1].categoryId;
      });
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final response = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        sortBy: _sortBy,
        sortDir: _sortDir,
        size: 100, // Load more products
      );

      setState(() {
        _products = response.content;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda produkter';
        _isLoading = false;
      });
    }
  }

  void _onSortChanged(String? value) {
    if (value == null) return;

    final parts = value.split('_');
    setState(() {
      _selectedSort = value;
      _sortBy = parts[0];
      _sortDir = parts[1];
    });
    _loadProducts();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ta bort produkt'),
        content: Text('Vill du verkligen ta bort "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _productService.deleteProduct(product.productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${product.name}" borttagen'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunde inte ta bort: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editProduct(Product? product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductEditScreen(product: product),
      ),
    ).then((_) => _loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hantera Produkter'),
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  const Tab(text: 'Alla'),
                  ..._categories.map((c) => Tab(text: c.name)),
                ],
              ),
        actions: [
          // Add new product button
          TextButton.icon(
            onPressed: () => _editProduct(null),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Ny', style: TextStyle(color: Colors.white)),
          ),
          // Sort dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<String>(
              value: _selectedSort,
              underline: const SizedBox(),
              icon: const Icon(Icons.sort, color: Colors.white),
              dropdownColor: Theme.of(context).colorScheme.surface,
              items: _sortOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: _onSortChanged,
            ),
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Uppdatera',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadData,
              child: const Text('Försök igen'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Inga produkter hittades',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.thumbnailImageUrl != null
                ? Image.network(
                    product.thumbnailImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Debug: Print error to console
                      debugPrint('Image load error: ${product.thumbnailImageUrl}');
                      debugPrint('Error: $error');
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              '${product.price.round()} kr',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            _buildStockBadge(product.stockQuantity),
            if (!product.active) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Inaktiv',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
            if (product.featured) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 16, color: Colors.amber),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editProduct(product),
              tooltip: 'Redigera',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteProduct(product),
              tooltip: 'Ta bort',
            ),
          ],
        ),
        onTap: () => _editProduct(product),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  Widget _buildStockBadge(int quantity) {
    Color color;
    String text;

    if (quantity <= 0) {
      color = Colors.red;
      text = 'Slut';
    } else if (quantity <= 10) {
      color = Colors.orange;
      text = '$quantity st';
    } else {
      color = Colors.green;
      text = '$quantity st';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
