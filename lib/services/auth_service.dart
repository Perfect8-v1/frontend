// lib/services/auth_service.dart
// SOP Version - Industristandard (plaintext över HTTPS)
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../config/api_config.dart';
import 'api_exception.dart';
import 'api_service.dart';

/// Authentication service - SOP (Standard Operating Procedure)
/// Skickar plaintext password över HTTPS, backend hashar med BCrypt.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _rolesKey = 'user_roles';
  static const String _userIdKey = 'user_id';

  String? _token;
  List<String> _roles = [];
  String? _email;
  int? _userId;

  // Getters för UI och andra tjänster
  String? get token => _token;
  String? get email => _email;
  int? get userId => _userId;
  List<String> get roles => _roles;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _roles.contains('ADMIN') || _roles.contains('ROLE_ADMIN');

  // ============================================================
  // Authentication
  // ============================================================

  Future<LoginResponse> adminLogin(String email, String password) async {
    try {
      debugPrint('🔑 STARTAR INLOGGNING FÖR: $email');

      // SOP: Skicka direkt till gateway
      final url = '${ApiConfig.gatewayUrl}/api/auth/login';
      debugPrint('📡 LOGIN REQUEST: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password, // Plaintext - backend hashar
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
          '📥 LOGIN RESPONSE (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        await _saveUserData(
          loginResponse.token,
          loginResponse.roles,
          loginResponse.email,
          loginResponse.userId,
        );
        return loginResponse;
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      debugPrint('🚨 LOGIN ERROR: $e');
      rethrow;
    }
  }

  Future<LoginResponse> customerLogin(String email, String password) async {
    return await adminLogin(email, password);
  }

  Future<void> register(RegisterRequest request) async {
    try {
      debugPrint('📝 STARTAR REGISTRERING FÖR: ${request.email}');

      final url = '${ApiConfig.gatewayUrl}/api/auth/register';
      debugPrint('📡 REGISTER REQUEST: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': request.email,
              'password': request.password, // Plaintext - backend hashar
              'firstName': request.firstName,
              'lastName': request.lastName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
          '📥 REGISTER RESPONSE (${response.statusCode}): ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      debugPrint('🚨 REGISTER ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // Token & Persistence Management
  // ============================================================

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _email = prefs.getString(_userKey);
    _userId = prefs.getInt(_userIdKey);

    if (_token != null) {
      ApiService.setToken(_token!);
    }

    final rolesJson = prefs.getString(_rolesKey);
    if (rolesJson != null) {
      _roles = List<String>.from(jsonDecode(rolesJson));
    }
  }

  Future<void> _saveUserData(
      String token, List<String> roles, String? email, int? userId) async {
    _token = token;
    _roles = roles;
    _email = email;
    _userId = userId;

    ApiService.setToken(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_rolesKey, jsonEncode(roles));
    if (email != null) await prefs.setString(_userKey, email);
    if (userId != null) await prefs.setInt(_userIdKey, userId);
  }

  Future<void> logout() async {
    _token = null;
    _roles = [];
    _email = null;
    _userId = null;
    ApiService.setToken('');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rolesKey);
    await prefs.remove(_userIdKey);
  }

  // MAGNUM OPUS: Denna metod krävs av dina existerande tjänster
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}
