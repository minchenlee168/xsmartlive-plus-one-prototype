class SearchKeyword {
  const SearchKeyword({
    required this.id,
    this.keyword = '',
    this.name = '',
  });

  final int id;
  final String keyword;
  final String name;

  String get displayText => keyword.isNotEmpty ? keyword : name;

  factory SearchKeyword.fromJson(Map<String, dynamic> json) => SearchKeyword(
        id: json['id'] as int? ?? 0,
        keyword: json['keyword'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}
