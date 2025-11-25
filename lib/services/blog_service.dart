import 'api_service.dart';
import '../config/api_config.dart';
import '../models/blog_post.dart';

class BlogService extends ApiService {
  // Get all published posts
  Future<List<BlogPost>> getAllPosts() async {
    final url = '${ApiConfig.blogUrl}/api/posts';
    final response = await get(url, requiresAuth: false);
    
    return (response as List)
        .map((json) => BlogPost.fromJson(json))
        .toList();
  }
  
  // Get single post by ID
  Future<BlogPost> getPost(int postId) async {
    final url = '${ApiConfig.blogUrl}/api/posts/$postId';
    final response = await get(url, requiresAuth: false);
    
    return BlogPost.fromJson(response);
  }
  
  // Get post by slug
  Future<BlogPost> getPostBySlug(String slug) async {
    final url = '${ApiConfig.blogUrl}/api/posts/slug/$slug';
    final response = await get(url, requiresAuth: false);
    
    return BlogPost.fromJson(response);
  }
}