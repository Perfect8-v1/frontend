// lib/repositories/mock_cart_repository.dart

import '../models/cart.dart';
import '../models/cart_item.dart';
import 'cart_repository.dart';

/// Mock-implementation för utveckling utan backend.
/// Byt till ApiCartRepository när backend är redo.
class MockCartRepository implements CartRepository {
  // Simulerad kundvagn i minnet
  Cart _cart = Cart.empty();

  // Fake produkter för test
  final Map<int, Map<String, dynamic>> _fakeProducts = {
    1: {
      'name': 'Produkt A',
      'price': 99.00,
      'image': 'https://via.placeholder.com/150'
    },
    2: {
      'name': 'Produkt B',
      'price': 149.00,
      'image': 'https://via.placeholder.com/150'
    },
    3: {
      'name': 'Produkt C',
      'price': 199.00,
      'image': 'https://via.placeholder.com/150'
    },
    4: {
      'name': 'Produkt D',
      'price': 299.00,
      'image': 'https://via.placeholder.com/150'
    },
    5: {
      'name': 'Produkt E',
      'price': 49.00,
      'image': 'https://via.placeholder.com/150'
    },
  };

  @override
  Future<Cart> getCart() async {
    // Simulera nätverksfördröjning
    await Future.delayed(const Duration(milliseconds: 300));
    return _cart;
  }

  @override
  Future<Cart> addToCart({
    required int productId,
    required int quantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Kolla om produkten finns i vår fake-databas
    final product = _fakeProducts[productId];
    if (product == null) {
      throw Exception('Produkt med ID $productId finns inte');
    }

    // Kolla om produkten redan finns i vagnen
    final existingIndex = _cart.items.indexWhere(
      (item) => item.productId == productId,
    );

    List<CartItem> updatedItems = List.from(_cart.items);

    if (existingIndex >= 0) {
      // Öka kvantiteten
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      // Lägg till ny produkt
      updatedItems.add(CartItem(
        productId: productId,
        productName: product['name'] as String,
        imageUrl: product['image'] as String?,
        unitPrice: product['price'] as double,
        quantity: quantity,
      ));
    }

    _cart = Cart(
      items: updatedItems,
      updatedDate: DateTime.now(),
    );

    return _cart;
  }

  @override
  Future<Cart> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (quantity <= 0) {
      return removeFromCart(productId: productId);
    }

    final index = _cart.items.indexWhere(
      (item) => item.productId == productId,
    );

    if (index < 0) {
      throw Exception('Produkten finns inte i vagnen');
    }

    List<CartItem> updatedItems = List.from(_cart.items);
    updatedItems[index] = updatedItems[index].copyWith(quantity: quantity);

    _cart = Cart(
      items: updatedItems,
      updatedDate: DateTime.now(),
    );

    return _cart;
  }

  @override
  Future<Cart> removeFromCart({
    required int productId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    List<CartItem> updatedItems =
        _cart.items.where((item) => item.productId != productId).toList();

    _cart = Cart(
      items: updatedItems,
      updatedDate: DateTime.now(),
    );

    return _cart;
  }

  @override
  Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cart = Cart.empty();
  }

  @override
  Future<int> getCartItemCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _cart.totalQuantity;
  }
}
