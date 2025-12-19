// lib/services/api_exception.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? path;
  final DateTime timestamp;

  ApiException({
    required this.statusCode,
    required this.message,
    this.path,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ApiException.fromResponse(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return ApiException(
        statusCode: response.statusCode,
        message: json['message'] ?? 'Unknown error',
        path: json['path'],
        timestamp: json['timestamp'] != null 
            ? DateTime.parse(json['timestamp']) 
            : null,
      );
    } catch (_) {
      return ApiException(
        statusCode: response.statusCode,
        message: response.body.isNotEmpty ? response.body : 'Unknown error',
      );
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
  
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isServerError => statusCode >= 500;
}