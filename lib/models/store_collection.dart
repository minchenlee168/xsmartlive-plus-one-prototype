// 主題館 (Store Collection) — B8.
//
// API_DOCUMENT.json declares the list/show responses as `array of items: []`
// without a strict schema, so this model is intentionally lenient and reads
// only the fields documented in `StoreCollectionStoreRequest` plus common
// image / item arrays merchants tend to attach.

class StoreCollection {
  const StoreCollection({
    required this.id,
    required this.name,
    this.remark,
    this.type,
    this.displayMode,
    this.isPinned = false,
    this.imageUrl,
    this.startTime,
    this.endTime,
    this.itemCount,
  });

  final int id;
  final String name;
  final String? remark;

  /// 1=標準, 2=輪播, 3=限時搶購
  final int? type;

  /// 1=標準, 2=精簡
  final int? displayMode;

  final bool isPinned;
  final String? imageUrl;
  final String? startTime;
  final String? endTime;
  final int? itemCount;

  String get typeLabel => switch (type) {
        1 => '標準',
        2 => '輪播',
        3 => '限時搶購',
        _ => '',
      };

  factory StoreCollection.fromJson(Map<String, dynamic> json) {
    int? toIntOrNull(dynamic v) =>
        v == null ? null : int.tryParse(v.toString());

    final image = json['image'];
    String? resolvedImageUrl;
    if (image is Map<String, dynamic>) {
      resolvedImageUrl = image['url'] as String?;
    } else if (image is List && image.isNotEmpty) {
      final first = image.first;
      if (first is Map<String, dynamic>) {
        resolvedImageUrl = first['url'] as String?;
      } else if (first is String) {
        resolvedImageUrl = first;
      }
    } else if (image is String) {
      resolvedImageUrl = image;
    }
    resolvedImageUrl ??= json['image_url'] as String? ??
        json['cover_image_url'] as String?;

    final items = json['items'] as List<dynamic>? ??
        json['products'] as List<dynamic>? ??
        json['product_cards'] as List<dynamic>?;

    return StoreCollection(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      remark: json['remark'] as String?,
      type: toIntOrNull(json['type']),
      displayMode: toIntOrNull(json['display_mode']),
      isPinned: json['is_pinned'] as bool? ?? false,
      imageUrl: (resolvedImageUrl?.isEmpty ?? true) ? null : resolvedImageUrl,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      itemCount: items?.length,
    );
  }
}
