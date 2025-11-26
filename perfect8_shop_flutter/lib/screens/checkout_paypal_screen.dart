// =============================================================
// File: lib/screens/checkout_paypal_screen.dart
// Purpose: Checkout flow. Create + execute PayPal payment.
// Endpoints: POST /api/payments/paypal/create, /api/payments/paypal/execute
// =============================================================
import 'package:flutter/material.dart';

class CheckoutPayPalScreen extends StatelessWidget {
  const CheckoutPayPalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const ListTile(title: Text('3 items'), trailing: Text('\$147.00')),
          const Spacer(),
          FilledButton.icon(onPressed: () {/* TODO: call create → open approve → execute */}, icon: const Icon(Icons.lock_rounded), label: const Text('Pay with PayPal')),
        ]),
      ),
    );
  }
}