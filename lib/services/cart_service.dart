// lib/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_models.dart';
import 'api_config.dart';
import 'auth_service.dart';
import 'api_exception.dart';

class CartService {
  final AuthService _authService;
  String? _guestSessionId;
  
  CartService(this._authService);
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authService.token != null) 
      'Authorization': 'Bearer ${_authService.token}'
    else if (_guestSessionId != null)
      'X-Session-Id': _guestSessionId!,
  };
  
  // Get cart
  Future<Cart> getCart() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart'),
      headers: _headers,
    );
    
    // Save guest session ID from response
    if (!_authService.isLoggedIn && response.headers.containsKey('x-session-id')) {
      _guestSessionId = response.headers['x-session-id'];
    }
    
    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException.fromResponse(response);
    }
  }
  
  // Add to cart
  Future<Cart> addToCart(AddToCartRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/add'),
      headers: _headers,
      body: jsonEncode(request.toJson()),
    );
    
    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException.fromResponse(response);
    }
  }
  
  // Update quantity
  Future<Cart> updateQuantity(int cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/update'),
      headers: _headers,
      body: jsonEncode({
        'cartItemId': cartItemId,
        'quantity': quantity,
      }),
    );
    
    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException.fromResponse(response);
    }
  }
  
  // Remove item
  Future<Cart> removeItem(int cartItemId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/remove/$cartItemId'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException.fromResponse(response);
    }
  }
  
  // Clear cart
  Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/cart/clear'),
      headers: _headers,
    );
    
    if (response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }
}