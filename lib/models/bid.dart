import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid.freezed.dart';
part 'bid.g.dart';

@freezed
abstract class Bid with _$Bid {
  const factory Bid({
    required int id,
    required int storeId,
    required int memberId,
    required int marketId,
    required int productCardId,
    required int productId,
    required String productName,
    required int productVariantId,
    required int quantity,
    required int unitPrice,
    required int totalAmount,
    String? remark,
    @Default(false) bool isAbandoned,
    required String createdAt,
    required String updatedAt,
  }) = _Bid;

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
}
