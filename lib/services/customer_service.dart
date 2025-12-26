// lib/services/customer_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import '../models/customer_models.dart';

class CustomerService {
  final AuthService _authService;

  CustomerService(this._authService);

  /// Get current customer profile
  Future<Customer> getProfile() async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/profile/';
    debugPrint('👤 CustomerService.getProfile() - URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    debugPrint('👤 CustomerService.getProfile() - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Customer.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get customer addresses
  Future<List<Address>> getAddresses() async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/addresses/';
    debugPrint('📍 CustomerService.getAddresses() - URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    debugPrint('📍 CustomerService.getAddresses() - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      if (data is List) {
        return data.map((a) => Address.fromJson(a)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Add new address
  Future<Address> addAddress(Map<String, dynamic> addressData) async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/addresses/';
    debugPrint('📍 CustomerService.addAddress() - URL: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        ..._authService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(addressData),
    );

    debugPrint('📍 CustomerService.addAddress() - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Address.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Delete address
  Future<void> deleteAddress(int addressId) async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/addresses/$addressId/';
    debugPrint('📍 CustomerService.deleteAddress() - URL: $url');

    final response = await http.delete(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    debugPrint('📍 CustomerService.deleteAddress() - Status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }

  /// Update customer profile
  Future<Customer> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/profile/';
    debugPrint('👤 CustomerService.updateProfile() - URL: $url');

    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;

    final response = await http.put(
      Uri.parse(url),
      headers: {
        ..._authService.authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('👤 CustomerService.updateProfile() - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return Customer.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}
