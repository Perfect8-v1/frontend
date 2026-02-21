// lib/services/email_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import 'api_exception.dart';
import '../models/email_models.dart';
import '../models/order_models.dart';

/// Service for sending emails via backend email-service (admin only)
class EmailService {
  final AuthService _authService;

  EmailService(this._authService);

  /// POST /email/send
  /// Skickar email via backend med template och variabler.
  Future<void> sendEmail(EmailRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.emailUrl}/send'),
        headers: _authService.authHeaders,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      debugPrint('Email error: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
        statusCode: 500,
        message: 'Kunde inte skicka email: $e',
      );
    }
  }

  /// GET /email/logs
  /// Hämtar email-historik (admin only).
  Future<List<EmailLog>> getEmailLogs() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.emailUrl}/logs'),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      if (data is List) {
        return data.map((item) => EmailLog.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Skickar orderbekräftelse via generisk send-endpoint med template.
  Future<void> sendOrderConfirmation(
      Order order, String customerEmail, String customerName) async {
    await sendEmail(EmailRequest(
      to: customerEmail,
      subject: 'Orderbekräftelse #${order.orderNumber}',
      template: 'order-confirmation',
      variables: _buildOrderVariables(order, customerName),
    ));
  }

  /// Skickar statusuppdatering för order.
  Future<void> sendOrderStatusUpdate(
      Order order, String customerEmail, String customerName) async {
    await sendEmail(EmailRequest(
      to: customerEmail,
      subject: 'Orderstatus uppdaterad #${order.orderNumber}',
      template: 'order-status',
      variables: _buildOrderVariables(order, customerName),
    ));
  }

  /// Skickar leveransbesked.
  Future<void> sendShippingNotification(
      Order order, String customerEmail, String customerName) async {
    await sendEmail(EmailRequest(
      to: customerEmail,
      subject: 'Din order har skickats #${order.orderNumber}',
      template: 'order-shipped',
      variables: _buildOrderVariables(order, customerName),
    ));
  }

  Map<String, dynamic> _buildOrderVariables(Order order, String customerName) {
    return {
      'orderId': order.orderId,
      'orderNumber': order.orderNumber,
      'customerName': customerName,
      'totalAmount': order.total,
      'currency': order.currency,
      'status': order.status.name.toUpperCase(),
      'paymentMethod': order.paymentMethod,
      'trackingUrl': order.trackingUrl,
    };
  }
}
