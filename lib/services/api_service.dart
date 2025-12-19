import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/health_response.dart';

/// API Service for Perfect8 Backend
/// 
/// Handles all HTTP requests and responses
class ApiService {
  /// Check health of a specific service
  /// 
  /// Returns HealthResponse if successful, null if failed
  Future<HealthResponse?> checkHealth(String serviceUrl) async {
    try {
      print('🔍 Checking health: $serviceUrl');
      
      // Make HTTP GET request
      final response = await http.get(
        Uri.parse(serviceUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Request timeout after 5 seconds');
        },
      );
      
      print('📡 Response status: ${response.statusCode}');
      
      // Check if request was successful
      if (response.statusCode == 200) {
        // Parse JSON response
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('✅ Health check successful: ${jsonData['status']}');
        
        return HealthResponse.fromJson(jsonData);
      } else {
        print('❌ Health check failed: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error during health check: $e');
      return null;
    }
  }
  
  /// Check health of Admin Service
  Future<HealthResponse?> checkAdminHealth() async {
    return await checkHealth(ApiConfig.adminHealth);
  }
  
  /// Check health of Blog Service
  Future<HealthResponse?> checkBlogHealth() async {
    return await checkHealth(ApiConfig.blogHealth);
  }
  
  /// Check health of Email Service
  Future<HealthResponse?> checkEmailHealth() async {
    return await checkHealth(ApiConfig.emailHealth);
  }
  
  /// Check health of Image Service
  Future<HealthResponse?> checkImageHealth() async {
    return await checkHealth(ApiConfig.imageHealth);
  }
  
  /// Check health of Shop Service
  Future<HealthResponse?> checkShopHealth() async {
    return await checkHealth(ApiConfig.shopHealth);
  }
  
  /// Check health of ALL services
  Future<Map<String, HealthResponse?>> checkAllServices() async {
    print('🔍 Checking all services...');
    
    return {
      'Admin': await checkAdminHealth(),
      'Blog': await checkBlogHealth(),
      'Email': await checkEmailHealth(),
      'Image': await checkImageHealth(),
      'Shop': await checkShopHealth(),
    };
  }
}
