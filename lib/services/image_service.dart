import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../config/api_config.dart';

class ImageService extends ApiService {
  // Upload single image
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final url = '${ApiConfig.imageUrl}/api/images/upload';
    final token = await _getToken();
    
    // Create multipart request
    final request = http.MultipartRequest('POST', Uri.parse(url));
    
    // Add headers
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add file
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    
    // Send request
    final streamedResponse = await request.send().timeout(ApiConfig.timeout);
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw ApiException('Failed to upload image: ${response.statusCode}');
    }
  }
  
  // Get image URL
  String getImageUrl(int imageId, {String size = 'medium'}) {
    return '${ApiConfig.imageUrl}/api/images/$imageId/thumbnail/$size';
  }
}