// =============================================================
// File: lib/screens/orders_screen.dart
// Purpose: List user orders + inline details.
// Endpoints: GET /api/orders (with status/pagination), GET /api/orders/{id}
// =============================================================
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => Card(
        child: ListTile(
          title: Text('Order #10$i'),
          subtitle: const Text('Status: Processing — 3 items'),
          trailing: const Text('\$120.00'),
          onTap: () => showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (_) => const _OrderDetailSheet(),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order details', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const ListTile(title: Text('Item A'), trailing: Text('\$49.00')),
          const ListTile(title: Text('Item B'), trailing: Text('\$71.00')),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () {}, child: const Text('Track shipment'))),
        ]),
      ),
    );
  }
}