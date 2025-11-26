class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String imageUrl;
  final bool active;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    required this.active,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        categoryId: json['categoryId'] as int,
        imageUrl: json['imageUrl'] as String? ?? '',
        active: json['active'] as bool? ?? true,
      );
}
