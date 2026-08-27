import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase.freezed.dart';
part 'purchase.g.dart';

/// Order list row — maps `PurchaseIndexResource`.
@freezed
abstract class Purchase with _$Purchase {
  const factory Purchase({
    required int id,
    required String createdAt,
    required int itemCount,
    required num amount,
    String? paymentMethod,
    String? shippingMethod,
    String? mallType,
    String? status,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}

@freezed
abstract class PurchaseCollection with _$PurchaseCollection {
  const factory PurchaseCollection({
    required List<Purchase> data,
    PurchasePagination? meta,
  }) = _PurchaseCollection;

  factory PurchaseCollection.fromJson(Map<String, dynamic> json) =>
      _$PurchaseCollectionFromJson(json);
}

@freezed
abstract class PurchasePagination with _$PurchasePagination {
  const factory PurchasePagination({
    required String currentPage,
    required String pageSize,
    required String totalPages,
    required String totalNumber,
  }) = _PurchasePagination;

  factory PurchasePagination.fromJson(Map<String, dynamic> json) =>
      _$PurchasePaginationFromJson(json);
}

/// Order detail — maps `App.Http.Resources.Mall.Purchase.PurchaseResource`.
@freezed
abstract class PurchaseDetail with _$PurchaseDetail {
  const factory PurchaseDetail({
    required int id,
    required List<PurchaseDetailItem> items,
    PurchaseShipment? shipment,
  }) = _PurchaseDetail;

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) =>
      _$PurchaseDetailFromJson(json);
}

/// Order-level shipment block — maps the singular `fulfillment` field on
/// PurchaseResource (added in 2026-05). Mirrors the new top-level checkout
/// model: a `delivery_type` (`home`/`pickup`) drives which recipient
/// fields are populated, and `shipping_method` / `shipping_method_name`
/// are filled in once the merchant calls createShipment server-side.
@freezed
abstract class PurchaseShipment with _$PurchaseShipment {
  const factory PurchaseShipment({
    String? deliveryType,
    String? pickupProvider,
    int? shippingMethodId,
    String? shippingMethodName,
    String? recipientName,
    String? recipientPhone,
    String? recipientAddress,
    String? convenienceStoreCode,
    String? trackingNo,
    String? trackingUrl,
  }) = _PurchaseShipment;

  factory PurchaseShipment.fromJson(Map<String, dynamic> json) =>
      _$PurchaseShipmentFromJson(json);
}

@freezed
abstract class PurchaseDetailItem with _$PurchaseDetailItem {
  const factory PurchaseDetailItem({
    required int id,
    String? productName,
    String? variantName,
    String? imageUrl,
    num? unitPrice,
    required int quantity,
    required List<PurchaseFulfillment> fulfillments,
  }) = _PurchaseDetailItem;

  factory PurchaseDetailItem.fromJson(Map<String, dynamic> json) =>
      _$PurchaseDetailItemFromJson(json);
}

/// Per-package fulfillment snapshot used by the timeline.
///
/// Maps the `items[].fulfillments[]` entry from `PurchaseResource`
/// (id / status / status_label / item_quantity). Optional timestamp
/// fields (`paidAt` / `shippedAt` / `deliveredAt` / `completedAt`)
/// are populated when backend provides them; otherwise the timeline
/// falls back to the order-level `createdAt` for the 待付款 node.
@freezed
abstract class PurchaseFulfillment with _$PurchaseFulfillment {
  const factory PurchaseFulfillment({
    required int id,
    required int status,
    required String statusLabel,
    required String itemQuantity,
    String? paidAt,
    String? shippedAt,
    String? deliveredAt,
    String? completedAt,
  }) = _PurchaseFulfillment;

  factory PurchaseFulfillment.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFulfillmentFromJson(json);
}
