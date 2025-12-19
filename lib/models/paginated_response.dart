// lib/models/paginated_response.dart

class PaginatedResponse<T> {
  final List<T> content;
  final int totalPages;
  final int totalElements;
  final int pageNumber;
  final int pageSize;
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.content,
    required this.totalPages,
    required this.totalElements,
    required this.pageNumber,
    required this.pageSize,
    required this.first,
    required this.last,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return PaginatedResponse(
      content: (json['content'] as List<dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      pageNumber: json['pageable']?['pageNumber'] ?? json['number'] ?? 0,
      pageSize: json['pageable']?['pageSize'] ?? json['size'] ?? 20,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }

  bool get hasMore => !last;
}