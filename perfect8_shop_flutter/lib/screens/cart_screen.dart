// =============================================================
// File: lib/screens/cart_screen.dart
// Purpose: Simple cart with quantities and total.
// =============================================================
import 'package:flutter/material.dart';
import '../../app_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) => const ListTile(
          leading: CircleAvatar(),
          title: Text('Product X'),
          subtitle: Text('Qty × Price'),
          trailing: Text('\$49.00'),
        ),
        separatorBuilder: (_, __) => const Divider(),
        itemCount: 3,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.checkout),
            child: const Text('Proceed to checkout'),
          ),
        ),
      ),
    );
  }
}