import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/health_response.dart';

class ApiService {
  // Statisk variabel för att lagra token centralt i appen
  static String? _accessToken;

  // Setter för att spara token efter lyckad inloggning
  static void setToken(String token) => _accessToken = token;

  // Getter för headers (växellådan)
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  /// Centraliserad metod för alla autentiserade GET-anrop
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  /// Centraliserad metod för alla autentiserade POST-anrop
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    return await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );
  }

  // ==========================================
  // Hälsovårdskontroll-logik
  // ==========================================

  Future<HealthResponse?> checkHealth(String serviceUrl) async {
    try {
      print('🔍 Checking health: $serviceUrl');
      final response = await http.get(
        Uri.parse(serviceUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return HealthResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('❌ Error: $e');
      return null;
    }
  }

  Future<HealthResponse?> checkAdminHealth() async =>
      await checkHealth(ApiConfig.adminHealth);
  Future<HealthResponse?> checkBlogHealth() async =>
      await checkHealth(ApiConfig.blogHealth);
  Future<HealthResponse?> checkEmailHealth() async =>
      await checkHealth(ApiConfig.emailHealth);
  Future<HealthResponse?> checkImageHealth() async =>
      await checkHealth(ApiConfig.imageHealth);
  Future<HealthResponse?> checkShopHealth() async =>
      await checkHealth(ApiConfig.shopHealth);

  Future<Map<String, HealthResponse?>> checkAllServices() async {
    return {
      'Admin': await checkAdminHealth(),
      'Blog': await checkBlogHealth(),
      'Email': await checkEmailHealth(),
      'Image': await checkImageHealth(),
      'Shop': await checkShopHealth(),
    };
  }
}
