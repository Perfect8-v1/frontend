// lib/repositories/cart_repository.dart

import '../models/cart.dart';

/// Kontraktet för Cart-operationer.
/// Både MockCrtRepository och ApiCartRepository implementerar detta.
abstract class CartRepository {
  /// Hämta kundvagnen
  Future<Cart> getCart();

  /// Lägg till produkt i vagnen
  Future<Cart> addToCart({required int productId, required int quantity});

  /// Uppdatera kvantitet för en produkt
  Future<Cart> updateQuantity({required int productId, required int quantity});

  /// Ta bort produkt från vagnen
  Future<Cart> removeFromCart({required int productId});

  /// Rensa hela vagnen
  Future<void> clearCart();

  /// Hämta antal produkter i vagnen
  Future<int> getCartItemCount();
}
