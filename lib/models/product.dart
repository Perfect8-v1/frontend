class Product {
  final int productId;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final bool isActive;
  
  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    required this.isActive,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json['productId'],
    name: json['name'],
    description: json['description'] ?? '',
    price: (json['price'] as num).toDouble(),
    stockQuantity: json['stockQuantity'],
    imageUrl: json['imageUrl'],
    isActive: json['active'] ?? true,
  );
  
  bool get inStock => stockQuantity > 0;
  
  String get formattedPrice => '${price.toStringAsFixed(2)} SEK';
}