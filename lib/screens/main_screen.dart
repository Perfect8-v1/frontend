// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import 'product_list_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'blog_list_screen.dart';
import 'admin_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _authService = AuthService();
  late final CartService _cartService;
  int _currentIndex = 0;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _cartService = CartService(_authService);
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await _cartService.getCart();
      debugPrint('🏷️ Cart loaded: itemCount=${cart.itemCount}, totalQuantity=${cart.totalQuantity}, items=${cart.items.length}');
      if (mounted) {
        // Use totalQuantity (sum of all item quantities) for badge
        setState(() => _cartItemCount = cart.totalQuantity);
      }
    } catch (e) {
      debugPrint('🏷️ Cart load error: $e');
    }
  }

  /// Call this from other screens to refresh cart count
  void refreshCartCount() {
    _loadCartCount();
  }

  List<Widget> get _screens {
    final screens = <Widget>[
      ProductListScreen(onCartUpdated: refreshCartCount),
      CartScreen(onCartUpdated: refreshCartCount),
      const ProfileScreen(),
      const BlogListScreen(),
    ];

    if (_authService.isAdmin) {
      screens.add(const AdminScreen());
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
      BottomNavigationBarItem(
        icon: _buildCartIcon(Icons.shopping_cart_outlined),
        activeIcon: _buildCartIcon(Icons.shopping_cart),
        label: 'Kundvagn',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.article_outlined),
        activeIcon: Icon(Icons.article),
        label: 'Blogg',
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

  Widget _buildCartIcon(IconData icon) {
    return Badge(
      isLabelVisible: _cartItemCount > 0,
      label: Text(
        _cartItemCount > 99 ? '99+' : '$_cartItemCount',
        style: const TextStyle(fontSize: 10),
      ),
      child: Icon(icon),
    );
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
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Refresh cart count when switching to cart tab
          if (index == 1) {
            _loadCartCount();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: _navItems,
      ),
    );
  }
}
