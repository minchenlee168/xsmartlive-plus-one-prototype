// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSetting _$AppSettingFromJson(Map<String, dynamic> json) => _AppSetting(
  ios: AppVersionInfo.fromJson(json['ios'] as Map<String, dynamic>),
  android: AppVersionInfo.fromJson(json['android'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppSettingToJson(_AppSetting instance) =>
    <String, dynamic>{'ios': instance.ios, 'android': instance.android};

_AppVersionInfo _$AppVersionInfoFromJson(Map<String, dynamic> json) =>
    _AppVersionInfo(
      minVersion: json['minVersion'] as String,
      currentVersion: json['currentVersion'] as String,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
    );

Map<String, dynamic> _$AppVersionInfoToJson(_AppVersionInfo instance) =>
    <String, dynamic>{
      'minVersion': instance.minVersion,
      'currentVersion': instance.currentVersion,
      'forceUpdate': instance.forceUpdate,
    };
