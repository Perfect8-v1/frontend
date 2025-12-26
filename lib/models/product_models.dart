// lib/models/product_models.dart
import '../services/api_config.dart';

/// Helper to convert image URLs to proper HTTPS URLs via nginx
///
/// Handles both:
/// - Relative URLs: /images/original/... → https://p8.rantila.com/images/original/...
/// - Legacy absolute URLs: http://p8.rantila.com:8084/images/... → https://p8.rantila.com/images/...
String? _toFullImageUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  // If URL contains :8084 (direct port access), strip it and use nginx path
  if (url.contains(':8084')) {
    // Extract path after port: http://p8.rantila.com:8084/images/... → /images/...
    final portIndex = url.indexOf(':8084');
    final pathStart = url.indexOf('/', portIndex + 5); // +5 for ":8084"
    if (pathStart != -1) {
      url = url.substring(pathStart); // Now it's a relative URL
    }
  }

  // Already correct HTTPS URL without port
  if (url.startsWith('https://')) return url;

  // HTTP URL - convert to HTTPS
  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }

  // Relative URL - prepend base URL
  return '${ApiConfig.imageUrl}$url';
}

/// Product model matching backend ProductResponse
class Product {
  // Core identifiers
  final int productId;
  final String name;
  final String? description;
  final String? sku;

  // Pricing
  final double price;
  final double? discountPrice;

  // Product details
  final String? brand;
  final String? manufacturer;
  final String? model;
  final String? barcode;
  final String? color;
  final String? size;
  final String? material;

  // Stock management
  final int stockQuantity;
  final int? lowStockThreshold;
  final int? reorderPoint;
  final int? reorderQuantity;

  // Physical properties
  final double? weight;
  final String? dimensions;

  // Media
  final String? imageUrl;
  final List<String> galleryImages;

  // Categorization
  final String? category;
  final int? categoryId;
  final List<String> tags;
  final List<int> relatedProductIds;

  // SEO
  final String? metaTitle;
  final String? metaDescription;
  final String? metaKeywords;

  // Status
  final bool featured;
  final bool active;

  // Analytics (read-only)
  final int views;
  final int salesCount;
  final double rating;
  final int reviewCount;

  // Timestamps
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
    this.manufacturer,
    this.model,
    this.barcode,
    this.color,
    this.size,
    this.material,
    required this.stockQuantity,
    this.lowStockThreshold,
    this.reorderPoint,
    this.reorderQuantity,
    this.weight,
    this.dimensions,
    this.imageUrl,
    this.galleryImages = const [],
    this.category,
    this.categoryId,
    this.tags = const [],
    this.relatedProductIds = const [],
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.featured = false,
    this.active = true,
    this.views = 0,
    this.salesCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
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
    manufacturer: json['manufacturer'],
    model: json['model'],
    barcode: json['barcode'],
    color: json['color'],
    size: json['size'],
    material: json['material'],
    stockQuantity: json['stockQuantity'] ?? 0,
    lowStockThreshold: json['lowStockThreshold'],
    reorderPoint: json['reorderPoint'],
    reorderQuantity: json['reorderQuantity'],
    weight: json['weight'] != null
        ? (json['weight'] as num).toDouble()
        : null,
    dimensions: json['dimensions'],
    imageUrl: _toFullImageUrl(json['imageUrl']),
    galleryImages: (json['galleryImages'] as List<dynamic>?)
        ?.map((e) => _toFullImageUrl(e.toString()))
        .where((e) => e != null)
        .cast<String>()
        .toList() ?? [],
    category: json['category'] ?? json['categoryName'],
    categoryId: json['categoryId'],
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [],
    relatedProductIds: (json['relatedProductIds'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList() ?? [],
    metaTitle: json['metaTitle'],
    metaDescription: json['metaDescription'],
    metaKeywords: json['metaKeywords'],
    featured: json['featured'] ?? false,
    active: json['active'] ?? true,
    views: json['views'] ?? 0,
    salesCount: json['salesCount'] ?? 0,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: json['reviewCount'] ?? 0,
    createdDate: json['createdDate'] != null
        ? DateTime.parse(json['createdDate'])
        : null,
    updatedDate: json['updatedDate'] != null
        ? DateTime.parse(json['updatedDate'])
        : null,
  );

  /// Convert to JSON for API requests (create/update)
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'sku': sku,
    'price': price,
    'discountPrice': discountPrice,
    'brand': brand,
    'manufacturer': manufacturer,
    'model': model,
    'barcode': barcode,
    'color': color,
    'size': size,
    'material': material,
    'stockQuantity': stockQuantity,
    'lowStockThreshold': lowStockThreshold,
    'reorderPoint': reorderPoint,
    'reorderQuantity': reorderQuantity,
    'weight': weight,
    'dimensions': dimensions,
    'imageUrl': imageUrl,
    'galleryImages': galleryImages,
    'categoryId': categoryId,
    'tags': tags,
    'relatedProductIds': relatedProductIds,
    'metaTitle': metaTitle,
    'metaDescription': metaDescription,
    'metaKeywords': metaKeywords,
    'featured': featured,
    'active': active,
  };

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

  /// Get image URL for specific size
  /// Sizes: thumbnail (150x150), small (400x400), medium (800x800), large (1600x1600), original
  String? getImageUrl(String size) {
    if (imageUrl == null || imageUrl!.isEmpty) return null;

    // Replace size in URL: /images/{oldSize}/ -> /images/{newSize}/
    final sizes = ['thumbnail', 'small', 'medium', 'large', 'original'];
    String result = imageUrl!;
    for (final s in sizes) {
      if (result.contains('/images/$s/')) {
        return result.replaceFirst('/images/$s/', '/images/$size/');
      }
    }
    return imageUrl; // Return as-is if pattern not found
  }

  /// Thumbnail for product list (150x150)
  String? get thumbnailImageUrl => getImageUrl('thumbnail');

  /// Small image (400x400)
  String? get smallImageUrl => getImageUrl('small');

  /// Medium image (800x800)
  String? get mediumImageUrl => getImageUrl('medium');

  /// Large image for product detail (1600x1600)
  String? get largeImageUrl => getImageUrl('large');

  /// Original full-size image
  String? get originalImageUrl => getImageUrl('original');
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
