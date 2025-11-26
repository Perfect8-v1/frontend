import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const QuantityStepper({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () => onChanged(value - 1),
        ),
        Text('$value'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
