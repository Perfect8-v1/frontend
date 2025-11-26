import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lyssna på AuthProvider. Använd isLoggedIn för att bestämma vy.
    final auth = context.watch<AuthProvider>();
    
    // --- Inloggad Vyn ---
    if (auth.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Inloggad som ${auth.email}'), 
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text('Logga ut'),
            ),
          ],
        ),
      );
    }

    // --- Utloggad Vyn (Inloggningsformulär) ---
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Logga in', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-post'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Ange e-post' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Lösenord'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Ange lösenord' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // --- FIXAD INLOGGNINGSLOGIK ---
                  FilledButton(
                    onPressed: _loading ? null : () async {
                      if (!_formKey.currentState!.validate()) return;
                      
                      // Steg 1: Sätt _loading till true (visar laddningsikon).
                      setState(() => _loading = true);
                      
                      final email = _emailCtrl.text.trim();
                      final password = _passCtrl.text;

                      final ok = await context.read<AuthProvider>().login(email, password);
                      
                      // Steg 2: Hantera resultatet av inloggningen.
                      if (!ok && context.mounted) {
                        // ENDAST vid misslyckande: Sätt _loading till false
                        // och visa felmeddelande. Detta bryter den oönskade loopen.
                        setState(() => _loading = false); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Inloggning misslyckades')),
                        );
                      }
                      // Vid succé (ok är true) triggar notifyListeners() i AuthProvider
                      // en rebuild som tar bort denna widget, och _loading = false 
                      // behöver INTE anropas här.
                    },
                    child: _loading 
                        ? const SizedBox(
                            width: 18, 
                            height: 18, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ) 
                        : const Text('Logga in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}