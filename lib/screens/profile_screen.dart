// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      (authService.email?.substring(0, 1) ?? 'U').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authService.email ?? 'Användare',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: authService.roles.map((role) {
                      final isAdminRole = role == 'ADMIN' || role == 'ROLE_ADMIN';
                      return Chip(
                        label: Text(
                          role.replaceAll('ROLE_', ''),
                          style: TextStyle(
                            color: isAdminRole ? Colors.white : null,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isAdminRole
                            ? Colors.deepPurple
                            : Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu items
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Mina ordrar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kommer snart...')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Adresser'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kommer snart...')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Inställningar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kommer snart...')),
              );
            },
          ),
          const Divider(),
          const SizedBox(height: 24),

          // Logout button
          FilledButton.icon(
            onPressed: () async {
              await authService.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logga ut'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red[700],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
