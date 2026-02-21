//TODO add getCartItemCount

// lib/services/cart_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cart_models.dart';
import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import 'api_service.dart';

/// Cart service för shop-service API-anrop via Gateway.
/// Uppdaterad för att hantera JWT-autentisering korrekt via Gateway.
class CartService {
  final AuthService _authService;

  CartService(this._authService);

  /// Hämtar aktuell varukorg för den inloggade användaren.
  Future<Cart> getCart() async {
    // Använder shopUrl och tar bort avslutande snedstreck för att undvika routing-fel i Gateway.
    final url = '${ApiConfig.shopUrl}/api/cart';
    final headers = ApiService.headers;

    debugPrint('🛒 CartService.getCart() - URL: $url');
    debugPrint('🛒 CartService.getCart() - Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    debugPrint('🛒 CartService.getCart() - Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('🛒 CartService.getCart() - Response: ${response.body}');
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Cart.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Lägger till en produkt i varukorgen.
  Future<Cart> addToCart(int productId, {int quantity = 1}) async {
    final url = '${ApiConfig.shopUrl}/api/cart/add';
    final headers = ApiService.headers;

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
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

  /// Uppdaterar kvantiteten för en vara i varukorgen.
  Future<Cart> updateQuantity(int cartItemId, int quantity) async {
    final url = '${ApiConfig.shopUrl}/api/cart/update';
    final headers = ApiService.headers;

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        'cartItemId': cartItemId,
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

  /// Tar bort en vara från varukorgen.
  Future<Cart> removeItem(int itemId) async {
    final url = '${ApiConfig.shopUrl}/api/cart/remove/$itemId';
    final headers = ApiService.headers;

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Cart.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Tömer hela varukorgen.
  Future<void> clearCart() async {
    final url = '${ApiConfig.shopUrl}/api/cart/clear';
    final headers = ApiService.headers;

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }
  }

  /// Hämtar antal artiklar i korgen.
  /// Inaktiverad tills vidare för att fokusera på kritiska fel (401/500).
  Future<int> getCartItemCount() async {
    // Returnerar 0 utan nätverksanrop för att minska brus i loggarna.
    return 0;

    /* final url = '${ApiConfig.shopUrl}/api/cart/count';
    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return data as int;
    } else {
      throw ApiException.fromResponse(response);
    }
    */
  }
}
