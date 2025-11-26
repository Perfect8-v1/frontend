// =============================================================
// File: lib/screens/search_screen.dart
// Purpose: Global search (products + blog posts)
// Endpoints: GET /api/products/search, GET /api/posts/search
// =============================================================
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: ctrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search products & blog…')),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(itemCount: 8, itemBuilder: (_, i) => const ListTile(title: Text('Result item')))),
        ]),
      ),
    );
  }
}