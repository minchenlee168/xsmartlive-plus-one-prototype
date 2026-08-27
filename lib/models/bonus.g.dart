// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bonus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BonusBalance _$BonusBalanceFromJson(Map<String, dynamic> json) =>
    _BonusBalance(
      pointBalance: (json['pointBalance'] as num).toInt(),
      updatedAt: json['updatedAt'] as String,
      expiringPoints: json['expiringPoints'] as String,
      expiringAt: json['expiringAt'] as String,
    );

Map<String, dynamic> _$BonusBalanceToJson(_BonusBalance instance) =>
    <String, dynamic>{
      'pointBalance': instance.pointBalance,
      'updatedAt': instance.updatedAt,
      'expiringPoints': instance.expiringPoints,
      'expiringAt': instance.expiringAt,
    };

_BonusUsage _$BonusUsageFromJson(Map<String, dynamic> json) => _BonusUsage(
  id: (json['id'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  purchaseId: (json['purchaseId'] as num).toInt(),
  pointUsed: (json['pointUsed'] as num).toInt(),
  convertedAmount: (json['convertedAmount'] as num).toDouble(),
  note: json['note'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$BonusUsageToJson(_BonusUsage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'purchaseId': instance.purchaseId,
      'pointUsed': instance.pointUsed,
      'convertedAmount': instance.convertedAmount,
      'note': instance.note,
      'createdAt': instance.createdAt,
    };
