import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

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
      
      // Start with LoginScreen
      home: const LoginScreen(),
    );
  }
}
