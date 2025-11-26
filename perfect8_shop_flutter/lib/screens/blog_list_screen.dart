// =============================================================
// File: lib/screens/blog_list_screen.dart
// Purpose: Blog feed with pagination and tags.
// Endpoints: GET /api/posts/published, /api/posts/search
// =============================================================
import 'package:flutter/material.dart';
import '../../app_router.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => Card(
        child: ListTile(
          title: const Text('Blog post title'),
          subtitle: const Text('A short teaser…'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.blogDetail, arguments: {'id': i}),
        ),
      ),
    );
  }
}