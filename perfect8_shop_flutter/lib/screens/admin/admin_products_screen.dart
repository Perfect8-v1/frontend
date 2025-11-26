// =============================================================
// File: lib/screens/admin/admin_products_screen.dart
// Purpose: CRUD products with status/stock toggles.
// Endpoints: GET/POST/PUT/DELETE /api/products, PUT /api/products/{id}/stock, toggle-status
// =============================================================
import 'package:flutter/material.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Products')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {/* TODO: create */}, label: const Text('New product'), icon: const Icon(Icons.add_rounded)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 12,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            leading: const CircleAvatar(),
            title: Text('Product #$i'),
            subtitle: const Text('Status: Active • Stock: 42'),
            trailing: Wrap(spacing: 6, children: [
              IconButton(onPressed: () {/* TODO: edit */}, icon: const Icon(Icons.edit_rounded)),
              IconButton(onPressed: () {/* TODO: toggle status */}, icon: const Icon(Icons.toggle_on_rounded)),
              IconButton(onPressed: () {/* TODO: delete */}, icon: const Icon(Icons.delete_outline_rounded)),
            ]),
          ),
        ),
      ),
    );
  }
}