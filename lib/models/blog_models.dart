// lib/models/blog_models.dart

/// Blog post model matching backend PostDto
class BlogPost {
  final int postId;
  final String title;
  final String slug;
  final String content;
  final bool published;
  final DateTime? publishedDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final int viewCount;
  final List<BlogImage> images;

  BlogPost({
    required this.postId,
    required this.title,
    required this.slug,
    required this.content,
    this.published = false,
    this.publishedDate,
    this.createdDate,
    this.updatedDate,
    this.viewCount = 0,
    this.images = const [],
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
        postId: json['postId'] ?? 0,
        title: json['title'] ?? '',
        slug: json['slug'] ?? '',
        content: json['content'] ?? '',
        published: json['published'] ?? false,
        publishedDate: json['publishedDate'] != null
            ? DateTime.parse(json['publishedDate'])
            : null,
        createdDate: json['createdDate'] != null
            ? DateTime.parse(json['createdDate'])
            : null,
        updatedDate: json['updatedDate'] != null
            ? DateTime.parse(json['updatedDate'])
            : null,
        viewCount: json['viewCount'] ?? 0,
        images: (json['images'] as List<dynamic>?)
                ?.map((e) => BlogImage.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        if (postId > 0) 'postId': postId,
        'title': title,
        'content': content,
        if (slug.isNotEmpty) 'slug': slug,
        'published': published,
        if (images.isNotEmpty) 'images': images.map((i) => i.toJson()).toList(),
      };

  /// Get excerpt from content (first 150 chars, stripped of HTML)
  String get excerpt {
    final stripped = content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
    if (stripped.length <= 150) return stripped;
    return '${stripped.substring(0, 150)}...';
  }

  /// Format date for display
  String get formattedDate {
    final date = publishedDate ?? createdDate;
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Blog image reference matching backend ImageDto
class BlogImage {
  final int imageId;
  final String? caption;
  final int displayOrder;

  BlogImage({
    required this.imageId,
    this.caption,
    this.displayOrder = 0,
  });

  factory BlogImage.fromJson(Map<String, dynamic> json) => BlogImage(
        imageId: json['imageId'] ?? 0,
        caption: json['caption'],
        displayOrder: json['displayOrder'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        if (caption != null) 'caption': caption,
        'displayOrder': displayOrder,
      };
}

/// Request to create/update blog post
class BlogPostRequest {
  final String title;
  final String content;
  final String? slug;
  final bool published;
  final List<BlogImage>? images;

  BlogPostRequest({
    required this.title,
    required this.content,
    this.slug,
    this.published = false,
    this.images,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        if (slug != null) 'slug': slug,
        'published': published,
        if (images != null) 'images': images!.map((i) => i.toJson()).toList(),
      };
}
