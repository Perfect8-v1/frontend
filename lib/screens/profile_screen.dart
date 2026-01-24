// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../models/customer_models.dart';
import '../services/customer_service.dart';
import '../services/auth_service.dart';
import '../services/api_exception.dart';
import 'login_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late final CustomerService _customerService;

  Customer? _customer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _customerService = CustomerService(_authService);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final customer = await _customerService.getProfile();
      if (mounted) {
        setState(() {
          _customer = customer;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Could not load profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      _getInitials(),
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    Text(
                      _customer?.fullName.isNotEmpty == true
                          ? _customer!.fullName
                          : _authService.email ?? 'Användare',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (_customer?.fullName.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        _authService.email ?? '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _authService.roles.map((role) {
                      final isAdminRole =
                          role == 'ADMIN' || role == 'ROLE_ADMIN';
                      return Chip(
                        label: Text(
                          role.replaceAll('ROLE_', ''),
                          style: TextStyle(
                            color: isAdminRole ? Colors.white : null,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor:
                            isAdminRole ? Colors.deepPurple : Colors.grey[200],
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
            leading: const Icon(Icons.person_outline),
            title: const Text('Redigera profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showEditProfileDialog,
          ),
          const Divider(),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressesScreen()),
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
              await _authService.logout();
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

  String _getInitials() {
    if (_customer?.firstName != null && _customer?.lastName != null) {
      return '${_customer!.firstName![0]}${_customer!.lastName![0]}'
          .toUpperCase();
    }
    return (_authService.email?.substring(0, 1) ?? 'U').toUpperCase();
  }

  void _showEditProfileDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameController =
        TextEditingController(text: _customer?.firstName ?? '');
    final lastNameController =
        TextEditingController(text: _customer?.lastName ?? '');
    final phoneController =
        TextEditingController(text: _customer?.phoneNumber ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Redigera profil'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Förnamn *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Efternamn *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Obligatoriskt' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(dialogContext);

              try {
                final updated = await _customerService.updateProfile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  phone: phoneController.text.isNotEmpty
                      ? phoneController.text
                      : null,
                );

                if (mounted) {
                  setState(() => _customer = updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil uppdaterad')),
                  );
                }
              } on ApiException catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fel: ${e.message}')),
                  );
                }
              }
            },
            child: const Text('Spara'),
          ),
        ],
      ),
    );
  }
}
