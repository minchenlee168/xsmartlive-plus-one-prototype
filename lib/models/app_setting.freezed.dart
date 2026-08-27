// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_setting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSetting {

 AppVersionInfo get ios; AppVersionInfo get android;
/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingCopyWith<AppSetting> get copyWith => _$AppSettingCopyWithImpl<AppSetting>(this as AppSetting, _$identity);

  /// Serializes this AppSetting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSetting&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ios,android);

@override
String toString() {
  return 'AppSetting(ios: $ios, android: $android)';
}


}

/// @nodoc
abstract mixin class $AppSettingCopyWith<$Res>  {
  factory $AppSettingCopyWith(AppSetting value, $Res Function(AppSetting) _then) = _$AppSettingCopyWithImpl;
@useResult
$Res call({
 AppVersionInfo ios, AppVersionInfo android
});


$AppVersionInfoCopyWith<$Res> get ios;$AppVersionInfoCopyWith<$Res> get android;

}
/// @nodoc
class _$AppSettingCopyWithImpl<$Res>
    implements $AppSettingCopyWith<$Res> {
  _$AppSettingCopyWithImpl(this._self, this._then);

  final AppSetting _self;
  final $Res Function(AppSetting) _then;

/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ios = null,Object? android = null,}) {
  return _then(_self.copyWith(
ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as AppVersionInfo,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as AppVersionInfo,
  ));
}
/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppVersionInfoCopyWith<$Res> get ios {
  
  return $AppVersionInfoCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppVersionInfoCopyWith<$Res> get android {
  
  return $AppVersionInfoCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppSetting].
extension AppSettingPatterns on AppSetting {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSetting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSetting() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSetting value)  $default,){
final _that = this;
switch (_that) {
case _AppSetting():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSetting value)?  $default,){
final _that = this;
switch (_that) {
case _AppSetting() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AppVersionInfo ios,  AppVersionInfo android)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSetting() when $default != null:
return $default(_that.ios,_that.android);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AppVersionInfo ios,  AppVersionInfo android)  $default,) {final _that = this;
switch (_that) {
case _AppSetting():
return $default(_that.ios,_that.android);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AppVersionInfo ios,  AppVersionInfo android)?  $default,) {final _that = this;
switch (_that) {
case _AppSetting() when $default != null:
return $default(_that.ios,_that.android);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSetting implements AppSetting {
  const _AppSetting({required this.ios, required this.android});
  factory _AppSetting.fromJson(Map<String, dynamic> json) => _$AppSettingFromJson(json);

@override final  AppVersionInfo ios;
@override final  AppVersionInfo android;

/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingCopyWith<_AppSetting> get copyWith => __$AppSettingCopyWithImpl<_AppSetting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSetting&&(identical(other.ios, ios) || other.ios == ios)&&(identical(other.android, android) || other.android == android));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ios,android);

@override
String toString() {
  return 'AppSetting(ios: $ios, android: $android)';
}


}

/// @nodoc
abstract mixin class _$AppSettingCopyWith<$Res> implements $AppSettingCopyWith<$Res> {
  factory _$AppSettingCopyWith(_AppSetting value, $Res Function(_AppSetting) _then) = __$AppSettingCopyWithImpl;
@override @useResult
$Res call({
 AppVersionInfo ios, AppVersionInfo android
});


@override $AppVersionInfoCopyWith<$Res> get ios;@override $AppVersionInfoCopyWith<$Res> get android;

}
/// @nodoc
class __$AppSettingCopyWithImpl<$Res>
    implements _$AppSettingCopyWith<$Res> {
  __$AppSettingCopyWithImpl(this._self, this._then);

  final _AppSetting _self;
  final $Res Function(_AppSetting) _then;

/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ios = null,Object? android = null,}) {
  return _then(_AppSetting(
ios: null == ios ? _self.ios : ios // ignore: cast_nullable_to_non_nullable
as AppVersionInfo,android: null == android ? _self.android : android // ignore: cast_nullable_to_non_nullable
as AppVersionInfo,
  ));
}

/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppVersionInfoCopyWith<$Res> get ios {
  
  return $AppVersionInfoCopyWith<$Res>(_self.ios, (value) {
    return _then(_self.copyWith(ios: value));
  });
}/// Create a copy of AppSetting
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppVersionInfoCopyWith<$Res> get android {
  
  return $AppVersionInfoCopyWith<$Res>(_self.android, (value) {
    return _then(_self.copyWith(android: value));
  });
}
}


/// @nodoc
mixin _$AppVersionInfo {

 String get minVersion; String get currentVersion; bool get forceUpdate;
/// Create a copy of AppVersionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppVersionInfoCopyWith<AppVersionInfo> get copyWith => _$AppVersionInfoCopyWithImpl<AppVersionInfo>(this as AppVersionInfo, _$identity);

  /// Serializes this AppVersionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppVersionInfo&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minVersion,currentVersion,forceUpdate);

@override
String toString() {
  return 'AppVersionInfo(minVersion: $minVersion, currentVersion: $currentVersion, forceUpdate: $forceUpdate)';
}


}

/// @nodoc
abstract mixin class $AppVersionInfoCopyWith<$Res>  {
  factory $AppVersionInfoCopyWith(AppVersionInfo value, $Res Function(AppVersionInfo) _then) = _$AppVersionInfoCopyWithImpl;
@useResult
$Res call({
 String minVersion, String currentVersion, bool forceUpdate
});




}
/// @nodoc
class _$AppVersionInfoCopyWithImpl<$Res>
    implements $AppVersionInfoCopyWith<$Res> {
  _$AppVersionInfoCopyWithImpl(this._self, this._then);

  final AppVersionInfo _self;
  final $Res Function(AppVersionInfo) _then;

/// Create a copy of AppVersionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minVersion = null,Object? currentVersion = null,Object? forceUpdate = null,}) {
  return _then(_self.copyWith(
minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppVersionInfo].
extension AppVersionInfoPatterns on AppVersionInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppVersionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppVersionInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppVersionInfo value)  $default,){
final _that = this;
switch (_that) {
case _AppVersionInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppVersionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AppVersionInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String minVersion,  String currentVersion,  bool forceUpdate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppVersionInfo() when $default != null:
return $default(_that.minVersion,_that.currentVersion,_that.forceUpdate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String minVersion,  String currentVersion,  bool forceUpdate)  $default,) {final _that = this;
switch (_that) {
case _AppVersionInfo():
return $default(_that.minVersion,_that.currentVersion,_that.forceUpdate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String minVersion,  String currentVersion,  bool forceUpdate)?  $default,) {final _that = this;
switch (_that) {
case _AppVersionInfo() when $default != null:
return $default(_that.minVersion,_that.currentVersion,_that.forceUpdate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppVersionInfo implements AppVersionInfo {
  const _AppVersionInfo({required this.minVersion, required this.currentVersion, this.forceUpdate = false});
  factory _AppVersionInfo.fromJson(Map<String, dynamic> json) => _$AppVersionInfoFromJson(json);

@override final  String minVersion;
@override final  String currentVersion;
@override@JsonKey() final  bool forceUpdate;

/// Create a copy of AppVersionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppVersionInfoCopyWith<_AppVersionInfo> get copyWith => __$AppVersionInfoCopyWithImpl<_AppVersionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppVersionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppVersionInfo&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minVersion,currentVersion,forceUpdate);

@override
String toString() {
  return 'AppVersionInfo(minVersion: $minVersion, currentVersion: $currentVersion, forceUpdate: $forceUpdate)';
}


}

/// @nodoc
abstract mixin class _$AppVersionInfoCopyWith<$Res> implements $AppVersionInfoCopyWith<$Res> {
  factory _$AppVersionInfoCopyWith(_AppVersionInfo value, $Res Function(_AppVersionInfo) _then) = __$AppVersionInfoCopyWithImpl;
@override @useResult
$Res call({
 String minVersion, String currentVersion, bool forceUpdate
});




}
/// @nodoc
class __$AppVersionInfoCopyWithImpl<$Res>
    implements _$AppVersionInfoCopyWith<$Res> {
  __$AppVersionInfoCopyWithImpl(this._self, this._then);

  final _AppVersionInfo _self;
  final $Res Function(_AppVersionInfo) _then;

/// Create a copy of AppVersionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minVersion = null,Object? currentVersion = null,Object? forceUpdate = null,}) {
  return _then(_AppVersionInfo(
minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as String,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
