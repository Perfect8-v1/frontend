// lib/services/cart_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cart_models.dart';
import 'api_config.dart';
import 'auth_service.dart';
import 'api_exception.dart';

/// Cart service for shop-service API calls
class CartService {
  final AuthService _authService;

  CartService(this._authService);

  /// Get current cart
  Future<Cart> getCart() async {
    final url = '${ApiConfig.shopUrl}/api/v1/cart/';
    final headers = _authService.authHeaders;
    debugPrint('🛒 CartService.getCart() - URL: $url');
    debugPrint('🛒 CartService.getCart() - Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    debugPrint('🛒 CartService.getCart() - Status: ${response.statusCode}');
    debugPrint('🛒 CartService.getCart() - Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Cart.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Add product to cart
  Future<Cart> addToCart(int productId, {int quantity = 1}) async {
    final url = '${ApiConfig.shopUrl}/api/v1/cart/add/';
    final body = jsonEncode({
      'productId': productId,
      'quantity': quantity,
    });
    debugPrint('🛒 CartService.addToCart() - URL: $url');
    debugPrint('🛒 CartService.addToCart() - Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: _authService.authHeaders,
      body: body,
    );

    debugPrint('🛒 CartService.addToCart() - Status: ${response.statusCode}');
    debugPrint('🛒 CartService.addToCart() - Response: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Cart.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Update item quantity
  Future<Cart> updateQuantity(int productId, int quantity) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/update/'),
      headers: _authService.authHeaders,
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Cart.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Remove item from cart
  Future<Cart> removeItem(int productId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/remove/$productId/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Cart.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/clear/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get cart item count
  Future<int> getCartItemCount() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/count/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return data as int;
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}
