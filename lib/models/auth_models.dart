// lib/models/auth_models.dart

/// Login response matching backend AuthResponse
class LoginResponse {
  final String token;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;
  final int? userId;
  final String? email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;

  LoginResponse({
    required this.token,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
    this.roles = const [],
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // User data kan ligga i ett 'user' objekt eller på toppnivån
    final user = json['user'] as Map<String, dynamic>? ?? json;

    return LoginResponse(
      token: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      tokenType: json['tokenType'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? 3600,
      userId: user['userId'],
      email: user['email'],
      firstName: user['firstName'],
      lastName: user['lastName'],
      roles: (user['roles'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }

  bool get isAdmin => roles.contains('ADMIN') || roles.contains('ROLE_ADMIN');
}

/// Customer login response (alias for LoginResponse)
class CustomerLoginResponse {
  final String token;
  final String? refreshToken;
  final String tokenType;
  final int? userId;
  final String? email;
  final String? firstName;
  final String? lastName;

  CustomerLoginResponse({
    required this.token,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
  });

  factory CustomerLoginResponse.fromJson(Map<String, dynamic> json) => CustomerLoginResponse(
    token: json['accessToken'] ?? json['token'],
    refreshToken: json['refreshToken'],
    tokenType: json['tokenType'] ?? 'Bearer',
    userId: json['userId'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
  );
}

/// Register request
class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    if (phone != null) 'phone': phone,
  };
}
