// lib/services/order_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import '../models/order_models.dart';
import '../models/cart_models.dart';

class OrderService {
  final AuthService _authService;

  OrderService(this._authService);

  /// Create order from cart
  Future<Order> createOrderFromCart({
    required Cart cart,
    required String shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    String? notes,
  }) async {
    // Build order items from cart
    final orderItems = cart.items.map((item) => {
      'productId': item.productId,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'productName': item.productName,
      'productSku': item.productSku,
    }).toList();

    final requestBody = {
      'customerId': cart.customerId,  // Use cart's customerId, not authService
      'orderItems': orderItems,
      'subtotal': cart.totalAmount,
      'taxAmount': cart.estimatedTax ?? 0,
      'shippingCost': cart.estimatedShipping ?? 0,
      'discountAmount': cart.discountAmount ?? 0,
      'totalAmount': cart.grandTotal,
      'currency': 'SEK',
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress ?? shippingAddress,
      'paymentMethod': paymentMethod ?? 'INVOICE',
      'notes': notes,
      'source': 'MOBILE',
    };

    final url = '${ApiConfig.shopUrl}/api/v1/orders/';
    final body = jsonEncode(requestBody);
    debugPrint('📦 OrderService.createOrder() - URL: $url');
    debugPrint('📦 OrderService.createOrder() - Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        ..._authService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('📦 OrderService.createOrder() - Status: ${response.statusCode}');
    debugPrint('📦 OrderService.createOrder() - Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Order.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get customer's orders
  Future<List<Order>> getMyOrders({int page = 0, int size = 20}) async {
    final userId = _authService.userId;
    if (userId == null) {
      throw ApiException(statusCode: 401, message: 'Inte inloggad');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/orders/customer/$userId/?page=$page&size=$size'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;

      // Handle paginated response
      final content = data['content'] ?? data;
      if (content is List) {
        return content.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get order by ID
  Future<Order> getOrder(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.shopUrl}/api/v1/orders/$orderId/'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Order.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Cancel order
  Future<Order> cancelOrder(int orderId, {String? reason}) async {
    final uri = Uri.parse('${ApiConfig.shopUrl}/api/v1/orders/$orderId/cancel/')
        .replace(queryParameters: reason != null ? {'reason': reason} : null);

    final response = await http.post(
      uri,
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Order.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}
