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