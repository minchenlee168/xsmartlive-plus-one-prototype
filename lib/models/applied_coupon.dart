/// Maps `AppliedCouponResource` returned by
/// `POST /v1/mall/store/{storeId}/cart/checkout/coupon/apply`.
///
/// The response describes a single coupon that the server has registered
/// against the current cart selection. `discount` is the actual amount that
/// will be deducted at checkout-preview / checkout-confirm time.
class AppliedCoupon {
  const AppliedCoupon({
    required this.memberCouponId,
    required this.couponId,
    this.name,
    this.description,
    this.discountAmount,
    this.discountPercent,
    this.minOrderAmount,
    this.usableEndTime,
    this.code,
    required this.discount,
    required this.eligible,
    this.reason,
    this.scopes = const [],
  });

  final int memberCouponId;
  final int couponId;
  final String? name;
  final String? description;
  final int? discountAmount;
  final int? discountPercent;
  final int? minOrderAmount;
  final String? usableEndTime;
  final String? code;
  final int discount;
  final bool eligible;
  final String? reason;
  final List<dynamic> scopes;

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) => AppliedCoupon(
        memberCouponId: (json['member_coupon_id'] as num).toInt(),
        couponId: (json['coupon_id'] as num).toInt(),
        name: json['name'] as String?,
        description: json['description'] as String?,
        discountAmount: (json['discount_amount'] as num?)?.toInt(),
        discountPercent: (json['discount_percent'] as num?)?.toInt(),
        minOrderAmount: (json['min_order_amount'] as num?)?.toInt(),
        usableEndTime: json['usable_end_time'] as String?,
        code: json['code'] as String?,
        discount: (json['discount'] as num?)?.toInt() ?? 0,
        eligible: json['eligible'] as bool? ?? false,
        reason: json['reason'] as String?,
        scopes: (json['scopes'] as List<dynamic>?) ?? const [],
      );
}
