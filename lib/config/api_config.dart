/// API Configuration for Perfect8 Backend
///
/// Updated to match Gateway Routing prefixes (application.yml)
class ApiConfig {
  // 🌐 SERVER (production på p8.rantila.com)
  static const String baseUrl = 'https://p8.rantila.com';

  // Gateway port (single entry point)
  static const int gatewayPort = 8080;

  // ==========================================
  // API Gateway URLs
  // ==========================================

  /// Gateway base URL
  static String get gatewayUrl => baseUrl;

  /// Admin & Auth (Gateway lyssnar direkt på /api/admin och /api/auth)
  /// INGET prefix här!
  static String get adminUrl => gatewayUrl;

  /// Shop Service (Gateway lyssnar på /shop/**)
  /// Vi lägger till /shop så att anrop blir: .../shop/api/cart
  static String get shopUrl => '$gatewayUrl/shop';

  /// Blog Service (Gateway lyssnar på /blog/**)
  static String get blogUrl => '$gatewayUrl/blog';

  /// Email Service (Gateway lyssnar på /email/**)
  static String get emailUrl => '$gatewayUrl/email';

  /// Image Service (Gateway lyssnar på /image/**)
  static String get imageUrl => '$gatewayUrl/image';

  // ==========================================
  // Health check endpoints
  // ==========================================

  // Dessa måste också ha prefixen för att hitta rätt via Gateway
  static String get adminHealth =>
      '$gatewayUrl/actuator/health'; // Admin är direkt under root
  static String get shopHealth => '$shopUrl/actuator/health';
  static String get blogHealth => '$blogUrl/actuator/health';
  static String get emailHealth => '$emailUrl/actuator/health';
  static String get imageHealth => '$imageUrl/actuator/health';
}
