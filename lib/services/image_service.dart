// lib/services/image_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';

/// Service för bildhantering via image-service
class ImageService {
  final AuthService _authService;

  ImageService(this._authService);

  /// Hämta bild-URL för ett givet image ID
  /// GET /image/api/images/{id}
  static String getImageUrl(int imageId) =>
      '${ApiConfig.imageUrl}/api/images/$imageId';

  /// Hämta thumbnail-URL
  /// GET /image/api/images/{id}/thumbnail/{size}
  /// Sizes: SMALL, MEDIUM, LARGE, ORIGINAL
  static String getThumbnailUrl(int imageId, String size) =>
      '${ApiConfig.imageUrl}/api/images/$imageId/thumbnail/$size';

  /// Hämta bilder i en kategori
  /// GET /image/api/images/category/{category}
  Future<List<ImageInfo>> getImagesByCategory(String category) async {
    final url = '${ApiConfig.imageUrl}/api/images/category/$category';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      if (data is List) {
        return data.map((item) => ImageInfo.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Ladda upp bild (admin only)
  /// POST /image/api/images/upload
  Future<ImageInfo> uploadImage(File file, String altText, {String? category}) async {
    final url = '${ApiConfig.imageUrl}/api/images/upload';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_authService.authHeaders);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['altText'] = altText;
    if (category != null) request.fields['category'] = category;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return ImageInfo.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Ta bort bild (admin only)
  /// DELETE /image/api/images/{id}
  Future<void> deleteImage(int imageId) async {
    final url = '${ApiConfig.imageUrl}/api/images/$imageId';

    final response = await http.delete(
      Uri.parse(url),
      headers: _authService.authHeaders,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }
}

/// Image metadata
class ImageInfo {
  final int? imageId;
  final String? url;
  final String? thumbnailUrl;
  final String? altText;
  final String? category;
  final int? width;
  final int? height;
  final int? fileSize;
  final String? mimeType;
  final DateTime? createdDate;

  ImageInfo({
    this.imageId,
    this.url,
    this.thumbnailUrl,
    this.altText,
    this.category,
    this.width,
    this.height,
    this.fileSize,
    this.mimeType,
    this.createdDate,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) => ImageInfo(
        imageId: json['imageId'] ?? json['id'],
        url: json['url'],
        thumbnailUrl: json['thumbnailUrl'],
        altText: json['altText'],
        category: json['category'],
        width: json['width'],
        height: json['height'],
        fileSize: json['fileSize'],
        mimeType: json['mimeType'],
        createdDate: json['createdDate'] != null
            ? DateTime.parse(json['createdDate'])
            : null,
      );
}
