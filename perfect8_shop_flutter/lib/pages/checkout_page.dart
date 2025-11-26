import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _zip = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _zip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Checkout', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Namn'),
                      validator: (v) => v == null || v.isEmpty ? 'Obligatoriskt' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _address,
                      decoration: const InputDecoration(labelText: 'Adress'),
                      validator: (v) => v == null || v.isEmpty ? 'Obligatoriskt' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _city,
                            decoration: const InputDecoration(labelText: 'Stad'),
                            validator: (v) => v == null || v.isEmpty ? 'Obligatoriskt' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _zip,
                            decoration: const InputDecoration(labelText: 'Postnummer'),
                            validator: (v) => v == null || v.isEmpty ? 'Obligatoriskt' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Att betala: ${cart.total.toStringAsFixed(2)} \$',
                            style: Theme.of(context).textTheme.titleMedium),
                        FilledButton.icon(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Betalning skickad (mock). Tack!')),
                            );
                            cart.clear();
                          },
                          icon: const Icon(Icons.lock),
                          label: const Text('Betala'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
