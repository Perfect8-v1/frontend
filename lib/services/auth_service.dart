import 'api_service.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';

class AuthService extends ApiService {
  // Login
  Future<LoginResponse> login(String email, String password) async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/login';
    
    final request = LoginRequest(email: email, password: password);
    final response = await post(url, request.toJson(), requiresAuth: false);
    
    final loginResponse = LoginResponse.fromJson(response);
    await _saveToken(loginResponse.token);
    
    return loginResponse;
  }
  
  // Register
  Future<LoginResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final url = '${ApiConfig.shopUrl}/api/v1/customers/register';
    
    final body = {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
    
    final response = await post(url, body, requiresAuth: false);
    
    final loginResponse = LoginResponse.fromJson(response);
    await _saveToken(loginResponse.token);
    
    return loginResponse;
  }
  
  // Logout
  Future<void> logout() async {
    await _deleteToken();
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }
}