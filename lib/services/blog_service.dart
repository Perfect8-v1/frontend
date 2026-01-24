// lib/services/blog_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'auth_service.dart';
import '../models/blog_models.dart';

/// Service för blogg-operationer via Gateway
class BlogService {
  final AuthService _authService;

  BlogService(this._authService);

  /// Hämta publicerade inlägg (Publikt)
  Future<List<BlogPost>> getPublishedPosts(
      {int page = 0, int size = 10}) async {
    // FIX: Använder ApiConfig.blogUrl och tar bort trailing slash innan query params
    final url = '${ApiConfig.blogUrl}/api/posts?page=$page&size=$size';

    debugPrint('🌐 BlogService.getPublishedPosts() - URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.headers,
    );

    debugPrint(
        '🌐 BlogService.getPublishedPosts() - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;

      final content = data['content'] ?? data;
      if (content is List) {
        return content.map((item) => BlogPost.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Hämta ett specifikt inlägg via slug (Publikt)
  Future<BlogPost> getPostBySlug(String slug) async {
    // FIX: Ingen trailing slash efter slug
    final url = '${ApiConfig.blogUrl}/api/posts/$slug';

    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.headers,
    );

    debugPrint(
        '🌐 BlogService.getPostBySlug($slug) - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return BlogPost.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Skapa nytt inlägg (Endast Admin)
  Future<BlogPost> createPost(BlogPostRequest request) async {
    // FIX: Ingen trailing slash
    final url = '${ApiConfig.blogUrl}/api/posts';

    final response = await http.post(
      Uri.parse(url),
      headers: ApiService.headers,
      body: jsonEncode(request.toJson()),
    );

    debugPrint('🌐 BlogService.createPost() - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return BlogPost.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Uppdatera inlägg (Endast Admin)
  Future<BlogPost> updatePost(int postId, BlogPostRequest request) async {
    // FIX: Ingen trailing slash efter postId
    final url = '${ApiConfig.blogUrl}/api/posts/$postId';

    final response = await http.put(
      Uri.parse(url),
      headers: ApiService.headers,
      body: jsonEncode(request.toJson()),
    );

    debugPrint(
        '🌐 BlogService.updatePost($postId) - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return BlogPost.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Ta bort inlägg (Endast Admin)
  Future<void> deletePost(int postId) async {
    // FIX: Ingen trailing slash efter postId
    final url = '${ApiConfig.blogUrl}/api/posts/$postId';

    final response = await http.delete(
      Uri.parse(url),
      headers: ApiService.headers,
    );

    debugPrint(
        '🌐 BlogService.deletePost($postId) - Status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }

  /// Hämta ALLA inlägg inkl. utkast (Endast Admin)
  Future<List<BlogPost>> getAllPosts({int page = 0, int size = 20}) async {
    // FIX: Korrekt routing för admin-vyn
    final url = '${ApiConfig.blogUrl}/api/posts/admin?page=$page&size=$size';

    debugPrint('🌐 BlogService.getAllPosts() - URL: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.headers,
    );

    debugPrint('🌐 BlogService.getAllPosts() - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;

      final content = data['content'] ?? data;
      if (content is List) {
        return content.map((item) => BlogPost.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}
