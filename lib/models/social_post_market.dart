// 社團 / 粉絲團貼文賣場 — B11.
//
// Both `GroupPostMarketResource` and `FanPagePostMarketResource` share the
// same shape (id, market_type, name, is_active, started_at, ended_at,
// post.{id, post_type, provider_post_id}). One model serves both.

class SocialPostMarket {
  const SocialPostMarket({
    required this.id,
    required this.storeId,
    required this.marketType,
    required this.marketTypeLabel,
    this.name,
    this.isActive = false,
    this.startedAt,
    this.endedAt,
    this.providerPostId,
    this.postType,
  });

  final int id;
  final int storeId;
  final int marketType;
  final String marketTypeLabel;
  final String? name;
  final bool isActive;
  final String? startedAt;
  final String? endedAt;
  final String? providerPostId;
  final int? postType;

  factory SocialPostMarket.fromJson(Map<String, dynamic> json) {
    int? toIntOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    final post = json['post'];
    String? postId;
    int? postType;
    if (post is Map<String, dynamic>) {
      postId = post['provider_post_id']?.toString();
      postType = toIntOrNull(post['post_type']);
    }

    return SocialPostMarket(
      id: (json['id'] as num?)?.toInt() ?? 0,
      storeId: (json['store_id'] as num?)?.toInt() ?? 0,
      marketType: toIntOrNull(json['market_type']) ?? 0,
      marketTypeLabel: json['market_type_label'] as String? ?? '',
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      startedAt: json['started_at'] as String?,
      endedAt: json['ended_at'] as String?,
      providerPostId: postId,
      postType: postType,
    );
  }
}
