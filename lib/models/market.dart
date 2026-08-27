import 'package:freezed_annotation/freezed_annotation.dart';

part 'market.freezed.dart';
part 'market.g.dart';

@freezed
abstract class Market with _$Market {
  const factory Market({
    required int id,
    required int storeId,
    required int marketType,
    required String marketTypeLabel,
    String? name,
    @Default(0) int purchaseCount,
    @Default(0) int totalAmount,
    @Default(false) bool isActive,
    required String startedAt,
    required String endedAt,
    required String createdAt,
    required String updatedAt,
  }) = _Market;

  factory Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);
}
