// lib/screens/admin_blog_list_screen.dart
import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import '../services/blog_service.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import 'admin_blog_edit_screen.dart';

/// Admin screen for managing blog posts
class AdminBlogListScreen extends StatefulWidget {
  const AdminBlogListScreen({super.key});

  @override
  State<AdminBlogListScreen> createState() => _AdminBlogListScreenState();
}

class _AdminBlogListScreenState extends State<AdminBlogListScreen> {
  final _authService = AuthService();
  late final BlogService _blogService;

  List<BlogPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _blogService = BlogService(_authService);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try admin endpoint first, fall back to public
      try {
        final posts = await _blogService.getAllPosts();
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } catch (_) {
        // Fall back to public posts if admin endpoint fails
        final posts = await _blogService.getPublishedPosts(size: 50);
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda inlägg: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(BlogPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Radera inlägg?'),
        content: Text('Vill du radera "${post.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Radera'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _blogService.deletePost(post.postId);
      _loadPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inlägget raderades')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunde inte radera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createPost() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AdminBlogEditScreen()),
    );
    if (result == true) {
      _loadPosts();
    }
  }

  void _editPost(BlogPost post) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminBlogEditScreen(post: post),
      ),
    );
    if (result == true) {
      _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hantera blogg'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        icon: const Icon(Icons.add),
        label: const Text('Nytt inlägg'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadPosts,
                icon: const Icon(Icons.refresh),
                label: const Text('Försök igen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Inga blogginlägg än',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _createPost,
              icon: const Icon(Icons.add),
              label: const Text('Skapa första inlägget'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildPostTile(_posts[index]),
    );
  }

  Widget _buildPostTile(BlogPost post) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: post.published ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          post.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(post.formattedDate),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: post.published ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                post.published ? 'Publicerad' : 'Utkast',
                style: TextStyle(
                  fontSize: 10,
                  color:
                      post.published ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.visibility, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 2),
            Text(
              '${post.viewCount}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editPost(post);
            if (value == 'delete') _deletePost(post);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Redigera'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Radera', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _editPost(post),
      ),
    );
  }
}
