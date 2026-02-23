// lib/services/order_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import '../models/order_models.dart';
import '../models/cart_models.dart';

class OrderService {
  final AuthService _authService;

  OrderService(this._authService);

  /// POST /shop/api/orders
  /// Creates an order from cart data with shipping address.
  Future<Order> createOrder({
    required Cart cart,
    required String paymentMethod,
    String? firstName,
    String? lastName,
    String? street,
    String? postalCode,
    String? city,
    String? phone,
    String? country,
  }) async {
    final url = '${ApiConfig.shopUrl}/api/orders';

    // Build address fields - individual fields (Option A: backend reads these)
    final Map<String, dynamic> addressFields = {};
    if (street != null && street.isNotEmpty) {
      addressFields['shippingAddressLine1'] = street;
      addressFields['shippingCity'] = city ?? '';
      addressFields['shippingState'] = '';               // Sverige har inga states
      addressFields['shippingPostalCode'] = postalCode ?? '';
      addressFields['shippingCountry'] = country ?? 'Sverige';
    }

    final body = {
      // NOTE: customerId sätts av backend via JWT - skicka 0 eller utelämna
      // Kontrollera att din OrderController hämtar customerId från JWT, inte från body
      'customerId': 0,
      'orderItems': cart.items.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'productName': item.productName,
        'productSku': item.productSku ?? '',
      }).toList(),
      'subtotal': cart.totalAmount,
      'taxAmount': 0,
      'shippingCost': cart.estimatedShipping ?? 0,
      'totalAmount': cart.grandTotal,
      'currency': 'SEK',
      'paymentMethod': paymentMethod,
      'source': 'WEB',
      ...addressFields,
    };

    debugPrint('OrderService.createOrder() - URL: $url');
    debugPrint('OrderService.createOrder() - Body: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(url),
      headers: _authService.authHeaders,
      body: jsonEncode(body),
    );

    debugPrint('OrderService.createOrder() - Status: ${response.statusCode}');
    debugPrint('OrderService.createOrder() - Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Order.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// GET /shop/api/orders/my-orders
  Future<List<Order>> getMyOrders() async {
    final url = '${ApiConfig.shopUrl}/api/orders/my-orders';
    final response = await http.get(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      final content = data is List ? data : (data['content'] ?? data);
      if (content is List) {
        return content.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// GET /shop/api/orders/{id}
  Future<Order> getOrder(int orderId) async {
    final url = '${ApiConfig.shopUrl}/api/orders/$orderId';

    final response = await http.get(
      Uri.parse(url),
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

  /// POST /shop/api/orders/{id}/cancel
  Future<Order> cancelOrder(int orderId) async {
    final url = '${ApiConfig.shopUrl}/api/orders/$orderId/cancel';

    final response = await http.post(
      Uri.parse(url),
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
