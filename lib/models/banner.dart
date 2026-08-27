class StoreBanner {
  const StoreBanner({
    required this.id,
    required this.title,
    this.mark,
    this.images = const [],
  });

  final int id;
  final String title;
  final String? mark;
  final List<StoreBannerImage> images;

  String? get imageUrl => images.isNotEmpty ? images.first.url : null;

  factory StoreBanner.fromJson(Map<String, dynamic> json) {
    // 2026-05 spec rev: bannerImage was reshaped to a 1-of-1 hasOne relation
    // and the array key renamed `image` → `images` (length 0 or 1). Accept
    // either to keep working against a partially rolled-out backend.
    final imageList = (json['images'] as List<dynamic>?) ??
        (json['image'] as List<dynamic>?) ??
        const [];
    return StoreBanner(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      mark: json['mark'] as String?,
      images: imageList
          .map((e) => StoreBannerImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StoreBannerImage {
  const StoreBannerImage({required this.url});
  final String url;

  factory StoreBannerImage.fromJson(Map<String, dynamic> json) =>
      StoreBannerImage(url: json['url'] as String? ?? '');
}
