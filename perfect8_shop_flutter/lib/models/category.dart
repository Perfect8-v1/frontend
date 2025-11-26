// lib/models/category.dart
class Category {
  final int id;
  final String name;
  final int? parentId;
  final bool active;
  final List<String>? imageUrls; // New field
  final String? textUrl; // New field

  Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.active,
    this.imageUrls,
    this.textUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parentId'] as int?,
      active: json['active'] as bool? ?? true,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>(),
      textUrl: json['textUrl'] as String?,
    );
  }
}