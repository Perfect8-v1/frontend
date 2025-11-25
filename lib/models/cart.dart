class CartItem {
  final int cartItemId;
  final int productId;
  final String productName;
  final double price;
  int quantity;
  
  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });
  
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    cartItemId: json['cartItemId'],
    productId: json['productId'],
    productName: json['productName'],
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'],
  );
  
  double get total => price * quantity;
}

class Cart {
  final int cartId;
  final List<CartItem> items;
  
  Cart({
    required this.cartId,
    required this.items,
  });
  
  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    cartId: json['cartId'],
    items: (json['items'] as List)
        .map((item) => CartItem.fromJson(item))
        .toList(),
  );
  
  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);
  
  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);
}