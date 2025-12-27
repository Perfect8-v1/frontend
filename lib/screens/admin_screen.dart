// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'admin_product_list_screen.dart';
import 'admin_product_images_screen.dart';
import 'admin_upload_screen.dart';
import 'admin_blog_list_screen.dart';

/// Admin hub screen with navigation to admin features
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            icon: Icons.inventory_2,
            title: 'Hantera Produkter',
            subtitle: 'Skapa, redigera och ta bort produkter',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminProductListScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            icon: Icons.image,
            title: 'Produktbilder',
            subtitle: 'Koppla bilder till produkter',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminProductImagesScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            icon: Icons.upload_file,
            title: 'Ladda upp Bilder',
            subtitle: 'Ladda upp nya bilder till systemet',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminUploadScreen()),
            ),
          ),
          _buildAdminCard(
            context,
            icon: Icons.article,
            title: 'Hantera Blogg',
            subtitle: 'Skapa, redigera och publicera blogginlägg',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminBlogListScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
