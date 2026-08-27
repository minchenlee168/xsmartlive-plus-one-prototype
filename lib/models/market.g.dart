// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Market _$MarketFromJson(Map<String, dynamic> json) => _Market(
  id: (json['id'] as num).toInt(),
  storeId: (json['storeId'] as num).toInt(),
  marketType: (json['marketType'] as num).toInt(),
  marketTypeLabel: json['marketTypeLabel'] as String,
  name: json['name'] as String?,
  purchaseCount: (json['purchaseCount'] as num?)?.toInt() ?? 0,
  totalAmount: (json['totalAmount'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? false,
  startedAt: json['startedAt'] as String,
  endedAt: json['endedAt'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$MarketToJson(_Market instance) => <String, dynamic>{
  'id': instance.id,
  'storeId': instance.storeId,
  'marketType': instance.marketType,
  'marketTypeLabel': instance.marketTypeLabel,
  'name': instance.name,
  'purchaseCount': instance.purchaseCount,
  'totalAmount': instance.totalAmount,
  'isActive': instance.isActive,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
