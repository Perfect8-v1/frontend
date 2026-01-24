import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';

/// Main entry point for Perfect8 Flutter App
void main() {
  runApp(const Perfect8App());
}

/// Root widget of the application
class Perfect8App extends StatelessWidget {
  const Perfect8App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title
      title: 'Perfect8 Training',

      // Theme configuration
      theme: ThemeData(
        // Primary color for app
        primarySwatch: Colors.blue,

        // Use Material 3 design
        useMaterial3: true,

        // Text theme
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Remove debug banner
      debugShowCheckedModeBanner: false,

      // Start with splash that checks auth
      home: const AuthCheckScreen(),
    );
  }
}

/// Initial screen that checks if user is logged in
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authService = AuthService();
    await authService.loadToken();

    if (!mounted) return;

    // Navigate based on auth state
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            authService.isLoggedIn ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
