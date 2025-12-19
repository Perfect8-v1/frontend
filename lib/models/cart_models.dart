// lib/models/cart_models.dart

class Cart {
  final int? cartId;
  final int? customerId;
  final List<CartItem> items;
  final int itemCount;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final String currency;
  final DateTime? updatedDate;

  Cart({
    this.cartId,
    this.customerId,
    this.items = const [],
    required this.itemCount,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    this.currency = 'SEK',
    this.updatedDate,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    cartId: json['cartId'],
    customerId: json['customerId'],
    items: (json['items'] as List<dynamic>?)
        ?.map((e) => CartItem.fromJson(e))
        .toList() ?? [],
    itemCount: json['itemCount'] ?? 0,
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    shipping: (json['shipping'] as num?)?.toDouble() ?? 0,
    tax: (json['tax'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    currency: json['currency'] ?? 'SEK',
    updatedDate: json['updatedDate'] != null 
        ? DateTime.parse(json['updatedDate']) 
        : null,
  );

  bool get isEmpty => items.isEmpty;
}

class CartItem {
  final int cartItemId;
  final int productId;
  final String productName;
  final int? variantId;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? thumbnailUrl;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.variantId,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.thumbnailUrl,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    cartItemId: json['cartItemId'],
    productId: json['productId'],
    productName: json['productName'],
    variantId: json['variantId'],
    variantName: json['variantName'],
    quantity: json['quantity'],
    unitPrice: (json['unitPrice'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
    thumbnailUrl: json['thumbnailUrl'],
  );
}

class AddToCartRequest {
  final int productId;
  final int? variantId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.variantId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    if (variantId != null) 'variantId': variantId,
    'quantity': quantity,
  };
}
