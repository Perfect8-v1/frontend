// lib/screens/blog_post_screen.dart
import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import '../services/auth_service.dart';
import '../services/blog_service.dart';
import '../services/api_config.dart';
import '../services/api_exception.dart';

/// Screen for viewing a single blog post
class BlogPostScreen extends StatefulWidget {
  final String slug;

  const BlogPostScreen({super.key, required this.slug});

  @override
  State<BlogPostScreen> createState() => _BlogPostScreenState();
}

class _BlogPostScreenState extends State<BlogPostScreen> {
  final _authService = AuthService();
  late final BlogService _blogService;

  BlogPost? _post;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _blogService = BlogService(_authService);
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final post = await _blogService.getPostBySlug(widget.slug);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kunde inte ladda inlägget: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_post?.title ?? 'Laddar...'),
      ),
      body: _buildBody(),
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
                onPressed: _loadPost,
                icon: const Icon(Icons.refresh),
                label: const Text('Försök igen'),
              ),
            ],
          ),
        ),
      );
    }

    if (_post == null) {
      return const Center(child: Text('Inlägget hittades inte'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _post!.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Meta info
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _post!.formattedDate,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${_post!.viewCount} visningar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const Divider(height: 32),

          // Images (if any)
          if (_post!.images.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _post!.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final image = _post!.images[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${ApiConfig.imageUrl}/api/v1/images/${image.imageId}/content/',
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Content (rendered as simple text - could use flutter_html for rich content)
          Text(
            _stripHtml(_post!.content),
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Strip HTML tags from content for basic display
  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}
