class ApiConfig {
  // Base URL
  static const String baseUrl = 'http://p8.rantila.com';
  
  // Service Ports
  static const String adminPort = '8081';
  static const String blogPort = '8082';
  static const String emailPort = '8083';
  static const String imagePort = '8084';
  static const String shopPort = '8085';
  
  // Full URLs
  static String get adminUrl => '$baseUrl:$adminPort';
  static String get blogUrl => '$baseUrl:$blogPort';
  static String get emailUrl => '$baseUrl:$emailPort';
  static String get imageUrl => '$baseUrl:$imagePort';
  static String get shopUrl => '$baseUrl:$shopPort';
  
  // Timeouts
  static const Duration timeout = Duration(seconds: 30);
  
  // API Version
  static const String apiVersion = 'v1';
}