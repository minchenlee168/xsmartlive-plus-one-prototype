// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bid _$BidFromJson(Map<String, dynamic> json) => _Bid(
  id: (json['id'] as num).toInt(),
  storeId: (json['storeId'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  marketId: (json['marketId'] as num).toInt(),
  productCardId: (json['productCardId'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  productVariantId: (json['productVariantId'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toInt(),
  totalAmount: (json['totalAmount'] as num).toInt(),
  remark: json['remark'] as String?,
  isAbandoned: json['isAbandoned'] as bool? ?? false,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$BidToJson(_Bid instance) => <String, dynamic>{
  'id': instance.id,
  'storeId': instance.storeId,
  'memberId': instance.memberId,
  'marketId': instance.marketId,
  'productCardId': instance.productCardId,
  'productId': instance.productId,
  'productName': instance.productName,
  'productVariantId': instance.productVariantId,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalAmount': instance.totalAmount,
  'remark': instance.remark,
  'isAbandoned': instance.isAbandoned,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
