// lib/services/blog_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_exception.dart';
import 'auth_service.dart';
import '../models/blog_models.dart';

/// Service for blog post operations
class BlogService {
  final AuthService _authService;

  BlogService(this._authService);

  /// Get published blog posts (public)
  Future<List<BlogPost>> getPublishedPosts({int page = 0, int size = 10}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.postsUrl}/api/posts/?page=$page&size=$size'),
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint('📝 BlogService.getPublishedPosts() - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;

      // Handle paginated response
      final content = data['content'] ?? data;
      if (content is List) {
        return content.map((item) => BlogPost.fromJson(item)).toList();
      }
      return [];
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get single blog post by slug (public)
  Future<BlogPost> getPostBySlug(String slug) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.postsUrl}/api/posts/$slug/'),
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint('📝 BlogService.getPostBySlug($slug) - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return BlogPost.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Create new blog post (admin only)
  Future<BlogPost> createPost(BlogPostRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.postsUrl}/api/posts/'),
      headers: _authService.authHeaders,
      body: jsonEncode(request.toJson()),
    );

    debugPrint('📝 BlogService.createPost() - Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return BlogPost.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Update existing blog post (admin only)
  Future<BlogPost> updatePost(int postId, BlogPostRequest request) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.postsUrl}/api/posts/$postId/'),
      headers: _authService.authHeaders,
      body: jsonEncode(request.toJson()),
    );

    debugPrint('📝 BlogService.updatePost($postId) - Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final data = json['data'] ?? json;
      return BlogPost.fromJson(data);
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Delete blog post (admin only)
  Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.postsUrl}/api/posts/$postId/'),
      headers: _authService.authHeaders,
    );

    debugPrint('📝 BlogService.deletePost($postId) - Status: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }

  /// Get all posts including drafts (admin only)
  Future<List<BlogPost>> getAllPosts({int page = 0, int size = 20}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.postsUrl}/api/posts/admin/?page=$page&size=$size'),
      headers: _authService.authHeaders,
    );

    debugPrint('📝 BlogService.getAllPosts() - Status: ${response.statusCode}');

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
