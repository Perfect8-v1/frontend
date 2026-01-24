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

  /// Skapa order från varukorg
  Future<Order> createOrderFromCart({
    required Cart cart,
    required String shippingAddress,
    String? billingAddress,
    String? paymentMethod,
    String? notes,
  }) async {
    final orderItems = cart.items
        .map((item) => {
              'productId': item.productId,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'productName': item.productName,
              'productSku': item.productSku,
            })
        .toList();

    final requestBody = {
      'customerId': cart.customerId,
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

    // FIX: shopUrl och ingen trailing slash
    final url = '${ApiConfig.shopUrl}/api/orders';
    final body = jsonEncode(requestBody);

    debugPrint('📦 OrderService.createOrder() - URL: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        ..._authService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint(
        '📦 OrderService.createOrder() - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      final order = Order.fromJson(data);

      // Fallback: Om backend inte returnerar artiklar, använd varukorgens artiklar
      if (order.items.isEmpty && cart.items.isNotEmpty) {
        return Order(
          orderId: order.orderId,
          orderNumber: order.orderNumber,
          customerId: order.customerId,
          status: order.status,
          items: cart.items
              .map((item) => OrderItem(
                    orderItemId: 0,
                    productId: item.productId,
                    productName: item.productName,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    subtotal: item.totalPrice,
                  ))
              .toList(),
          subtotal: order.subtotal,
          shipping: order.shipping,
          tax: order.tax,
          total: order.total,
          currency: order.currency,
          shippingAddress: order.shippingAddress,
          billingAddress: order.billingAddress,
          paymentMethod: order.paymentMethod,
          paymentStatus: order.paymentStatus,
          trackingNumber: order.trackingNumber,
          trackingUrl: order.trackingUrl,
          notes: order.notes,
          createdDate: order.createdDate,
          shippedDate: order.shippedDate,
          deliveredDate: order.deliveredDate,
        );
      }
      return order;
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Hämta inloggad kunds ordrar
  Future<List<Order>> getMyOrders({int page = 0, int size = 20}) async {
    final userId = _authService.userId;
    if (userId == null) {
      throw ApiException(statusCode: 401, message: 'Inte inloggad');
    }

    final url =
        '${ApiConfig.shopUrl}/api/orders/customer/$userId?page=$page&size=$size';
    final response = await http.get(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      final content = data['content'] ?? data;
      if (content is List) {
        return content.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Hämta specifik order via ID
  Future<Order> getOrder(int orderId) async {
    // FIX: shopUrl och ingen trailing slash
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

  /// Avbryt order
  Future<Order> cancelOrder(int orderId, {String? reason}) async {
    // FIX: shopUrl och ingen trailing slash innan query params
    final uri = Uri.parse('${ApiConfig.shopUrl}/api/orders/$orderId/cancel')
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
