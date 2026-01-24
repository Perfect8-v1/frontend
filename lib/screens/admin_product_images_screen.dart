// lib/screens/admin_product_images_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../models/product_models.dart';

class AdminProductImagesScreen extends StatefulWidget {
  const AdminProductImagesScreen({super.key});

  @override
  State<AdminProductImagesScreen> createState() =>
      _AdminProductImagesScreenState();
}

class _AdminProductImagesScreenState extends State<AdminProductImagesScreen> {
  final _authService = AuthService();

  List<Product> _products = [];
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;
  String? _errorMessage;

  Product? _selectedProduct;
  Map<String, dynamic>? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load products and images in parallel
      await Future.wait([
        _loadProducts(),
        _loadImages(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/products?size=100'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['data']?['content'] ?? data['content'] ?? [];
      setState(() {
        _products =
            (content as List).map((json) => Product.fromJson(json)).toList();
      });
    }
  }

  Future<void> _loadImages() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.imageUrl}/api/images/category/products'),
      headers: {
        'Authorization': 'Bearer ${_authService.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _images = List<Map<String, dynamic>>.from(data is List ? data : []);
      });
    } else if (response.statusCode == 204) {
      // No images found
      setState(() {
        _images = [];
      });
    }
  }

  Future<void> _attachImage() async {
    if (_selectedProduct == null || _selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      // Get the thumbnail URL from the image
      final imageUrl = _selectedImage!['thumbnailUrl'] ??
          _selectedImage!['originalUrl'] ??
          '';

      // Build request body with all required fields including sku
      final requestBody = {
        'name': _selectedProduct!.name,
        'description': _selectedProduct!.description ?? '',
        'sku': _selectedProduct!.sku ?? 'SKU-${_selectedProduct!.productId}',
        'price': _selectedProduct!.price > 0 ? _selectedProduct!.price : 1.0,
        'discountPrice': _selectedProduct!.discountPrice,
        'stockQuantity': _selectedProduct!.stockQuantity,
        'imageUrl': imageUrl,
        'categoryId': _selectedProduct!.categoryId,
        'featured': _selectedProduct!.featured,
        'active': _selectedProduct!.active,
        'weight': _selectedProduct!.weight,
        'tags': _selectedProduct!.tags,
      };

      debugPrint('Sending request body: ${jsonEncode(requestBody)}');

      // Update the product with the new image URL
      final response = await http.put(
        Uri.parse(
            '${ApiConfig.shopUrl}/api/products/${_selectedProduct!.productId}'),
        headers: {
          'Authorization': 'Bearer ${_authService.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Reload products to show updated image
        await _loadProducts();

        setState(() {
          _selectedProduct = null;
          _selectedImage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bild kopplad till produkten'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Parse error response for better message
        String errorMsg = 'Status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? errorData['error'] ?? errorMsg;
        } catch (_) {}
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koppla bilder till produkter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(),
      floatingActionButton: _selectedProduct != null && _selectedImage != null
          ? FloatingActionButton.extended(
              onPressed: _attachImage,
              icon: const Icon(Icons.link),
              label: const Text('Koppla bild'),
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Selected items summary
        if (_selectedProduct != null || _selectedImage != null)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produkt: ${_selectedProduct?.name ?? "Välj produkt"}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bild: ${_selectedImage?['originalFilename'] ?? "Välj bild"}',
                      ),
                    ],
                  ),
                ),
                if (_selectedProduct != null || _selectedImage != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedProduct = null;
                        _selectedImage = null;
                      });
                    },
                    child: const Text('Rensa'),
                  ),
              ],
            ),
          ),

        // Products and Images lists
        Expanded(
          child: Row(
            children: [
              // Products list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: Text(
                        'Produkter (${_products.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final isSelected =
                              _selectedProduct?.productId == product.productId;

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: Colors.blue[100],
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: product.thumbnailImageUrl != null
                                  ? Image.network(
                                      product.thumbnailImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image_outlined),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child:
                                          const Icon(Icons.image_not_supported),
                                    ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              product.thumbnailImageUrl != null
                                  ? 'Har bild'
                                  : 'Ingen bild',
                              style: TextStyle(
                                color: product.thumbnailImageUrl != null
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedProduct = isSelected ? null : product;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const VerticalDivider(width: 1),

              // Images list
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: Text(
                        'Bilder (${_images.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: _images.isEmpty
                          ? const Center(
                              child: Text(
                                  'Inga bilder uppladdade.\nGå till Bilduppladdning först.'),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _images.length,
                              itemBuilder: (context, index) {
                                final image = _images[index];
                                final isSelected = _selectedImage == image;
                                final thumbnailUrl = image['thumbnailUrl'] ??
                                    image['originalUrl'] ??
                                    '';

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImage =
                                          isSelected ? null : image;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey,
                                        width: isSelected ? 3 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            thumbnailUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.broken_image),
                                          ),
                                          if (isSelected)
                                            Container(
                                              color:
                                                  Colors.blue.withOpacity(0.3),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
