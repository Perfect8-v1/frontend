/// API Configuration for Perfect8 Backend
///
/// Updated to use API Gateway instead of direct service connections
class ApiConfig {
  // 🏠 LOCAL (utveckling på din dator)
  // static const String baseUrl = 'http://localhost:8080';

  // 🌐 SERVER (production på p8.rantila.com)
  static const String baseUrl = 'http://p8.rantila.com:8080';

  // Gateway port (single entry point)
  static const int gatewayPort = 8080;

  // ==========================================
  // API Gateway URLs (all traffic goes through Gateway)
  // ==========================================

  /// Gateway base URL (all requests go through this)
  static String get gatewayUrl => baseUrl;

  /// All services use Gateway - no direct service URLs needed
  static String get adminUrl => gatewayUrl;
  static String get blogUrl => gatewayUrl;
  static String get emailUrl => gatewayUrl;
  static String get imageUrl => gatewayUrl;
  static String get shopUrl => gatewayUrl;

  // ==========================================
  // Health check endpoints (via Gateway)
  // ==========================================

  /// Note: Actuator endpoints still use service-specific paths
  /// Gateway routes /api/admin/actuator/** to admin-service
  static String get adminHealth => '$gatewayUrl/api/admin/actuator/health';
  static String get blogHealth => '$gatewayUrl/api/posts/actuator/health';
  static String get emailHealth => '$gatewayUrl/api/email/actuator/health';
  static String get imageHealth => '$gatewayUrl/api/images/actuator/health';
  static String get shopHealth => '$gatewayUrl/api/shop/actuator/health';

  // ==========================================
  // Notes for developers
  // ==========================================

  /// IMPORTANT:
  /// - All API calls now go through Gateway (port 8080)
  /// - No /v1 in paths! Use /api/products NOT /api/v1/products
  /// - Gateway handles routing to appropriate services
  /// - Example: GET http://p8.rantila.com:8080/api/products
  ///   → Gateway routes to shop-service:8085/api/products
}
