// lib/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';

class PaymentService {
  final AuthService _authService;

  PaymentService(this._authService);

  /// POST /shop/api/payments/initiate
  /// Initierar betalning, returnerar t.ex. PayPal redirect URL.
  Future<PaymentInitResponse> initiatePayment(int orderId, String method) async {
    final url = '${ApiConfig.shopUrl}/api/payments/initiate';

    final response = await http.post(
      Uri.parse(url),
      headers: _authService.authHeaders,
      body: jsonEncode({
        'orderId': orderId,
        'method': method,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return PaymentInitResponse.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// POST /shop/api/payments/process
  /// Bekräftar betalning efter extern redirect (t.ex. PayPal).
  Future<PaymentResponse> processPayment(String paymentId, String payerId) async {
    final url = '${ApiConfig.shopUrl}/api/payments/process';

    final response = await http.post(
      Uri.parse(url),
      headers: _authService.authHeaders,
      body: jsonEncode({
        'paymentId': paymentId,
        'payerId': payerId,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return PaymentResponse.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// GET /shop/api/payments/{id}
  /// Hämtar betalningsstatus.
  Future<PaymentResponse> getPaymentStatus(int paymentId) async {
    final url = '${ApiConfig.shopUrl}/api/payments/$paymentId';

    final response = await http.get(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return PaymentResponse.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}

/// Svar vid initiering av betalning
class PaymentInitResponse {
  final String? redirectUrl;
  final String? paymentId;
  final String? status;

  PaymentInitResponse({this.redirectUrl, this.paymentId, this.status});

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) =>
      PaymentInitResponse(
        redirectUrl: json['redirectUrl'] ?? json['approvalUrl'],
        paymentId: json['paymentId'],
        status: json['status'],
      );
}

/// Svar vid betalningsbekräftelse / status
class PaymentResponse {
  final int? paymentId;
  final int? orderId;
  final String? status;
  final String? method;
  final double? amount;
  final String? currency;
  final DateTime? createdDate;

  PaymentResponse({
    this.paymentId,
    this.orderId,
    this.status,
    this.method,
    this.amount,
    this.currency,
    this.createdDate,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      PaymentResponse(
        paymentId: json['paymentId'],
        orderId: json['orderId'],
        status: json['status'],
        method: json['method'],
        amount: (json['amount'] as num?)?.toDouble(),
        currency: json['currency'],
        createdDate: json['createdDate'] != null
            ? DateTime.parse(json['createdDate'])
            : null,
      );
}
