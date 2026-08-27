// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coupon _$CouponFromJson(Map<String, dynamic> json) => _Coupon(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  enable: (json['enable'] as num).toInt(),
  discountType: (json['discountType'] as num).toInt(),
  totalQuota: (json['totalQuota'] as num?)?.toInt(),
  usableEndTime: json['usableEndTime'] as String?,
  status: json['status'] as String,
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  discountPercent: (json['discountPercent'] as num?)?.toDouble(),
  minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
  code: json['code'] as String?,
  scopes: json['scopes'] as List<dynamic>? ?? const <dynamic>[],
);

Map<String, dynamic> _$CouponToJson(_Coupon instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'enable': instance.enable,
  'discountType': instance.discountType,
  'totalQuota': instance.totalQuota,
  'usableEndTime': instance.usableEndTime,
  'status': instance.status,
  'discountAmount': instance.discountAmount,
  'discountPercent': instance.discountPercent,
  'minOrderAmount': instance.minOrderAmount,
  'code': instance.code,
  'scopes': instance.scopes,
};
