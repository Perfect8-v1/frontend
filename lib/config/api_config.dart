/// API Configuration for Perfect8 Backend
/// 
/// Change baseUrl to switch between local and production server
class ApiConfig {
  // 🏠 LOCAL (utveckling på din dator)
  // static const String baseUrl = 'http://localhost';
  
  // 🌐 SERVER (production på p8.rantila.com)
  static const String baseUrl = 'http://p8.rantila.com';
  
  // Service ports
  static const int adminPort = 8081;
  static const int blogPort = 8082;
  static const int emailPort = 8083;
  static const int imagePort = 8084;
  static const int shopPort = 8085;
  
  // Full URLs för varje service
  static String get adminUrl => '$baseUrl:$adminPort';
  static String get blogUrl => '$baseUrl:$blogPort';
  static String get emailUrl => '$baseUrl:$emailPort';
  static String get imageUrl => '$baseUrl:$imagePort';
  static String get shopUrl => '$baseUrl:$shopPort';
  
  // Health check endpoints
  static String get adminHealth => '$adminUrl/actuator/health';
  static String get blogHealth => '$blogUrl/actuator/health';
  static String get emailHealth => '$emailUrl/actuator/health';
  static String get imageHealth => '$imageUrl/actuator/health';
  static String get shopHealth => '$shopUrl/actuator/health';
}