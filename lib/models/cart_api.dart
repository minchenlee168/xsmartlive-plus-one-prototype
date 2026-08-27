import 'package:freezed_annotation/freezed_annotation.dart';

part 'cart_api.freezed.dart';
part 'cart_api.g.dart';

Object? _readProduct(Map json, String _) {
  return json['product'] ?? json['product_card'];
}

@freezed
abstract class CartApi with _$CartApi {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CartApi({
    required int id,
    required int skuCount,
    required double subtotal,
    required double discount,
    required double total,
    @Default([]) List<CartApiItem> items,
    /// `false` when the merchant disables 棄標 (member abandon). When
    /// false, the UI must hide the per-item delete affordance — the
    /// destroy endpoint will return `20313: 無法移除購物車項目` if called.
    @Default(true) bool canAbandon,
    required String createdAt,
    required String updatedAt,
  }) = _CartApi;

  factory CartApi.fromJson(Map<String, dynamic> json) =>
      _$CartApiFromJson(json);
}

@freezed
abstract class CartApiItem with _$CartApiItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CartApiItem({
    required int id,
    required int cartId,
    int? bidId,
    int? productId,
    int? productVariantId,
    required int quantity,
    required int unitPrice,
    String? image,
    @JsonKey(readValue: _readProduct)
    required CartApiProduct product,
    required String createdAt,
    required String updatedAt,
  }) = _CartApiItem;

  factory CartApiItem.fromJson(Map<String, dynamic> json) =>
      _$CartApiItemFromJson(json);
}

@freezed
abstract class CartApiProduct with _$CartApiProduct {
  const factory CartApiProduct({
    int? id,
    String? name,
  }) = _CartApiProduct;

  factory CartApiProduct.fromJson(Map<String, dynamic> json) =>
      _$CartApiProductFromJson(json);
}
