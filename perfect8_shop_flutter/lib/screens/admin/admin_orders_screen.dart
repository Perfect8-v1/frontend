// =============================================================
// File: lib/screens/admin/admin_orders_screen.dart
// Purpose: Manage orders + statuses, refunds, shipment.
// Endpoints: GET/PUT /api/orders, /api/payments/refund, /api/shipments
// =============================================================
import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Orders')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => Card(
          child: ListTile(
            title: Text('Order #10$i'),
            subtitle: const Text('Customer John • Status: Processing'),
            trailing: Wrap(spacing: 8, children: [
              DropdownButton<String>(
                value: 'Processing',
                underline: const SizedBox.shrink(),
                items: const [DropdownMenuItem(value: 'Processing', child: Text('Processing')), DropdownMenuItem(value: 'Shipped', child: Text('Shipped')), DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled'))],
                onChanged: (v) {/* TODO: update /status */},
              ),
              IconButton(onPressed: () {/* TODO: refund */}, icon: const Icon(Icons.reply_rounded), tooltip: 'Refund'),
              IconButton(onPressed: () {/* TODO: shipment */}, icon: const Icon(Icons.local_shipping_rounded), tooltip: 'Shipment'),
            ]),
          ),
        ),
      ),
    );
  }
}