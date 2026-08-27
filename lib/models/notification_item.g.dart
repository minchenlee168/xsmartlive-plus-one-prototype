// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      time: json['time'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'time': instance.time,
      'isRead': instance.isRead,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.live: 'live',
  NotificationType.cart: 'cart',
  NotificationType.favorite: 'favorite',
  NotificationType.promotion: 'promotion',
};
