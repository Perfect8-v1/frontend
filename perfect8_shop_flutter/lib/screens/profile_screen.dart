// =============================================================
// File: lib/screens/profile_screen.dart
// Purpose: User account area — details, addresses, auth, admin entry.
// Endpoints: GET /api/customers/email/{email}, PUT /api/customers/{id}
// =============================================================
import 'package:flutter/material.dart';
import '../../app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(radius: 36),
        const SizedBox(height: 12),
        Center(child: Text('John Doe', style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: 24),
        Card(
          child: Column(children: [
            ListTile(leading: const Icon(Icons.email_rounded), title: const Text('Email'), subtitle: const Text('john@example.com')),
            ListTile(leading: const Icon(Icons.location_on_rounded), title: const Text('Shipping address'), subtitle: const Text('Add an address')),
          ]),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login), icon: const Icon(Icons.login_rounded), label: const Text('Sign in')),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminDashboard), icon: const Icon(Icons.admin_panel_settings_rounded), label: const Text('Admin Dashboard')),
      ],
    );
  }
}