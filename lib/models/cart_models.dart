// lib/models/cart_models.dart
import '../config/api_config.dart';

/// Helper to convert image URLs to proper HTTPS URLs via nginx
String? _toFullImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  // If URL contains :8084 (direct port access), strip it and use nginx path
  if (url.contains(':8084')) {
    final portIndex = url.indexOf(':8084');
    final pathStart = url.indexOf('/', portIndex + 5);
    if (pathStart != -1) {
      url = url.substring(pathStart);
    }
  }

  if (url.startsWith('https://')) return url;
  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }

  return '${ApiConfig.imageUrl}$url';
}

/// Cart model matching backend CartResponse
class Cart {
  final int? cartId;
  final int? customerId;
  final List<CartItem> items;
  final int itemCount;
  final int totalQuantity;
  final double totalAmount;
  final double? discountAmount;
  final double? estimatedTax;
  final double? estimatedShipping;
  final double grandTotal;
  final String? couponCode;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Cart({
    this.cartId,
    this.customerId,
    this.items = const [],
    this.itemCount = 0,
    this.totalQuantity = 0,
    this.totalAmount = 0,
    this.discountAmount,
    this.estimatedTax,
    this.estimatedShipping,
    this.grandTotal = 0,
    this.couponCode,
    this.createdDate,
    this.updatedDate,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        cartId: json['cartId'],
        customerId: json['customerId'],
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => CartItem.fromJson(e))
                .toList() ??
            [],
        itemCount: json['itemCount'] ?? 0,
        totalQuantity: json['totalQuantity'] ?? json['itemCount'] ?? 0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        estimatedTax: (json['estimatedTax'] as num?)?.toDouble(),
        estimatedShipping: (json['estimatedShipping'] as num?)?.toDouble(),
        grandTotal: (json['grandTotal'] as num?)?.toDouble() ??
            (json['totalAmount'] as num?)?.toDouble() ??
            0,
        couponCode: json['couponCode'],
        createdDate: json['createdDate'] != null
            ? DateTime.parse(json['createdDate'])
            : null,
        updatedDate: json['updatedDate'] != null
            ? DateTime.parse(json['updatedDate'])
            : null,
      );

  bool get isEmpty => items.isEmpty;

  /// Get formatted total for display
  String get formattedTotal => '${grandTotal.toStringAsFixed(0)} kr';
}

/// Cart item model matching backend CartItemResponse
class CartItem {
  final int cartItemId;
  final int productId;
  final String productName;
  final String? productSku;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final int? stockAvailable;
  final bool inStock;

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    this.productSku,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.stockAvailable,
    this.inStock = true,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        cartItemId: json['cartItemId'] ?? 0,
        productId: json['productId'] ?? 0,
        productName: json['productName'] ?? '',
        productSku: json['productSku'],
        imageUrl: _toFullImageUrl(json['imageUrl'] ?? json['thumbnailUrl']),
        quantity: json['quantity'] ?? 1,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ??
            ((json['unitPrice'] as num?)?.toDouble() ?? 0) *
                (json['quantity'] ?? 1),
        stockAvailable: json['stockAvailable'],
        inStock: json['inStock'] ?? true,
      );

  /// Get formatted price for display
  String get formattedUnitPrice => '${unitPrice.toStringAsFixed(0)} kr';
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} kr';
}

/// Request to add item to cart
class AddToCartRequest {
  final int productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
}
