import 'package:freezed_annotation/freezed_annotation.dart';

part 'bonus.freezed.dart';
part 'bonus.g.dart';

@freezed
abstract class BonusBalance with _$BonusBalance {
  const factory BonusBalance({
    required int pointBalance,
    required String updatedAt,
    required String expiringPoints,
    required String expiringAt,
  }) = _BonusBalance;

  factory BonusBalance.fromJson(Map<String, dynamic> json) =>
      _$BonusBalanceFromJson(json);
}

@freezed
abstract class BonusUsage with _$BonusUsage {
  const factory BonusUsage({
    required int id,
    required int memberId,
    required int purchaseId,
    required int pointUsed,
    required double convertedAmount,
    String? note,
    required String createdAt,
  }) = _BonusUsage;

  factory BonusUsage.fromJson(Map<String, dynamic> json) =>
      _$BonusUsageFromJson(json);
}

/// 2026-05 spec: BonusHistoryResource — merged earning + usage feed.
///   • `type`         : "earning" or "usage" (drives sign of point_amount)
///   • `point_amount` : positive for earning, negative for usage
///   • `created_at`   : ISO 8601 — list is sorted desc by this column
///
/// Kept plain (no Freezed) because the response is loose and we render it
/// as-is without further transformation.
class BonusHistory {
  const BonusHistory({
    required this.id,
    required this.type,
    required this.pointAmount,
    required this.createdAt,
    this.note,
    this.purchaseId,
  });

  final int id;

  /// `"earning"` or `"usage"`.
  final String type;

  /// Signed point delta: positive for earning, negative for usage.
  final int pointAmount;
  final String createdAt;
  final String? note;
  final int? purchaseId;

  bool get isEarning => type == 'earning';
  bool get isUsage => type == 'usage';

  factory BonusHistory.fromJson(Map<String, dynamic> json) => BonusHistory(
        id: (json['id'] as num?)?.toInt() ?? 0,
        type: json['type'] as String? ?? 'earning',
        pointAmount: (json['point_amount'] as num?)?.toInt() ?? 0,
        createdAt: json['created_at'] as String? ?? '',
        note: json['note'] as String?,
        purchaseId: (json['purchase_id'] as num?)?.toInt(),
      );
}
