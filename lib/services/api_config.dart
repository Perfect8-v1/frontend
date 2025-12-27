// lib/services/api_config.dart

class ApiConfig {
  // Production - all services via nginx reverse proxy
  static const String baseUrl = 'https://p8.rantila.com';

  // Development (uncomment for local testing with direct ports)
  // static const String baseUrl = 'http://127.0.0.1';
  // static String get adminUrl => '$baseUrl:8081';
  // static String get shopUrl => '$baseUrl:8085';
  // static String get imageUrl => '$baseUrl:8084';

  // Production URLs - nginx proxies /api/v1/* to services
  // nginx strips /v1/ before forwarding to backend
  static String get adminUrl => baseUrl;  // /api/v1/auth/* -> admin:8081/api/auth/*
  static String get blogUrl => baseUrl;   // /api/v1/blog/* -> blog:8082/api/blog/*
  static String get postsUrl => baseUrl;  // /api/v1/posts/* -> blog:8082/api/posts/*
  static String get emailUrl => baseUrl;  // /api/v1/email/* -> email:8083/api/email/*
  static String get imageUrl => baseUrl;  // /api/v1/images/* -> image:8084/api/images/*
  static String get shopUrl => baseUrl;   // /api/v1/products/* -> shop:8085/api/products/*

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}