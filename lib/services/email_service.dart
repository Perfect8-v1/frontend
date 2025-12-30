// lib/services/email_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';
import 'api_exception.dart';
import '../models/email_models.dart';
import '../models/order_models.dart';

/// Service for sending emails via backend email-service
class EmailService {
  final AuthService _authService;

  EmailService(this._authService);

  /// Send order confirmation email
  Future<void> sendOrderConfirmation(
      Order order, String customerEmail, String customerName) async {
    final emailDto = _buildOrderEmailDTO(order, customerEmail, customerName);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.emailUrl}/api/email/order/confirmation'),
        headers: _authService.authHeaders,
        body: jsonEncode(emailDto.toJson()),
      );

      debugPrint('📧 Email response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Kunde inte skicka orderbekräftelse',
        );
      }
    } catch (e) {
      debugPrint('📧 Email error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        message: 'Kunde inte skicka email: $e',
      );
    }
  }

  /// Send order status update email
  Future<void> sendOrderStatusUpdate(
      Order order, String customerEmail, String customerName) async {
    final emailDto = _buildOrderEmailDTO(order, customerEmail, customerName);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.emailUrl}/api/email/order/status'),
        headers: _authService.authHeaders,
        body: jsonEncode(emailDto.toJson()),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Kunde inte skicka statusuppdatering',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        message: 'Kunde inte skicka email: $e',
      );
    }
  }

  /// Send shipping notification email
  Future<void> sendShippingNotification(
      Order order, String customerEmail, String customerName) async {
    final emailDto = _buildOrderEmailDTO(order, customerEmail, customerName);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.emailUrl}/api/email/order/shipped'),
        headers: _authService.authHeaders,
        body: jsonEncode(emailDto.toJson()),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Kunde inte skicka leveransbesked',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        message: 'Kunde inte skicka email: $e',
      );
    }
  }

  /// Send simple email
  Future<void> sendEmail(EmailRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.emailUrl}/api/email/send'),
        headers: _authService.authHeaders,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Kunde inte skicka email',
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        message: 'Kunde inte skicka email: $e',
      );
    }
  }

  /// Check if email service is running
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.emailUrl}/api/email/test'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Build OrderEmailDTO from Order model
  OrderEmailDTO _buildOrderEmailDTO(
      Order order, String customerEmail, String customerName) {
    return OrderEmailDTO(
      orderId: order.orderId,
      orderNumber: order.orderNumber,
      orderDate: order.createdDate,
      orderStatus: order.status.name.toUpperCase(),
      customerId: order.customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      items: order.items
          .map((item) => OrderItemDto(
                productId: item.productId,
                productName: item.productName,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                totalPrice: item.subtotal,
                variantInfo: item.variantName,
              ))
          .toList(),
      subtotal: order.subtotal,
      taxAmount: order.tax,
      shippingCost: order.shipping,
      totalAmount: order.total,
      currency: order.currency,
      shippingAddress: AddressDto(
        firstName: order.shippingAddress.firstName,
        lastName: order.shippingAddress.lastName,
        street: order.shippingAddress.street,
        city: order.shippingAddress.city,
        postalCode: order.shippingAddress.postalCode,
        country: order.shippingAddress.country,
        phone: order.shippingAddress.phone,
      ),
      billingAddress: AddressDto(
        firstName: order.billingAddress.firstName,
        lastName: order.billingAddress.lastName,
        street: order.billingAddress.street,
        city: order.billingAddress.city,
        postalCode: order.billingAddress.postalCode,
        country: order.billingAddress.country,
        phone: order.billingAddress.phone,
      ),
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      trackingUrl: order.trackingUrl,
    );
  }
}
