/// Maps `StoreCheckoutSettingResource` from
/// `GET /v1/mall/store/{id}/storeCheckoutSetting`. Drives merchant-level
/// checkout behaviours that the cart/checkout UI may want to gate on.
class StoreCheckoutSetting {
  const StoreCheckoutSetting({
    required this.enableCustomMode,
    required this.enableMergeCheckout,
    required this.enableMemberAbandon,
    required this.deductStockOnCheckout,
    this.checkoutLimit,
  });

  /// 客人可自行決定要結帳的商品。
  final bool enableCustomMode;

  /// 不同購物車是否可以合併結帳。
  final bool enableMergeCheckout;

  /// 客人可自行將購物車中的標單商品移除。
  final bool enableMemberAbandon;

  /// 結帳當下扣庫存（true）vs 得標當下扣庫存（false）。
  final bool deductStockOnCheckout;

  /// 從加入購物車到完成結帳的時間限制（分鐘）。`null` 表示無限制。
  final int? checkoutLimit;

  factory StoreCheckoutSetting.fromJson(Map<String, dynamic> json) =>
      StoreCheckoutSetting(
        enableCustomMode: json['enable_custom_mode'] as bool? ?? false,
        enableMergeCheckout:
            json['enable_merge_checkout'] as bool? ?? false,
        enableMemberAbandon:
            json['enable_member_abandon'] as bool? ?? false,
        deductStockOnCheckout:
            json['deduct_stock_on_checkout'] as bool? ?? false,
        checkoutLimit: (json['checkout_limit'] as num?)?.toInt(),
      );
}
