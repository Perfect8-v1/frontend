// lib/services/auth_service.dart
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'api_config.dart';
import 'api_exception.dart';

/// Authentication service with client-side password hashing.
/// Passwords are hashed with BCrypt before leaving the device.
/// Singleton pattern ensures token is shared across all screens.
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

  String? get token => _token;
  String? get email => _email;
  int? get userId => _userId;
  List<String> get roles => _roles;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _roles.contains('ADMIN') || _roles.contains('ROLE_ADMIN');

  // ============================================================
  // Salt Management
  // ============================================================

  /// Fetch salt for login (existing user)
  Future<String> _getSaltForLogin(String email) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.adminUrl}/api/auth/salt/?email=$email'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['salt'] as String;
    } else if (response.statusCode == 404) {
      throw ApiException(
        statusCode: 404,
        message: 'Användaren finns inte',
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Fetch salt for registration (new user)
  Future<String> _getSaltForRegistration(String email) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.adminUrl}/api/auth/salt/?email=$email&forRegistration=true'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['salt'] as String;
    } else if (response.statusCode == 409) {
      throw ApiException(
        statusCode: 409,
        message: 'E-postadressen är redan registrerad',
      );
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Hash password with BCrypt salt
  String _hashPassword(String password, String salt) {
    return BCrypt.hashpw(password, salt);
  }

  // ============================================================
  // Authentication
  // ============================================================

  /// Admin login with client-side hashing
  Future<LoginResponse> adminLogin(String email, String password) async {
    // Step 1: Fetch salt for this user
    final salt = await _getSaltForLogin(email);

    // Step 2: Hash password client-side
    final passwordHash = _hashPassword(password, salt);

    // Step 3: Send hash to backend
    final response = await http.post(
      Uri.parse('${ApiConfig.adminUrl}/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'passwordHash': passwordHash,
      }),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      await _saveUserData(loginResponse.token, loginResponse.roles, loginResponse.email, loginResponse.userId);
      return loginResponse;
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Customer login with client-side hashing
  Future<LoginResponse> customerLogin(String email, String password) async {
    // Step 1: Fetch salt for this user
    final salt = await _getSaltForLogin(email);

    // Step 2: Hash password client-side
    final passwordHash = _hashPassword(password, salt);

    // Step 3: Send hash to backend
    final response = await http.post(
      Uri.parse('${ApiConfig.adminUrl}/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'passwordHash': passwordHash,
      }),
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      await _saveUserData(loginResponse.token, loginResponse.roles, loginResponse.email, loginResponse.userId);
      return loginResponse;
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Customer registration with client-side hashing
  Future<void> register(RegisterRequest request) async {
    // Step 1: Fetch new salt from backend
    final salt = await _getSaltForRegistration(request.email);

    // Step 2: Hash password client-side
    final passwordHash = _hashPassword(request.password, salt);

    // Step 3: Send hash + salt to backend
    final response = await http.post(
      Uri.parse('${ApiConfig.adminUrl}/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': request.email,
        'passwordHash': passwordHash,
        'passwordSalt': salt,
        'firstName': request.firstName,
        'lastName': request.lastName,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }
  }

  // ============================================================
  // Token Management
  // ============================================================

  /// Load saved token and roles from storage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _email = prefs.getString(_userKey);
    _userId = prefs.getInt(_userIdKey);
    final rolesJson = prefs.getString(_rolesKey);
    if (rolesJson != null) {
      _roles = List<String>.from(jsonDecode(rolesJson));
    }
  }

  /// Save token and user data to storage
  Future<void> _saveUserData(String token, List<String> roles, String? email, int? userId) async {
    _token = token;
    _roles = roles;
    _email = email;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_rolesKey, jsonEncode(roles));
    if (email != null) {
      await prefs.setString(_userKey, email);
    }
    if (userId != null) {
      await prefs.setInt(_userIdKey, userId);
    }
  }

  /// Logout and clear stored data
  Future<void> logout() async {
    _token = null;
    _roles = [];
    _email = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rolesKey);
    await prefs.remove(_userIdKey);
  }

  /// Get auth headers for API requests
  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };
}
