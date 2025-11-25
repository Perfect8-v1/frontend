class BlogPost {
  final int postId;
  final String title;
  final String content;
  final String slug;
  final DateTime publishedDate;
  final int viewCount;
  final String authorName;
  
  BlogPost({
    required this.postId,
    required this.title,
    required this.content,
    required this.slug,
    required this.publishedDate,
    required this.viewCount,
    required this.authorName,
  });
  
  factory BlogPost.fromJson(Map<String, dynamic> json) => BlogPost(
    postId: json['postId'],
    title: json['title'],
    content: json['content'],
    slug: json['slug'],
    publishedDate: DateTime.parse(json['publishedDate']),
    viewCount: json['viewCount'] ?? 0,
    authorName: json['authorName'] ?? 'Unknown',
  );
  
  String get formattedDate {
    return '${publishedDate.year}-${publishedDate.month.toString().padLeft(2, '0')}-${publishedDate.day.toString().padLeft(2, '0')}';
  }
}