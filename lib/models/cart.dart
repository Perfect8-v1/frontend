// lib/models/cart.dart

import 'cart_item.dart';

class Cart {
  final int? cartId;
  final int? customerId;
  final List<CartItem> items;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Cart({
    this.cartId,
    this.customerId,
    required this.items,
    this.createdDate,
    this.updatedDate,
  });

  /// Antal unika produkter
  int get itemCount => items.length;

  /// Totalt antal produkter (med kvantitet)
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Totalsumma
  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Är vagnen tom?
  bool get isEmpty => items.isEmpty;

  /// Från JSON (backend-svar)
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'] as int?,
      customerId: json['customerId'] as int?,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'] as String)
          : null,
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'] as String)
          : null,
    );
  }

  /// Till JSON
  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'createdDate': createdDate?.toIso8601String(),
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }

  /// Tom vagn
  factory Cart.empty() {
    return Cart(items: []);
  }
}
