// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'admin_upload_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _authService = AuthService();
  int _currentIndex = 0;

  List<Widget> get _screens {
    final screens = <Widget>[
      const ProductListScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    if (_authService.isAdmin) {
      screens.add(const AdminUploadScreen());
    }

    return screens;
  }

  List<BottomNavigationBarItem> get _navItems {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.store_outlined),
        activeIcon: Icon(Icons.store),
        label: 'Produkter',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart_outlined),
        activeIcon: Icon(Icons.shopping_cart),
        label: 'Kundvagn',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    if (_authService.isAdmin) {
      items.add(const BottomNavigationBarItem(
        icon: Icon(Icons.admin_panel_settings_outlined),
        activeIcon: Icon(Icons.admin_panel_settings),
        label: 'Admin',
      ));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }
}
