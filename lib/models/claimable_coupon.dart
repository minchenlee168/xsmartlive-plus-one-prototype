class ClaimableCoupon {
  const ClaimableCoupon({
    required this.id,
    required this.name,
    this.description,
    required this.enable,
    required this.discountType,
    this.discountAmount,
    this.discountPercent,
    this.totalQuota,
    this.expiresAt,
    required this.status,
    this.scope,
  });

  final int id;
  final String name;
  final String? description;
  final int enable;
  final int discountType;
  final String? discountAmount;
  final String? discountPercent;
  final int? totalQuota;
  final String? expiresAt;
  final String status;

  /// 適用範圍 — pre-formatted label from backend, e.g.
  /// "適用範圍：全站" or "適用範圍（直播場次）：我是直播場次-2025-12-24".
  final String? scope;

  factory ClaimableCoupon.fromJson(Map<String, dynamic> json) =>
      ClaimableCoupon(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        enable: (json['enable'] as num?)?.toInt() ?? 1,
        discountType: (json['discount_type'] as num?)?.toInt() ?? 1,
        discountAmount: json['discount_amount']?.toString(),
        discountPercent: json['discount_percent']?.toString(),
        totalQuota: (json['total_quota'] as num?)?.toInt(),
        expiresAt:
            json['expires_at'] as String? ?? json['usable_end_time'] as String?,
        status: json['status']?.toString() ?? '',
        scope: _parseScope(json['scope']),
      );

  /// Tolerant parser — backend returns `scope` as either a legacy string or
  /// the current `[{range, name}]` list. Empty/unknown shapes return null.
  static String? _parseScope(Object? raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    if (raw is List) {
      final parts = <String>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final range = item['range']?.toString() ?? '';
        final name = item['name']?.toString();
        if (range.isEmpty && (name == null || name.isEmpty)) continue;
        if (name == null || name.isEmpty) {
          parts.add(range);
        } else {
          parts.add('（$range）：$name');
        }
      }
      if (parts.isEmpty) return null;
      final joined = parts.join('、');
      return joined.startsWith('（') ? '適用範圍$joined' : '適用範圍：$joined';
    }
    return null;
  }

  String get discountLabel {
    final amount = _positive(discountAmount);
    if (amount != null) return '折${_fmt(amount)}元';
    final percent = _positive(discountPercent);
    if (percent != null) return '折${_fmt(percent)}%';
    // Fallback by discount_type when concrete values are unavailable.
    switch (discountType) {
      case 3:
      case 4:
        return '折%';
      default:
        return '折元';
    }
  }

  static double? _positive(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final v = double.tryParse(raw);
    return (v != null && v > 0) ? v : null;
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}
