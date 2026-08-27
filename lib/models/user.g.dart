// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  memberId: (json['memberId'] as num).toInt(),
  name: json['name'] as String,
  providerMemberId: json['providerMemberId'] as String?,
  memberProviderId: (json['memberProviderId'] as num?)?.toInt(),
  avatarUrl: json['avatarUrl'] as String?,
  wasRecentlyCreated: json['wasRecentlyCreated'] as bool? ?? false,
  email: json['email'] as String? ?? '',
  level: json['level'] as String? ?? 'Lv.1',
  points: (json['points'] as num?)?.toInt() ?? 0,
  isVip: json['isVip'] as bool? ?? false,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'memberId': instance.memberId,
  'name': instance.name,
  'providerMemberId': instance.providerMemberId,
  'memberProviderId': instance.memberProviderId,
  'avatarUrl': instance.avatarUrl,
  'wasRecentlyCreated': instance.wasRecentlyCreated,
  'email': instance.email,
  'level': instance.level,
  'points': instance.points,
  'isVip': instance.isVip,
};
