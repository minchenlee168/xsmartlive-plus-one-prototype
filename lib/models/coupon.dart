import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon.freezed.dart';
part 'coupon.g.dart';

@freezed
abstract class Coupon with _$Coupon {
  const factory Coupon({
    required int id,
    required String name,
    required int enable,
    required int discountType,
    int? totalQuota,
    String? usableEndTime,
    required String status,
    // 2026-05 spec rev: CouponResource now exposes concrete discount /
    // min-order numbers alongside the existing scope list. All optional
    // so the codegen JSON adapter copes with legacy responses.
    double? discountAmount,
    double? discountPercent,
    double? minOrderAmount,
    String? code,
    @Default(<dynamic>[]) List<dynamic> scopes,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);
}
