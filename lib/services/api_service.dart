import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  
  // Get JWT token from secure storage
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  
  // Save JWT token
  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
  
  // Delete JWT token
  Future<void> _deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }
  
  // Build headers with JWT
  Future<Map<String, String>> _buildHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // Generic GET request
  Future<dynamic> get(String url, {bool requiresAuth = true}) async {
    try {
      final headers = await _buildHeaders(includeAuth: requiresAuth);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  // Generic POST request
  Future<dynamic> post(String url, dynamic body, {bool requiresAuth = true}) async {
    try {
      final headers = await _buildHeaders(includeAuth: requiresAuth);
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }
  
  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ApiException('Unauthorized - Please login again', statusCode: 401);
    } else if (response.statusCode == 403) {
      throw ApiException('Forbidden - Insufficient permissions', statusCode: 403);
    } else if (response.statusCode == 404) {
      throw ApiException('Not found', statusCode: 404);
    } else {
      throw ApiException(
        'Server error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => message;
}