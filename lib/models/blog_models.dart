// lib/models/blog_models.dart

class BlogPost {
  final int postId;
  final String title;
  final String slug;
  final String content;
  final bool published;
  final DateTime? publishedDate;
  final DateTime createdDate;
  final DateTime updatedDate;
  final int viewCount;
  final List<ImageReference> images;

  BlogPost({
    required this.postId,
    required this.title,
    required this.slug,
    required this.content,
    required this.published,
    this.publishedDate,
    required this.createdDate,
    required this.updatedDate,
    required this.viewCount,
    this.images = const [],
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
    postId: json['postId'],
    title: json['title'],
    slug: json['slug'],
    content: json['content'],
    published: json['published'] ?? false,
    publishedDate: json['publishedDate'] != null 
        ? DateTime.parse(json['publishedDate']) 
        : null,
    createdDate: DateTime.parse(json['createdDate']),
    updatedDate: DateTime.parse(json['updatedDate']),
    viewCount: json['viewCount'] ?? 0,
    images: (json['images'] as List<dynamic>?)
        ?.map((e) => ImageReference.fromJson(e))
        .toList() ?? [],
  );
}

class ImageReference {
  final int imageReferenceId;
  final int imageId;
  final String? caption;
  final int displayOrder;

  ImageReference({
    required this.imageReferenceId,
    required this.imageId,
    this.caption,
    required this.displayOrder,
  });

  factory ImageReference.fromJson(Map<String, dynamic> json) => ImageReference(
    imageReferenceId: json['imageReferenceId'],
    imageId: json['imageId'],
    caption: json['caption'],
    displayOrder: json['displayOrder'] ?? 0,
  );
}