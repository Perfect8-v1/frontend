// lib/models/product_models.dart

/// Product model matching backend ProductResponse
class Product {
  final int productId;
  final String name;
  final String? description;
  final String? sku;
  final double price;
  final double? discountPrice;
  final String? brand;
  final String? imageUrl;
  final List<String> galleryImages;
  final int stockQuantity;
  final bool featured;
  final bool active;
  final String? category;
  final int? categoryId;
  final double? weight;
  final String? dimensions;
  final List<String> tags;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  Product({
    required this.productId,
    required this.name,
    this.description,
    this.sku,
    required this.price,
    this.discountPrice,
    this.brand,
    this.imageUrl,
    this.galleryImages = const [],
    required this.stockQuantity,
    this.featured = false,
    this.active = true,
    this.category,
    this.categoryId,
    this.weight,
    this.dimensions,
    this.tags = const [],
    this.createdDate,
    this.updatedDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productId: json['productId'],
    name: json['name'] ?? '',
    description: json['description'],
    sku: json['sku'],
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    discountPrice: json['discountPrice'] != null
        ? (json['discountPrice'] as num).toDouble()
        : null,
    brand: json['brand'],
    imageUrl: json['imageUrl'],
    galleryImages: (json['galleryImages'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [],
    stockQuantity: json['stockQuantity'] ?? 0,
    featured: json['featured'] ?? false,
    active: json['active'] ?? true,
    category: json['category'] ?? json['categoryName'],
    categoryId: json['categoryId'],
    weight: json['weight'] != null
        ? (json['weight'] as num).toDouble()
        : null,
    dimensions: json['dimensions'],
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [],
    createdDate: json['createdDate'] != null
        ? DateTime.parse(json['createdDate'])
        : null,
    updatedDate: json['updatedDate'] != null
        ? DateTime.parse(json['updatedDate'])
        : null,
  );

  /// Check if product has a discount
  bool get hasDiscount =>
      discountPrice != null &&
      discountPrice! > 0 &&
      discountPrice! < price;

  /// Get discount percentage
  double get discountPercentage => hasDiscount
      ? ((price - discountPrice!) / price * 100)
      : 0;

  /// Get effective price (discount or regular)
  double get effectivePrice => hasDiscount ? discountPrice! : price;

  /// Check if product is in stock
  bool get inStock => stockQuantity > 0;

  /// Get availability text
  String get availability {
    if (stockQuantity <= 0) return 'Slut i lager';
    if (stockQuantity <= 5) return 'Få kvar';
    return 'I lager';
  }
}

/// Category model
class Category {
  final int categoryId;
  final String name;
  final String? description;
  final String? slug;
  final int? parentId;
  final int productCount;
  final String? imageUrl;

  Category({
    required this.categoryId,
    required this.name,
    this.description,
    this.slug,
    this.parentId,
    this.productCount = 0,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categoryId: json['categoryId'],
    name: json['name'] ?? '',
    description: json['description'],
    slug: json['slug'],
    parentId: json['parentId'],
    productCount: json['productCount'] ?? 0,
    imageUrl: json['imageUrl'],
  );
}
