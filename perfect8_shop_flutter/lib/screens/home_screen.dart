// =============================================================
// File: lib/screens/home_screen.dart
// Purpose: Landing hero, featured products, blog highlights.
// Notes: Integrate products GET /api/products/featured and posts
//        GET /api/posts/published for sections.
// =============================================================
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroCard(),
        const SizedBox(height: 16),
        Text('Featured Products', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _PlaceholderGrid(count: 4, aspect: 1),
        const SizedBox(height: 16),
        Text('From the Blog', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        _PlaceholderList(count: 3),
        const SizedBox(height: 48),
        Text('Made with Flutter • Material 3', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline)),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome to Perfect8', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Portfolio‑grade blog + e‑commerce demo. Browse products and read our latest posts.'),
            const SizedBox(height: 16),
            Wrap(spacing: 12, children: [
              ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.store_rounded), label: const Text('Shop now')),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.article_rounded), label: const Text('Read blog')),
            ]),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderGrid extends StatelessWidget {
  final int count;
  final double aspect;
  const _PlaceholderGrid({required this.count, required this.aspect});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: count,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspect,
      ),
      itemBuilder: (_, i) => const _ProductPlaceholderCard(),
    );
  }
}

class _ProductPlaceholderCard extends StatelessWidget {
  const _ProductPlaceholderCard();
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(color: Theme.of(context).colorScheme.surfaceVariant)),
            const ListTile(title: Text('Product name'), subtitle: Text('Short blurb')),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderList extends StatelessWidget {
  final int count;
  const _PlaceholderList({required this.count});
  @override
  Widget build(BuildContext context) {
    return Column(children: [for (int i = 0; i < count; i++) const _BlogRow()]);
  }
}

class _BlogRow extends StatelessWidget {
  const _BlogRow();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      leading: const CircleAvatar(radius: 24),
      title: const Text('Blog post title'),
      subtitle: const Text('Teaser text…'),
      onTap: () {},
    );
  }
}