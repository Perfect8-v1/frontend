// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_models.dart';
import '../models/paginated_response.dart';
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';

/// Product service for shop-service API calls
class ProductService {
  final AuthService _authService;

  ProductService(this._authService);

  /// Get products with pagination and filters
  Future<PaginatedResponse<Product>> getProducts({
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String sortDir = 'asc',
    int? categoryId,
    bool? featured,
    bool? inStock,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDir': sortDir,
      if (categoryId != null) 'categoryId': categoryId.toString(),
      if (featured != null) 'featured': featured.toString(),
      if (inStock != null) 'inStock': inStock.toString(),
    };

    final uri = Uri.parse('${ApiConfig.shopUrl}/api/products/')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Backend wraps response in ApiResponse: { success, message, data }
      final data = json['data'] ?? json;
      return PaginatedResponse.fromJson(
        data,
        (item) => Product.fromJson(item),
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get single product by ID
  Future<Product> getProduct(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/products/$productId/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Backend wraps response in ApiResponse: { success, message, data }
      final data = json['data'] ?? json;
      return Product.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Search products
  Future<PaginatedResponse<Product>> searchProducts(
    String query, {
    int page = 0,
    int size = 20,
  }) async {
    final uri = Uri.parse('${ApiConfig.shopUrl}/api/products/search/')
        .replace(queryParameters: {
          'query': query,
          'page': page.toString(),
          'size': size.toString(),
        });

    final response = await http.get(
      uri,
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return PaginatedResponse.fromJson(
        data,
        (item) => Product.fromJson(item),
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    final uri = Uri.parse('${ApiConfig.shopUrl}/api/products/featured/')
        .replace(queryParameters: {'limit': limit.toString()});

    final response = await http.get(
      uri,
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return (data as List<dynamic>)
          .map((item) => Product.fromJson(item))
          .toList();
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get products by category
  Future<PaginatedResponse<Product>> getProductsByCategory(
    int categoryId, {
    int page = 0,
    int size = 20,
  }) async {
    final uri = Uri.parse('${ApiConfig.shopUrl}/api/products/category/$categoryId/')
        .replace(queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        });

    final response = await http.get(
      uri,
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return PaginatedResponse.fromJson(
        data,
        (item) => Product.fromJson(item),
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get categories
  Future<List<Category>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/categories/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return (data as List<dynamic>)
          .map((item) => Category.fromJson(item))
          .toList();
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  // ========== ADMIN CRUD OPERATIONS ==========

  /// Create a new product (Admin only)
  Future<Product> createProduct(Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.shopUrl}/api/products/'),
      headers: {
        ..._authService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(productData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Product.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Update existing product (Admin only)
  Future<Product> updateProduct(int productId, Map<String, dynamic> productData) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.shopUrl}/api/products/$productId/'),
      headers: {
        ..._authService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(productData),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Product.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Delete product (Admin only) - soft delete
  Future<void> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.shopUrl}/api/products/$productId/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }

  /// Toggle product active status (Admin only)
  Future<Product> toggleProductStatus(int productId) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.shopUrl}/api/products/$productId/toggle-status/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Product.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}
