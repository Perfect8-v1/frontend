import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (a, b) => a + b.quantity);
  double get total =>
      _items.values.fold(0.0, (a, b) => a + (b.product.price * b.quantity));

  void add(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void remove(Product product) {
    if (!_items.containsKey(product.id)) return;
    final item = _items[product.id]!;
    item.quantity--;
    if (item.quantity <= 0) {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void setQty(Product product, int qty) {
    if (qty <= 0) {
      _items.remove(product.id);
    } else {
      _items[product.id] = CartItem(product: product, quantity: qty);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
