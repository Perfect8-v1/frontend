// =============================================================
// File: lib/ui/responsive_scaffold.dart
// Purpose: One adaptive shell that switches navigation patterns:
//  - <600: BottomNavigationBar + FAB (cart)
//  - 600–1024: NavigationRail
//  - >=1024: Rail extended (sidebar)
// Also exposes a theme switcher.
// =============================================================
import 'package:flutter/material.dart';
import '../app.dart';
import '../app_router.dart';
import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/blog_list_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';

enum TabItem { home, shop, blog, orders, profile }

extension on TabItem {
  String get label => switch (this) {
        TabItem.home => 'Home',
        TabItem.shop => 'Shop',
        TabItem.blog => 'Blog',
        TabItem.orders => 'Orders',
        TabItem.profile => 'Profile',
      };
  IconData get icon => switch (this) {
        TabItem.home => Icons.home_rounded,
        TabItem.shop => Icons.store_rounded,
        TabItem.blog => Icons.article_rounded,
        TabItem.orders => Icons.receipt_long_rounded,
        TabItem.profile => Icons.person_rounded,
      };
}

class ResponsiveScaffold extends StatefulWidget {
  final ValueChanged<UIStyle> onChangeTheme;
  final UIStyle currentStyle;
  const ResponsiveScaffold({super.key, required this.onChangeTheme, required this.currentStyle});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  TabItem _tab = TabItem.home;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    final body = IndexedStack(
      index: _tab.index,
      children: const [
        HomeScreen(),
        ProductListScreen(),
        BlogListScreen(),
        OrdersScreen(),
        ProfileScreen(),
      ],
    );

    final actions = <Widget>[
      IconButton(
        tooltip: 'Search',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
        icon: const Icon(Icons.search_rounded),
      ),
      PopupMenuButton<Object>(
        tooltip: 'Theme',
        onSelected: (value) {
          if (value is UIStyle) widget.onChangeTheme(value);
        },
        itemBuilder: (context) => [
          CheckedPopupMenuItem(
            value: UIStyle.nordicLight,
            checked: widget.currentStyle == UIStyle.nordicLight,
            child: const Text('Nordic Light'),
          ),
          CheckedPopupMenuItem(
            value: UIStyle.darkPro,
            checked: widget.currentStyle == UIStyle.darkPro,
            child: const Text('Dark Pro'),
          ),
          CheckedPopupMenuItem(
            value: UIStyle.storefrontPop,
            checked: widget.currentStyle == UIStyle.storefrontPop,
            child: const Text('Storefront Pop'),
          ),
        ],
        icon: const Icon(Icons.brightness_6_rounded),
      ),
    ];

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(title: Text(_tab.label), actions: actions),
        body: SafeArea(child: body),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
          icon: const Icon(Icons.shopping_cart_rounded),
          label: const Text('Cart'),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab.index,
          onDestinationSelected: (i) => setState(() => _tab = TabItem.values[i]),
          destinations: [for (final t in TabItem.values) NavigationDestination(icon: Icon(t.icon), label: t.label)],
        ),
      );
    }

    // Tablet & Desktop use a Rail
    final rail = NavigationRail(
      selectedIndex: _tab.index,
      onDestinationSelected: (i) => setState(() => _tab = TabItem.values[i]),
      labelType: isTablet ? NavigationRailLabelType.selected : NavigationRailLabelType.none,
      extended: isDesktop,
      destinations: [
        for (final t in TabItem.values)
          NavigationRailDestination(icon: Icon(t.icon), label: Text(t.label)),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(_tab.label), actions: actions),
      body: Row(
        children: [
          rail,
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: body)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
        icon: const Icon(Icons.shopping_cart_checkout),
        label: const Text('Cart'),
      ),
    );
  }
}