// lib/services/api_config.dart

class ApiConfig {
  // Production - all services via nginx Gateway on port 8080
  static const String baseUrl = 'http://p8.rantila.com:8080';

  // Development (uncomment for local testing with direct ports)
  // static const String baseUrl = 'http://127.0.0.1';
  // static String get adminUrl => '$baseUrl:8081';
  // static String get shopUrl => '$baseUrl:8085';
  // static String get imageUrl => '$baseUrl:8084';

  // All services use Gateway - no more /v1/ in paths
  static String get gatewayUrl => baseUrl;
  static String get adminUrl => gatewayUrl;  // /api/auth/* -> admin:8081
  static String get blogUrl => gatewayUrl;   // /api/blog/* -> blog:8082
  static String get postsUrl => gatewayUrl;  // /api/posts/* -> blog:8082
  static String get emailUrl => gatewayUrl;  // /api/email/* -> email:8083
  static String get imageUrl => gatewayUrl;  // /api/images/* -> image:8084
  static String get shopUrl => gatewayUrl;   // /api/products/* -> shop:8085

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
