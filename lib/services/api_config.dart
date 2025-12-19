// lib/services/api_config.dart

class ApiConfig {
  // Production
  static const String baseUrl = 'http://p8.rantila.com';
  
  // Development (använd 127.0.0.1 istället för localhost för IPv4)
  // static const String baseUrl = 'http://127.0.0.1';
  
  // Service ports
  static const int adminPort = 8081;
  static const int blogPort = 8082;
  static const int emailPort = 8083;
  static const int imagePort = 8084;
  static const int shopPort = 8085;
  
  // Full URLs
  static String get adminUrl => '$baseUrl:$adminPort';
  static String get blogUrl => '$baseUrl:$blogPort';
  static String get emailUrl => '$baseUrl:$emailPort';
  static String get imageUrl => '$baseUrl:$imagePort';
  static String get shopUrl => '$baseUrl:$shopPort';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}