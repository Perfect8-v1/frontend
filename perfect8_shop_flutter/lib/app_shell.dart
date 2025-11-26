import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/categories_page.dart';
import 'pages/cart_page.dart';
import 'pages/login_page.dart';
import 'pages/checkout_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    CategoriesPage(),
    CartPage(),
    LoginPage(),
    CheckoutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfect8 Shop'),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Hem'),
          NavigationDestination(icon: Icon(Icons.category), label: 'Kategorier'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Kundvagn'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Logga in'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Checkout'),
        ],
      ),
    );
  }
}
