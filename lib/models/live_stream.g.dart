// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveComment _$LiveCommentFromJson(Map<String, dynamic> json) => _LiveComment(
  id: json['id'] as String,
  username: json['username'] as String,
  message: json['message'] as String,
  avatar: json['avatar'] as String?,
  time: json['time'] as String? ?? '',
);

Map<String, dynamic> _$LiveCommentToJson(_LiveComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'message': instance.message,
      'avatar': instance.avatar,
      'time': instance.time,
    };
