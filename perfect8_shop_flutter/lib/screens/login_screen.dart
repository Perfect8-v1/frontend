// =============================================================
// File: lib/screens/login_screen.dart
// Purpose: Admin login (JWT) + user sign‑in.
// Endpoints: POST /api/auth/login, GET /api/auth/me
// =============================================================
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : () async {
              setState(() => _busy = true);
              // TODO: call /api/auth/login, store JWT securely.
              await Future.delayed(const Duration(milliseconds: 600));
              if (context.mounted) Navigator.of(context).pop();
            },
            child: _busy ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Sign in'),
          ),
        ]),
      ),
    );
  }
}