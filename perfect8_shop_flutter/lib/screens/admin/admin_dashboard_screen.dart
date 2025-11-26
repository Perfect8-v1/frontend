// =============================================================
// File: lib/screens/admin/admin_dashboard_screen.dart
// Purpose: KPIs and quick links.
// Endpoint: GET /api/admin/dashboard/stats, /api/admin/orders/recent
// =============================================================
import 'package:flutter/material.dart';
import '../../../app_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: MediaQuery.of(context).size.width < 900 ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _KpiCard(title: 'Sales (30d)', value: '\$ 12,430'),
          _KpiCard(title: 'Orders (30d)', value: '118'),
          _KpiCard(title: 'Active customers', value: '1,264'),
          _KpiCard(title: 'Low stock', value: '5'),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(spacing: 12, children: [
            OutlinedButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminProducts), icon: const Icon(Icons.inventory_2_rounded), label: const Text('Products')),
            OutlinedButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminOrders), icon: const Icon(Icons.receipt_long_rounded), label: const Text('Orders')),
            OutlinedButton.icon(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminSales), icon: const Icon(Icons.bar_chart_rounded), label: const Text('Sales')),
          ]),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title; final String value;
  const _KpiCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}