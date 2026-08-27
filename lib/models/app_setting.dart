import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_setting.freezed.dart';
part 'app_setting.g.dart';

@freezed
abstract class AppSetting with _$AppSetting {
  const factory AppSetting({
    required AppVersionInfo ios,
    required AppVersionInfo android,
  }) = _AppSetting;

  factory AppSetting.fromJson(Map<String, dynamic> json) =>
      _$AppSettingFromJson(json);
}

@freezed
abstract class AppVersionInfo with _$AppVersionInfo {
  const factory AppVersionInfo({
    required String minVersion,
    required String currentVersion,
    @Default(false) bool forceUpdate,
  }) = _AppVersionInfo;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) =>
      _$AppVersionInfoFromJson(json);
}
