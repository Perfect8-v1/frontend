/// Health Check Response Model
/// 
/// Represents the JSON response from /actuator/health endpoint
class HealthResponse {
  final String status;
  final Map<String, dynamic>? components;
  
  HealthResponse({
    required this.status,
    this.components,
  });
  
  /// Convert JSON to Dart object
  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String,
      components: json['components'] as Map<String, dynamic>?,
    );
  }
  
  /// Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'components': components,
    };
  }
  
  /// Check if service is healthy
  bool get isHealthy => status.toLowerCase() == 'up';
  
  /// Get database status
  String? get databaseStatus {
    if (components != null && components!.containsKey('db')) {
      final db = components!['db'] as Map<String, dynamic>?;
      return db?['status'] as String?;
    }
    return null;
  }
  
  @override
  String toString() {
    return 'HealthResponse(status: $status, isHealthy: $isHealthy)';
  }
}
