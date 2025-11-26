import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/cart_provider.dart';
import '../widgets/quantity_stepper.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    if (items.isEmpty) {
      return const Center(child: Text('Kundvagnen är tom.'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final it = items[i];
              return ListTile(
                leading: it.product.imageUrl.isNotEmpty
                    ? Image.network(it.product.imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                    : const SizedBox(width: 56, height: 56),
                title: Text(it.product.name),
                subtitle: Text('${it.product.price.toStringAsFixed(2)} \$ / st'),
                trailing: QuantityStepper(
                  value: it.quantity,
                  onChanged: (v) => cart.setQty(it.product, v),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Totalt: ${cart.total.toStringAsFixed(2)} \$',
                  style: Theme.of(context).textTheme.titleLarge),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout påbörjad (mock). Gå till fliken "Checkout".')),
                  );
                },
                icon: const Icon(Icons.payment),
                label: const Text('Till kassan'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
