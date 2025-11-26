// =============================================================
// File: lib/app.dart
// Purpose: App entry with 3 switchable design systems (themes),
//          adaptive layout, and navigation shell.
// Platforms: Windows (desktop), Web, iOS, Android
// =============================================================
import 'package:flutter/material.dart';
import 'ui/themes.dart';
import 'ui/responsive_scaffold.dart';
import 'app_router.dart';
import 'screens/product_detail_screen.dart';
import 'screens/blog_detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_paypal_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_products_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_sales_report_screen.dart';

/// Three cohesive UI packages to choose from at runtime.
enum UIStyle { nordicLight, darkPro, storefrontPop }

class AppState extends ChangeNotifier {
  UIStyle _style = UIStyle.darkPro;
  UIStyle get style => _style;
  set style(UIStyle s) {
    if (_style != s) {
      _style = s;
      notifyListeners();
    }
  }
}

class Perfect8App extends StatelessWidget {
  final AppState state;
  const Perfect8App({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final light = Themes.forStyle(state.style, Brightness.light);
        final dark = Themes.(state.style, Brightness.dark);
        return MaterialApp(
          title: 'Perfect8',
          debugShowCheckedModeBanner: false,
          theme: light,
          darkTheme: dark,
          themeMode: ThemeMode.system,
          home: ResponsiveScaffold(
            onChangeTheme: (style) => state.style = style,
            currentStyle: state.style,
          ),
          onGenerateRoute: (settings) {
            // Centralized route handling (Navigator 1.0)
            switch (settings.name) {
              case AppRoutes.productDetail:
                final args = settings.arguments as Map?; 
                final id = (args?['id'] ?? 0) as int;
                return MaterialPageRoute(builder: (_) => ProductDetailScreen(id: id));
              case AppRoutes.blogDetail:
                final args = settings.arguments as Map?; 
                final id = (args?['id'] ?? 0) as int;
                return MaterialPageRoute(builder: (_) => BlogDetailScreen(id: id));
              case AppRoutes.search:
                return MaterialPageRoute(builder: (_) => const SearchScreen());
              case AppRoutes.cart:
                return MaterialPageRoute(builder: (_) => const CartScreen());
              case AppRoutes.checkout:
                return MaterialPageRoute(builder: (_) => const CheckoutPayPalScreen());
              case AppRoutes.login:
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              case AppRoutes.adminDashboard:
                return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
              case AppRoutes.adminProducts:
                return MaterialPageRoute(builder: (_) => const AdminProductsScreen());
              case AppRoutes.adminOrders:
                return MaterialPageRoute(builder: (_) => const AdminOrdersScreen());
              case AppRoutes.adminSales:
                return MaterialPageRoute(builder: (_) => const AdminSalesReportScreen());
            }
            return null;
          },
        );
      },
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  runApp(Perfect8App(state: state));
}

// =============================================================
// File: lib/app_router.dart
// Purpose: Centralized route names used across the app.
// Note: Using Navigator 1.0 for simplicity (no 3rd party deps).
// =============================================================
class AppRoutes {
  static const productDetail = '/productDetail'; // args: {id: int}
  static const blogDetail = '/blogDetail'; // args: {id: int}
  static const search = '/search';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const login = '/login';
  static const adminDashboard = '/admin/dashboard';
  static const adminProducts = '/admin/products';
  static const adminOrders = '/admin/orders';
  static const adminSales = '/admin/sales';
}