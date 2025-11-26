// =============================================================
// File: lib/screens/blog_detail_screen.dart
// Purpose: Post details with hero image and related products.
// Endpoints: GET /api/posts/{id}, + deep links to products.
// =============================================================
import 'package:flutter/material.dart';

class BlogDetailScreen extends StatelessWidget {
  final int id;
  const BlogDetailScreen({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blog Post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(aspectRatio: 16 / 9, child: Container(color: Theme.of(context).colorScheme.surfaceVariant)),
          const SizedBox(height: 16),
          Text('Post Title', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit…'),
          const SizedBox(height: 24),
          Text('Related products', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 12, children: const [Chip(label: Text('Product A')), Chip(label: Text('Product B'))]),
        ],
      ),
    );
  }
}