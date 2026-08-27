class StoreMarquee {
  const StoreMarquee({
    required this.id,
    this.content = '',
    this.title = '',
  });

  final int id;
  final String content;
  final String title;

  String get displayText => content.isNotEmpty ? content : title;

  factory StoreMarquee.fromJson(Map<String, dynamic> json) => StoreMarquee(
        id: json['id'] as int? ?? 0,
        content: json['content'] as String? ?? '',
        title: json['title'] as String? ?? '',
      );
}
