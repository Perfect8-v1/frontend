// lib/models/cart_item.dart

class CartItem {
  final int productId;
  final String productName;
  final String? imageUrl;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
  });

  /// Totalpris för denna rad
  double get totalPrice => unitPrice * quantity;

  /// Från JSON (backend-svar)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      imageUrl: json['imageUrl'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  /// Till JSON (skicka till backend)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }

  /// Kopiera med ändringar
  CartItem copyWith({
    int? productId,
    String? productName,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
