import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'state/cart_provider.dart';
import 'state/auth_provider.dart';
import 'state/catalog_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Perfect8 Shop!',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
          useMaterial3: true,
        ),
        home: const AppShell(),
      ),
    );
  }
}
