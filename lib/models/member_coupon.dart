/// 2026-05 spec rev: backend dropped `expires_at` in favour of
/// `usable_end_time`, renamed `scope` (string) → `scopes` (List), and
/// surfaces `coupon_id` / `min_order_amount` directly on the member-coupon
/// row. Reader tolerates both legacy and new payload shapes so a partially
/// rolled-out backend cannot blank out coupon cards.
class MemberCoupon {
  const MemberCoupon({
    required this.id,
    this.couponId,
    required this.name,
    this.description,
    this.discountAmount,
    this.discountPercent,
    this.minOrderAmount,
    this.code,
    required this.status,
    this.usableEndTime,
    required this.used,
    this.usedAt,
    this.claimedAt,
    this.scopes = const [],
  });

  final int id;
  final int? couponId;
  final String name;
  final String? description;
  final String? discountAmount;
  final String? discountPercent;
  final String? minOrderAmount;
  final String? code;
  final String status;

  /// ISO 8601 expiry time. Preferred key per 2026-05 spec.
  final String? usableEndTime;

  /// Legacy alias for [usableEndTime] so existing screen code keeps
  /// compiling. Reads the new key; falls back to the legacy `expires_at`
  /// when a stale backend still returns it.
  String? get expiresAt => usableEndTime;

  final bool used;
  final String? usedAt;
  final String? claimedAt;

  /// `scopes` from the new resource — each entry is shaped:
  /// `{target_type, target_type_label, target_id, target_name, is_inclusion}`.
  /// Kept as raw maps because the UI only ever joins the labels.
  final List<MemberCouponScope> scopes;

  factory MemberCoupon.fromJson(Map<String, dynamic> json) => MemberCoupon(
        id: (json['id'] as num?)?.toInt() ?? 0,
        couponId: (json['coupon_id'] as num?)?.toInt(),
        name: json['name']?.toString() ?? '',
        description: _stringOrNull(json['description']),
        discountAmount: _stringOrNull(json['discount_amount']),
        discountPercent: _stringOrNull(json['discount_percent']),
        minOrderAmount: _stringOrNull(json['min_order_amount']),
        code: _stringOrNull(json['code']),
        status: _stringOrNull(json['status']) ?? '',
        usableEndTime: _stringOrNull(json['usable_end_time']) ??
            _stringOrNull(json['expires_at']),
        used: _boolOrFalse(json['used']),
        usedAt: _stringOrNull(json['used_at']),
        claimedAt: _stringOrNull(json['claimed_at']),
        scopes: _parseScopes(json['scopes']),
      );
}

class MemberCouponScope {
  const MemberCouponScope({
    this.targetType,
    this.targetTypeLabel,
    this.targetId,
    this.targetName,
    required this.isInclusion,
  });

  final int? targetType;
  final String? targetTypeLabel;
  final int? targetId;
  final String? targetName;
  final bool isInclusion;

  factory MemberCouponScope.fromJson(Map<String, dynamic> json) =>
      MemberCouponScope(
        targetType: (json['target_type'] as num?)?.toInt(),
        targetTypeLabel: _stringOrNull(json['target_type_label']),
        targetId: (json['target_id'] as num?)?.toInt(),
        targetName: _stringOrNull(json['target_name']),
        isInclusion: _boolOrFalse(json['is_inclusion']),
      );
}

List<MemberCouponScope> _parseScopes(Object? raw) {
  if (raw is! List) return const [];
  final out = <MemberCouponScope>[];
  for (final item in raw) {
    if (item is! Map<String, dynamic>) continue;
    try {
      out.add(MemberCouponScope.fromJson(item));
    } catch (_) {
      // skip malformed entries instead of failing the whole coupon
    }
  }
  return out;
}

String? _stringOrNull(Object? raw) {
  if (raw == null) return null;
  if (raw is String) return raw.isEmpty ? null : raw;
  if (raw is num) return raw.toString();
  return raw.toString();
}

bool _boolOrFalse(Object? raw) {
  if (raw is bool) return raw;
  if (raw is num) return raw != 0;
  if (raw is String) {
    final v = raw.toLowerCase();
    return v == 'true' || v == '1';
  }
  return false;
}
