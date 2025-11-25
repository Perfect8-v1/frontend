class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({required this.email, required this.password});
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String token;
  final String email;
  final String firstName;
  final String lastName;
  
  LoginResponse({
    required this.token,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['token'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
  );
}