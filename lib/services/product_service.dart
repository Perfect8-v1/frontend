import 'api_service.dart';
import '../config/api_config.dart';
import '../models/product.dart';

class ProductService extends ApiService {
  // Get all products
  Future<List<Product>> getAllProducts() async {
    final url = '${ApiConfig.shopUrl}/api/v1/products';
    final response = await get(url, requiresAuth: false);
    
    return (response as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
  
  // Get single product
  Future<Product> getProduct(int productId) async {
    final url = '${ApiConfig.shopUrl}/api/v1/products/$productId';
    final response = await get(url, requiresAuth: false);
    
    return Product.fromJson(response);
  }
  
  // Search products
  Future<List<Product>> searchProducts(String query) async {
    final url = '${ApiConfig.shopUrl}/api/v1/products/search?q=$query';
    final response = await get(url, requiresAuth: false);
    
    return (response as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
  
  // Get products by category
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final url = '${ApiConfig.shopUrl}/api/v1/products/category/$categoryId';
    final response = await get(url, requiresAuth: false);
    
    return (response as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }
}