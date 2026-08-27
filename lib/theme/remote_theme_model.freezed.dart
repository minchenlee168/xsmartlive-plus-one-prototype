// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_theme_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemoteThemeModel {

 RemoteColors get colors; RemoteTypography get typography; RemoteShape get shape; RemoteAssets get assets; RemoteSpacing? get spacing; RemoteElevation? get elevation; RemoteBrandPalette? get brandPalette;
/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteThemeModelCopyWith<RemoteThemeModel> get copyWith => _$RemoteThemeModelCopyWithImpl<RemoteThemeModel>(this as RemoteThemeModel, _$identity);

  /// Serializes this RemoteThemeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteThemeModel&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.typography, typography) || other.typography == typography)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.assets, assets) || other.assets == assets)&&(identical(other.spacing, spacing) || other.spacing == spacing)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.brandPalette, brandPalette) || other.brandPalette == brandPalette));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,colors,typography,shape,assets,spacing,elevation,brandPalette);

@override
String toString() {
  return 'RemoteThemeModel(colors: $colors, typography: $typography, shape: $shape, assets: $assets, spacing: $spacing, elevation: $elevation, brandPalette: $brandPalette)';
}


}

/// @nodoc
abstract mixin class $RemoteThemeModelCopyWith<$Res>  {
  factory $RemoteThemeModelCopyWith(RemoteThemeModel value, $Res Function(RemoteThemeModel) _then) = _$RemoteThemeModelCopyWithImpl;
@useResult
$Res call({
 RemoteColors colors, RemoteTypography typography, RemoteShape shape, RemoteAssets assets, RemoteSpacing? spacing, RemoteElevation? elevation, RemoteBrandPalette? brandPalette
});


$RemoteColorsCopyWith<$Res> get colors;$RemoteTypographyCopyWith<$Res> get typography;$RemoteShapeCopyWith<$Res> get shape;$RemoteAssetsCopyWith<$Res> get assets;$RemoteSpacingCopyWith<$Res>? get spacing;$RemoteElevationCopyWith<$Res>? get elevation;$RemoteBrandPaletteCopyWith<$Res>? get brandPalette;

}
/// @nodoc
class _$RemoteThemeModelCopyWithImpl<$Res>
    implements $RemoteThemeModelCopyWith<$Res> {
  _$RemoteThemeModelCopyWithImpl(this._self, this._then);

  final RemoteThemeModel _self;
  final $Res Function(RemoteThemeModel) _then;

/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? colors = null,Object? typography = null,Object? shape = null,Object? assets = null,Object? spacing = freezed,Object? elevation = freezed,Object? brandPalette = freezed,}) {
  return _then(_self.copyWith(
colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as RemoteColors,typography: null == typography ? _self.typography : typography // ignore: cast_nullable_to_non_nullable
as RemoteTypography,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as RemoteShape,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as RemoteAssets,spacing: freezed == spacing ? _self.spacing : spacing // ignore: cast_nullable_to_non_nullable
as RemoteSpacing?,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as RemoteElevation?,brandPalette: freezed == brandPalette ? _self.brandPalette : brandPalette // ignore: cast_nullable_to_non_nullable
as RemoteBrandPalette?,
  ));
}
/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteColorsCopyWith<$Res> get colors {
  
  return $RemoteColorsCopyWith<$Res>(_self.colors, (value) {
    return _then(_self.copyWith(colors: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteTypographyCopyWith<$Res> get typography {
  
  return $RemoteTypographyCopyWith<$Res>(_self.typography, (value) {
    return _then(_self.copyWith(typography: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteShapeCopyWith<$Res> get shape {
  
  return $RemoteShapeCopyWith<$Res>(_self.shape, (value) {
    return _then(_self.copyWith(shape: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteAssetsCopyWith<$Res> get assets {
  
  return $RemoteAssetsCopyWith<$Res>(_self.assets, (value) {
    return _then(_self.copyWith(assets: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteSpacingCopyWith<$Res>? get spacing {
    if (_self.spacing == null) {
    return null;
  }

  return $RemoteSpacingCopyWith<$Res>(_self.spacing!, (value) {
    return _then(_self.copyWith(spacing: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteElevationCopyWith<$Res>? get elevation {
    if (_self.elevation == null) {
    return null;
  }

  return $RemoteElevationCopyWith<$Res>(_self.elevation!, (value) {
    return _then(_self.copyWith(elevation: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteBrandPaletteCopyWith<$Res>? get brandPalette {
    if (_self.brandPalette == null) {
    return null;
  }

  return $RemoteBrandPaletteCopyWith<$Res>(_self.brandPalette!, (value) {
    return _then(_self.copyWith(brandPalette: value));
  });
}
}


/// Adds pattern-matching-related methods to [RemoteThemeModel].
extension RemoteThemeModelPatterns on RemoteThemeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteThemeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteThemeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteThemeModel value)  $default,){
final _that = this;
switch (_that) {
case _RemoteThemeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteThemeModel value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteThemeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RemoteColors colors,  RemoteTypography typography,  RemoteShape shape,  RemoteAssets assets,  RemoteSpacing? spacing,  RemoteElevation? elevation,  RemoteBrandPalette? brandPalette)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteThemeModel() when $default != null:
return $default(_that.colors,_that.typography,_that.shape,_that.assets,_that.spacing,_that.elevation,_that.brandPalette);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RemoteColors colors,  RemoteTypography typography,  RemoteShape shape,  RemoteAssets assets,  RemoteSpacing? spacing,  RemoteElevation? elevation,  RemoteBrandPalette? brandPalette)  $default,) {final _that = this;
switch (_that) {
case _RemoteThemeModel():
return $default(_that.colors,_that.typography,_that.shape,_that.assets,_that.spacing,_that.elevation,_that.brandPalette);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RemoteColors colors,  RemoteTypography typography,  RemoteShape shape,  RemoteAssets assets,  RemoteSpacing? spacing,  RemoteElevation? elevation,  RemoteBrandPalette? brandPalette)?  $default,) {final _that = this;
switch (_that) {
case _RemoteThemeModel() when $default != null:
return $default(_that.colors,_that.typography,_that.shape,_that.assets,_that.spacing,_that.elevation,_that.brandPalette);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteThemeModel implements RemoteThemeModel {
  const _RemoteThemeModel({required this.colors, required this.typography, required this.shape, required this.assets, this.spacing, this.elevation, this.brandPalette});
  factory _RemoteThemeModel.fromJson(Map<String, dynamic> json) => _$RemoteThemeModelFromJson(json);

@override final  RemoteColors colors;
@override final  RemoteTypography typography;
@override final  RemoteShape shape;
@override final  RemoteAssets assets;
@override final  RemoteSpacing? spacing;
@override final  RemoteElevation? elevation;
@override final  RemoteBrandPalette? brandPalette;

/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteThemeModelCopyWith<_RemoteThemeModel> get copyWith => __$RemoteThemeModelCopyWithImpl<_RemoteThemeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteThemeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteThemeModel&&(identical(other.colors, colors) || other.colors == colors)&&(identical(other.typography, typography) || other.typography == typography)&&(identical(other.shape, shape) || other.shape == shape)&&(identical(other.assets, assets) || other.assets == assets)&&(identical(other.spacing, spacing) || other.spacing == spacing)&&(identical(other.elevation, elevation) || other.elevation == elevation)&&(identical(other.brandPalette, brandPalette) || other.brandPalette == brandPalette));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,colors,typography,shape,assets,spacing,elevation,brandPalette);

@override
String toString() {
  return 'RemoteThemeModel(colors: $colors, typography: $typography, shape: $shape, assets: $assets, spacing: $spacing, elevation: $elevation, brandPalette: $brandPalette)';
}


}

/// @nodoc
abstract mixin class _$RemoteThemeModelCopyWith<$Res> implements $RemoteThemeModelCopyWith<$Res> {
  factory _$RemoteThemeModelCopyWith(_RemoteThemeModel value, $Res Function(_RemoteThemeModel) _then) = __$RemoteThemeModelCopyWithImpl;
@override @useResult
$Res call({
 RemoteColors colors, RemoteTypography typography, RemoteShape shape, RemoteAssets assets, RemoteSpacing? spacing, RemoteElevation? elevation, RemoteBrandPalette? brandPalette
});


@override $RemoteColorsCopyWith<$Res> get colors;@override $RemoteTypographyCopyWith<$Res> get typography;@override $RemoteShapeCopyWith<$Res> get shape;@override $RemoteAssetsCopyWith<$Res> get assets;@override $RemoteSpacingCopyWith<$Res>? get spacing;@override $RemoteElevationCopyWith<$Res>? get elevation;@override $RemoteBrandPaletteCopyWith<$Res>? get brandPalette;

}
/// @nodoc
class __$RemoteThemeModelCopyWithImpl<$Res>
    implements _$RemoteThemeModelCopyWith<$Res> {
  __$RemoteThemeModelCopyWithImpl(this._self, this._then);

  final _RemoteThemeModel _self;
  final $Res Function(_RemoteThemeModel) _then;

/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? colors = null,Object? typography = null,Object? shape = null,Object? assets = null,Object? spacing = freezed,Object? elevation = freezed,Object? brandPalette = freezed,}) {
  return _then(_RemoteThemeModel(
colors: null == colors ? _self.colors : colors // ignore: cast_nullable_to_non_nullable
as RemoteColors,typography: null == typography ? _self.typography : typography // ignore: cast_nullable_to_non_nullable
as RemoteTypography,shape: null == shape ? _self.shape : shape // ignore: cast_nullable_to_non_nullable
as RemoteShape,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as RemoteAssets,spacing: freezed == spacing ? _self.spacing : spacing // ignore: cast_nullable_to_non_nullable
as RemoteSpacing?,elevation: freezed == elevation ? _self.elevation : elevation // ignore: cast_nullable_to_non_nullable
as RemoteElevation?,brandPalette: freezed == brandPalette ? _self.brandPalette : brandPalette // ignore: cast_nullable_to_non_nullable
as RemoteBrandPalette?,
  ));
}

/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteColorsCopyWith<$Res> get colors {
  
  return $RemoteColorsCopyWith<$Res>(_self.colors, (value) {
    return _then(_self.copyWith(colors: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteTypographyCopyWith<$Res> get typography {
  
  return $RemoteTypographyCopyWith<$Res>(_self.typography, (value) {
    return _then(_self.copyWith(typography: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteShapeCopyWith<$Res> get shape {
  
  return $RemoteShapeCopyWith<$Res>(_self.shape, (value) {
    return _then(_self.copyWith(shape: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteAssetsCopyWith<$Res> get assets {
  
  return $RemoteAssetsCopyWith<$Res>(_self.assets, (value) {
    return _then(_self.copyWith(assets: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteSpacingCopyWith<$Res>? get spacing {
    if (_self.spacing == null) {
    return null;
  }

  return $RemoteSpacingCopyWith<$Res>(_self.spacing!, (value) {
    return _then(_self.copyWith(spacing: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteElevationCopyWith<$Res>? get elevation {
    if (_self.elevation == null) {
    return null;
  }

  return $RemoteElevationCopyWith<$Res>(_self.elevation!, (value) {
    return _then(_self.copyWith(elevation: value));
  });
}/// Create a copy of RemoteThemeModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RemoteBrandPaletteCopyWith<$Res>? get brandPalette {
    if (_self.brandPalette == null) {
    return null;
  }

  return $RemoteBrandPaletteCopyWith<$Res>(_self.brandPalette!, (value) {
    return _then(_self.copyWith(brandPalette: value));
  });
}
}


/// @nodoc
mixin _$RemoteBrandPalette {

 String get tone50; String get tone100; String get tone200; String get tone300; String get tone400; String get tone500; String get tone600; String get tone700; String get tone800; String get tone900; String get tone950;
/// Create a copy of RemoteBrandPalette
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteBrandPaletteCopyWith<RemoteBrandPalette> get copyWith => _$RemoteBrandPaletteCopyWithImpl<RemoteBrandPalette>(this as RemoteBrandPalette, _$identity);

  /// Serializes this RemoteBrandPalette to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteBrandPalette&&(identical(other.tone50, tone50) || other.tone50 == tone50)&&(identical(other.tone100, tone100) || other.tone100 == tone100)&&(identical(other.tone200, tone200) || other.tone200 == tone200)&&(identical(other.tone300, tone300) || other.tone300 == tone300)&&(identical(other.tone400, tone400) || other.tone400 == tone400)&&(identical(other.tone500, tone500) || other.tone500 == tone500)&&(identical(other.tone600, tone600) || other.tone600 == tone600)&&(identical(other.tone700, tone700) || other.tone700 == tone700)&&(identical(other.tone800, tone800) || other.tone800 == tone800)&&(identical(other.tone900, tone900) || other.tone900 == tone900)&&(identical(other.tone950, tone950) || other.tone950 == tone950));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tone50,tone100,tone200,tone300,tone400,tone500,tone600,tone700,tone800,tone900,tone950);

@override
String toString() {
  return 'RemoteBrandPalette(tone50: $tone50, tone100: $tone100, tone200: $tone200, tone300: $tone300, tone400: $tone400, tone500: $tone500, tone600: $tone600, tone700: $tone700, tone800: $tone800, tone900: $tone900, tone950: $tone950)';
}


}

/// @nodoc
abstract mixin class $RemoteBrandPaletteCopyWith<$Res>  {
  factory $RemoteBrandPaletteCopyWith(RemoteBrandPalette value, $Res Function(RemoteBrandPalette) _then) = _$RemoteBrandPaletteCopyWithImpl;
@useResult
$Res call({
 String tone50, String tone100, String tone200, String tone300, String tone400, String tone500, String tone600, String tone700, String tone800, String tone900, String tone950
});




}
/// @nodoc
class _$RemoteBrandPaletteCopyWithImpl<$Res>
    implements $RemoteBrandPaletteCopyWith<$Res> {
  _$RemoteBrandPaletteCopyWithImpl(this._self, this._then);

  final RemoteBrandPalette _self;
  final $Res Function(RemoteBrandPalette) _then;

/// Create a copy of RemoteBrandPalette
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tone50 = null,Object? tone100 = null,Object? tone200 = null,Object? tone300 = null,Object? tone400 = null,Object? tone500 = null,Object? tone600 = null,Object? tone700 = null,Object? tone800 = null,Object? tone900 = null,Object? tone950 = null,}) {
  return _then(_self.copyWith(
tone50: null == tone50 ? _self.tone50 : tone50 // ignore: cast_nullable_to_non_nullable
as String,tone100: null == tone100 ? _self.tone100 : tone100 // ignore: cast_nullable_to_non_nullable
as String,tone200: null == tone200 ? _self.tone200 : tone200 // ignore: cast_nullable_to_non_nullable
as String,tone300: null == tone300 ? _self.tone300 : tone300 // ignore: cast_nullable_to_non_nullable
as String,tone400: null == tone400 ? _self.tone400 : tone400 // ignore: cast_nullable_to_non_nullable
as String,tone500: null == tone500 ? _self.tone500 : tone500 // ignore: cast_nullable_to_non_nullable
as String,tone600: null == tone600 ? _self.tone600 : tone600 // ignore: cast_nullable_to_non_nullable
as String,tone700: null == tone700 ? _self.tone700 : tone700 // ignore: cast_nullable_to_non_nullable
as String,tone800: null == tone800 ? _self.tone800 : tone800 // ignore: cast_nullable_to_non_nullable
as String,tone900: null == tone900 ? _self.tone900 : tone900 // ignore: cast_nullable_to_non_nullable
as String,tone950: null == tone950 ? _self.tone950 : tone950 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteBrandPalette].
extension RemoteBrandPalettePatterns on RemoteBrandPalette {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteBrandPalette value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteBrandPalette() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteBrandPalette value)  $default,){
final _that = this;
switch (_that) {
case _RemoteBrandPalette():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteBrandPalette value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteBrandPalette() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tone50,  String tone100,  String tone200,  String tone300,  String tone400,  String tone500,  String tone600,  String tone700,  String tone800,  String tone900,  String tone950)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteBrandPalette() when $default != null:
return $default(_that.tone50,_that.tone100,_that.tone200,_that.tone300,_that.tone400,_that.tone500,_that.tone600,_that.tone700,_that.tone800,_that.tone900,_that.tone950);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tone50,  String tone100,  String tone200,  String tone300,  String tone400,  String tone500,  String tone600,  String tone700,  String tone800,  String tone900,  String tone950)  $default,) {final _that = this;
switch (_that) {
case _RemoteBrandPalette():
return $default(_that.tone50,_that.tone100,_that.tone200,_that.tone300,_that.tone400,_that.tone500,_that.tone600,_that.tone700,_that.tone800,_that.tone900,_that.tone950);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tone50,  String tone100,  String tone200,  String tone300,  String tone400,  String tone500,  String tone600,  String tone700,  String tone800,  String tone900,  String tone950)?  $default,) {final _that = this;
switch (_that) {
case _RemoteBrandPalette() when $default != null:
return $default(_that.tone50,_that.tone100,_that.tone200,_that.tone300,_that.tone400,_that.tone500,_that.tone600,_that.tone700,_that.tone800,_that.tone900,_that.tone950);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteBrandPalette implements RemoteBrandPalette {
  const _RemoteBrandPalette({this.tone50 = '#F2EBFF', this.tone100 = '#E0D0FC', this.tone200 = '#C29FFA', this.tone300 = '#A370F7', this.tone400 = '#8441F5', this.tone500 = '#7008E7', this.tone600 = '#5218C2', this.tone700 = '#3D0F91', this.tone800 = '#290661', this.tone900 = '#270251', this.tone950 = '#130128'});
  factory _RemoteBrandPalette.fromJson(Map<String, dynamic> json) => _$RemoteBrandPaletteFromJson(json);

@override@JsonKey() final  String tone50;
@override@JsonKey() final  String tone100;
@override@JsonKey() final  String tone200;
@override@JsonKey() final  String tone300;
@override@JsonKey() final  String tone400;
@override@JsonKey() final  String tone500;
@override@JsonKey() final  String tone600;
@override@JsonKey() final  String tone700;
@override@JsonKey() final  String tone800;
@override@JsonKey() final  String tone900;
@override@JsonKey() final  String tone950;

/// Create a copy of RemoteBrandPalette
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteBrandPaletteCopyWith<_RemoteBrandPalette> get copyWith => __$RemoteBrandPaletteCopyWithImpl<_RemoteBrandPalette>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteBrandPaletteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteBrandPalette&&(identical(other.tone50, tone50) || other.tone50 == tone50)&&(identical(other.tone100, tone100) || other.tone100 == tone100)&&(identical(other.tone200, tone200) || other.tone200 == tone200)&&(identical(other.tone300, tone300) || other.tone300 == tone300)&&(identical(other.tone400, tone400) || other.tone400 == tone400)&&(identical(other.tone500, tone500) || other.tone500 == tone500)&&(identical(other.tone600, tone600) || other.tone600 == tone600)&&(identical(other.tone700, tone700) || other.tone700 == tone700)&&(identical(other.tone800, tone800) || other.tone800 == tone800)&&(identical(other.tone900, tone900) || other.tone900 == tone900)&&(identical(other.tone950, tone950) || other.tone950 == tone950));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tone50,tone100,tone200,tone300,tone400,tone500,tone600,tone700,tone800,tone900,tone950);

@override
String toString() {
  return 'RemoteBrandPalette(tone50: $tone50, tone100: $tone100, tone200: $tone200, tone300: $tone300, tone400: $tone400, tone500: $tone500, tone600: $tone600, tone700: $tone700, tone800: $tone800, tone900: $tone900, tone950: $tone950)';
}


}

/// @nodoc
abstract mixin class _$RemoteBrandPaletteCopyWith<$Res> implements $RemoteBrandPaletteCopyWith<$Res> {
  factory _$RemoteBrandPaletteCopyWith(_RemoteBrandPalette value, $Res Function(_RemoteBrandPalette) _then) = __$RemoteBrandPaletteCopyWithImpl;
@override @useResult
$Res call({
 String tone50, String tone100, String tone200, String tone300, String tone400, String tone500, String tone600, String tone700, String tone800, String tone900, String tone950
});




}
/// @nodoc
class __$RemoteBrandPaletteCopyWithImpl<$Res>
    implements _$RemoteBrandPaletteCopyWith<$Res> {
  __$RemoteBrandPaletteCopyWithImpl(this._self, this._then);

  final _RemoteBrandPalette _self;
  final $Res Function(_RemoteBrandPalette) _then;

/// Create a copy of RemoteBrandPalette
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tone50 = null,Object? tone100 = null,Object? tone200 = null,Object? tone300 = null,Object? tone400 = null,Object? tone500 = null,Object? tone600 = null,Object? tone700 = null,Object? tone800 = null,Object? tone900 = null,Object? tone950 = null,}) {
  return _then(_RemoteBrandPalette(
tone50: null == tone50 ? _self.tone50 : tone50 // ignore: cast_nullable_to_non_nullable
as String,tone100: null == tone100 ? _self.tone100 : tone100 // ignore: cast_nullable_to_non_nullable
as String,tone200: null == tone200 ? _self.tone200 : tone200 // ignore: cast_nullable_to_non_nullable
as String,tone300: null == tone300 ? _self.tone300 : tone300 // ignore: cast_nullable_to_non_nullable
as String,tone400: null == tone400 ? _self.tone400 : tone400 // ignore: cast_nullable_to_non_nullable
as String,tone500: null == tone500 ? _self.tone500 : tone500 // ignore: cast_nullable_to_non_nullable
as String,tone600: null == tone600 ? _self.tone600 : tone600 // ignore: cast_nullable_to_non_nullable
as String,tone700: null == tone700 ? _self.tone700 : tone700 // ignore: cast_nullable_to_non_nullable
as String,tone800: null == tone800 ? _self.tone800 : tone800 // ignore: cast_nullable_to_non_nullable
as String,tone900: null == tone900 ? _self.tone900 : tone900 // ignore: cast_nullable_to_non_nullable
as String,tone950: null == tone950 ? _self.tone950 : tone950 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RemoteColors {

// `primary` / `onPrimary` are LEGACY fields retained for schema
// backward-compat. The effective brand primary is now
// `brandPalette.tone500`, and `onPrimary` is always white. New merchants
// should configure brand colours via `brandPalette` (11-tone ramp).
 String get primary; String get onPrimary; String get secondary; String get surface; String get background; String get error;// Extended semantic colors
 String get success; String get warning; String get info; String get divider; String get muted;// Auth page decorative gradient (login / register / forgot password).
// Separate from [primary]/[secondary] so auth pages can carry their own
// accent without tying it to the brand primary.
 String get authGradientStart; String get authGradientEnd;
/// Create a copy of RemoteColors
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteColorsCopyWith<RemoteColors> get copyWith => _$RemoteColorsCopyWithImpl<RemoteColors>(this as RemoteColors, _$identity);

  /// Serializes this RemoteColors to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.onPrimary, onPrimary) || other.onPrimary == onPrimary)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.background, background) || other.background == background)&&(identical(other.error, error) || other.error == error)&&(identical(other.success, success) || other.success == success)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.info, info) || other.info == info)&&(identical(other.divider, divider) || other.divider == divider)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.authGradientStart, authGradientStart) || other.authGradientStart == authGradientStart)&&(identical(other.authGradientEnd, authGradientEnd) || other.authGradientEnd == authGradientEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primary,onPrimary,secondary,surface,background,error,success,warning,info,divider,muted,authGradientStart,authGradientEnd);

@override
String toString() {
  return 'RemoteColors(primary: $primary, onPrimary: $onPrimary, secondary: $secondary, surface: $surface, background: $background, error: $error, success: $success, warning: $warning, info: $info, divider: $divider, muted: $muted, authGradientStart: $authGradientStart, authGradientEnd: $authGradientEnd)';
}


}

/// @nodoc
abstract mixin class $RemoteColorsCopyWith<$Res>  {
  factory $RemoteColorsCopyWith(RemoteColors value, $Res Function(RemoteColors) _then) = _$RemoteColorsCopyWithImpl;
@useResult
$Res call({
 String primary, String onPrimary, String secondary, String surface, String background, String error, String success, String warning, String info, String divider, String muted, String authGradientStart, String authGradientEnd
});




}
/// @nodoc
class _$RemoteColorsCopyWithImpl<$Res>
    implements $RemoteColorsCopyWith<$Res> {
  _$RemoteColorsCopyWithImpl(this._self, this._then);

  final RemoteColors _self;
  final $Res Function(RemoteColors) _then;

/// Create a copy of RemoteColors
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? primary = null,Object? onPrimary = null,Object? secondary = null,Object? surface = null,Object? background = null,Object? error = null,Object? success = null,Object? warning = null,Object? info = null,Object? divider = null,Object? muted = null,Object? authGradientStart = null,Object? authGradientEnd = null,}) {
  return _then(_self.copyWith(
primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as String,onPrimary: null == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as String,secondary: null == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as String,surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as String,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as String,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as String,divider: null == divider ? _self.divider : divider // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as String,authGradientStart: null == authGradientStart ? _self.authGradientStart : authGradientStart // ignore: cast_nullable_to_non_nullable
as String,authGradientEnd: null == authGradientEnd ? _self.authGradientEnd : authGradientEnd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteColors].
extension RemoteColorsPatterns on RemoteColors {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteColors value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteColors() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteColors value)  $default,){
final _that = this;
switch (_that) {
case _RemoteColors():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteColors value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteColors() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String primary,  String onPrimary,  String secondary,  String surface,  String background,  String error,  String success,  String warning,  String info,  String divider,  String muted,  String authGradientStart,  String authGradientEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteColors() when $default != null:
return $default(_that.primary,_that.onPrimary,_that.secondary,_that.surface,_that.background,_that.error,_that.success,_that.warning,_that.info,_that.divider,_that.muted,_that.authGradientStart,_that.authGradientEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String primary,  String onPrimary,  String secondary,  String surface,  String background,  String error,  String success,  String warning,  String info,  String divider,  String muted,  String authGradientStart,  String authGradientEnd)  $default,) {final _that = this;
switch (_that) {
case _RemoteColors():
return $default(_that.primary,_that.onPrimary,_that.secondary,_that.surface,_that.background,_that.error,_that.success,_that.warning,_that.info,_that.divider,_that.muted,_that.authGradientStart,_that.authGradientEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String primary,  String onPrimary,  String secondary,  String surface,  String background,  String error,  String success,  String warning,  String info,  String divider,  String muted,  String authGradientStart,  String authGradientEnd)?  $default,) {final _that = this;
switch (_that) {
case _RemoteColors() when $default != null:
return $default(_that.primary,_that.onPrimary,_that.secondary,_that.surface,_that.background,_that.error,_that.success,_that.warning,_that.info,_that.divider,_that.muted,_that.authGradientStart,_that.authGradientEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteColors implements RemoteColors {
  const _RemoteColors({this.primary = '#9333EA', this.onPrimary = '#FFFFFF', this.secondary = '#EC4899', this.surface = '#FFFFFF', this.background = '#F9FAFB', this.error = '#EF4444', this.success = '#10B981', this.warning = '#F59E0B', this.info = '#3B82F6', this.divider = '#E5E7EB', this.muted = '#9CA3AF', this.authGradientStart = '#64C6EC', this.authGradientEnd = '#F032FF'});
  factory _RemoteColors.fromJson(Map<String, dynamic> json) => _$RemoteColorsFromJson(json);

// `primary` / `onPrimary` are LEGACY fields retained for schema
// backward-compat. The effective brand primary is now
// `brandPalette.tone500`, and `onPrimary` is always white. New merchants
// should configure brand colours via `brandPalette` (11-tone ramp).
@override@JsonKey() final  String primary;
@override@JsonKey() final  String onPrimary;
@override@JsonKey() final  String secondary;
@override@JsonKey() final  String surface;
@override@JsonKey() final  String background;
@override@JsonKey() final  String error;
// Extended semantic colors
@override@JsonKey() final  String success;
@override@JsonKey() final  String warning;
@override@JsonKey() final  String info;
@override@JsonKey() final  String divider;
@override@JsonKey() final  String muted;
// Auth page decorative gradient (login / register / forgot password).
// Separate from [primary]/[secondary] so auth pages can carry their own
// accent without tying it to the brand primary.
@override@JsonKey() final  String authGradientStart;
@override@JsonKey() final  String authGradientEnd;

/// Create a copy of RemoteColors
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteColorsCopyWith<_RemoteColors> get copyWith => __$RemoteColorsCopyWithImpl<_RemoteColors>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteColorsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteColors&&(identical(other.primary, primary) || other.primary == primary)&&(identical(other.onPrimary, onPrimary) || other.onPrimary == onPrimary)&&(identical(other.secondary, secondary) || other.secondary == secondary)&&(identical(other.surface, surface) || other.surface == surface)&&(identical(other.background, background) || other.background == background)&&(identical(other.error, error) || other.error == error)&&(identical(other.success, success) || other.success == success)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.info, info) || other.info == info)&&(identical(other.divider, divider) || other.divider == divider)&&(identical(other.muted, muted) || other.muted == muted)&&(identical(other.authGradientStart, authGradientStart) || other.authGradientStart == authGradientStart)&&(identical(other.authGradientEnd, authGradientEnd) || other.authGradientEnd == authGradientEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,primary,onPrimary,secondary,surface,background,error,success,warning,info,divider,muted,authGradientStart,authGradientEnd);

@override
String toString() {
  return 'RemoteColors(primary: $primary, onPrimary: $onPrimary, secondary: $secondary, surface: $surface, background: $background, error: $error, success: $success, warning: $warning, info: $info, divider: $divider, muted: $muted, authGradientStart: $authGradientStart, authGradientEnd: $authGradientEnd)';
}


}

/// @nodoc
abstract mixin class _$RemoteColorsCopyWith<$Res> implements $RemoteColorsCopyWith<$Res> {
  factory _$RemoteColorsCopyWith(_RemoteColors value, $Res Function(_RemoteColors) _then) = __$RemoteColorsCopyWithImpl;
@override @useResult
$Res call({
 String primary, String onPrimary, String secondary, String surface, String background, String error, String success, String warning, String info, String divider, String muted, String authGradientStart, String authGradientEnd
});




}
/// @nodoc
class __$RemoteColorsCopyWithImpl<$Res>
    implements _$RemoteColorsCopyWith<$Res> {
  __$RemoteColorsCopyWithImpl(this._self, this._then);

  final _RemoteColors _self;
  final $Res Function(_RemoteColors) _then;

/// Create a copy of RemoteColors
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? primary = null,Object? onPrimary = null,Object? secondary = null,Object? surface = null,Object? background = null,Object? error = null,Object? success = null,Object? warning = null,Object? info = null,Object? divider = null,Object? muted = null,Object? authGradientStart = null,Object? authGradientEnd = null,}) {
  return _then(_RemoteColors(
primary: null == primary ? _self.primary : primary // ignore: cast_nullable_to_non_nullable
as String,onPrimary: null == onPrimary ? _self.onPrimary : onPrimary // ignore: cast_nullable_to_non_nullable
as String,secondary: null == secondary ? _self.secondary : secondary // ignore: cast_nullable_to_non_nullable
as String,surface: null == surface ? _self.surface : surface // ignore: cast_nullable_to_non_nullable
as String,background: null == background ? _self.background : background // ignore: cast_nullable_to_non_nullable
as String,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as String,warning: null == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as String,info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as String,divider: null == divider ? _self.divider : divider // ignore: cast_nullable_to_non_nullable
as String,muted: null == muted ? _self.muted : muted // ignore: cast_nullable_to_non_nullable
as String,authGradientStart: null == authGradientStart ? _self.authGradientStart : authGradientStart // ignore: cast_nullable_to_non_nullable
as String,authGradientEnd: null == authGradientEnd ? _self.authGradientEnd : authGradientEnd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RemoteTypography {

 String get fontFamily; double get headingSize; double get titleSize; double get bodySize; double get labelSize; double get captionSize;
/// Create a copy of RemoteTypography
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteTypographyCopyWith<RemoteTypography> get copyWith => _$RemoteTypographyCopyWithImpl<RemoteTypography>(this as RemoteTypography, _$identity);

  /// Serializes this RemoteTypography to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteTypography&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.headingSize, headingSize) || other.headingSize == headingSize)&&(identical(other.titleSize, titleSize) || other.titleSize == titleSize)&&(identical(other.bodySize, bodySize) || other.bodySize == bodySize)&&(identical(other.labelSize, labelSize) || other.labelSize == labelSize)&&(identical(other.captionSize, captionSize) || other.captionSize == captionSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontFamily,headingSize,titleSize,bodySize,labelSize,captionSize);

@override
String toString() {
  return 'RemoteTypography(fontFamily: $fontFamily, headingSize: $headingSize, titleSize: $titleSize, bodySize: $bodySize, labelSize: $labelSize, captionSize: $captionSize)';
}


}

/// @nodoc
abstract mixin class $RemoteTypographyCopyWith<$Res>  {
  factory $RemoteTypographyCopyWith(RemoteTypography value, $Res Function(RemoteTypography) _then) = _$RemoteTypographyCopyWithImpl;
@useResult
$Res call({
 String fontFamily, double headingSize, double titleSize, double bodySize, double labelSize, double captionSize
});




}
/// @nodoc
class _$RemoteTypographyCopyWithImpl<$Res>
    implements $RemoteTypographyCopyWith<$Res> {
  _$RemoteTypographyCopyWithImpl(this._self, this._then);

  final RemoteTypography _self;
  final $Res Function(RemoteTypography) _then;

/// Create a copy of RemoteTypography
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontFamily = null,Object? headingSize = null,Object? titleSize = null,Object? bodySize = null,Object? labelSize = null,Object? captionSize = null,}) {
  return _then(_self.copyWith(
fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,headingSize: null == headingSize ? _self.headingSize : headingSize // ignore: cast_nullable_to_non_nullable
as double,titleSize: null == titleSize ? _self.titleSize : titleSize // ignore: cast_nullable_to_non_nullable
as double,bodySize: null == bodySize ? _self.bodySize : bodySize // ignore: cast_nullable_to_non_nullable
as double,labelSize: null == labelSize ? _self.labelSize : labelSize // ignore: cast_nullable_to_non_nullable
as double,captionSize: null == captionSize ? _self.captionSize : captionSize // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteTypography].
extension RemoteTypographyPatterns on RemoteTypography {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteTypography value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteTypography() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteTypography value)  $default,){
final _that = this;
switch (_that) {
case _RemoteTypography():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteTypography value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteTypography() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fontFamily,  double headingSize,  double titleSize,  double bodySize,  double labelSize,  double captionSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteTypography() when $default != null:
return $default(_that.fontFamily,_that.headingSize,_that.titleSize,_that.bodySize,_that.labelSize,_that.captionSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fontFamily,  double headingSize,  double titleSize,  double bodySize,  double labelSize,  double captionSize)  $default,) {final _that = this;
switch (_that) {
case _RemoteTypography():
return $default(_that.fontFamily,_that.headingSize,_that.titleSize,_that.bodySize,_that.labelSize,_that.captionSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fontFamily,  double headingSize,  double titleSize,  double bodySize,  double labelSize,  double captionSize)?  $default,) {final _that = this;
switch (_that) {
case _RemoteTypography() when $default != null:
return $default(_that.fontFamily,_that.headingSize,_that.titleSize,_that.bodySize,_that.labelSize,_that.captionSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteTypography implements RemoteTypography {
  const _RemoteTypography({this.fontFamily = 'Noto Sans TC', this.headingSize = 24.0, this.titleSize = 16.0, this.bodySize = 14.0, this.labelSize = 12.0, this.captionSize = 11.0});
  factory _RemoteTypography.fromJson(Map<String, dynamic> json) => _$RemoteTypographyFromJson(json);

@override@JsonKey() final  String fontFamily;
@override@JsonKey() final  double headingSize;
@override@JsonKey() final  double titleSize;
@override@JsonKey() final  double bodySize;
@override@JsonKey() final  double labelSize;
@override@JsonKey() final  double captionSize;

/// Create a copy of RemoteTypography
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteTypographyCopyWith<_RemoteTypography> get copyWith => __$RemoteTypographyCopyWithImpl<_RemoteTypography>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteTypographyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteTypography&&(identical(other.fontFamily, fontFamily) || other.fontFamily == fontFamily)&&(identical(other.headingSize, headingSize) || other.headingSize == headingSize)&&(identical(other.titleSize, titleSize) || other.titleSize == titleSize)&&(identical(other.bodySize, bodySize) || other.bodySize == bodySize)&&(identical(other.labelSize, labelSize) || other.labelSize == labelSize)&&(identical(other.captionSize, captionSize) || other.captionSize == captionSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontFamily,headingSize,titleSize,bodySize,labelSize,captionSize);

@override
String toString() {
  return 'RemoteTypography(fontFamily: $fontFamily, headingSize: $headingSize, titleSize: $titleSize, bodySize: $bodySize, labelSize: $labelSize, captionSize: $captionSize)';
}


}

/// @nodoc
abstract mixin class _$RemoteTypographyCopyWith<$Res> implements $RemoteTypographyCopyWith<$Res> {
  factory _$RemoteTypographyCopyWith(_RemoteTypography value, $Res Function(_RemoteTypography) _then) = __$RemoteTypographyCopyWithImpl;
@override @useResult
$Res call({
 String fontFamily, double headingSize, double titleSize, double bodySize, double labelSize, double captionSize
});




}
/// @nodoc
class __$RemoteTypographyCopyWithImpl<$Res>
    implements _$RemoteTypographyCopyWith<$Res> {
  __$RemoteTypographyCopyWithImpl(this._self, this._then);

  final _RemoteTypography _self;
  final $Res Function(_RemoteTypography) _then;

/// Create a copy of RemoteTypography
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontFamily = null,Object? headingSize = null,Object? titleSize = null,Object? bodySize = null,Object? labelSize = null,Object? captionSize = null,}) {
  return _then(_RemoteTypography(
fontFamily: null == fontFamily ? _self.fontFamily : fontFamily // ignore: cast_nullable_to_non_nullable
as String,headingSize: null == headingSize ? _self.headingSize : headingSize // ignore: cast_nullable_to_non_nullable
as double,titleSize: null == titleSize ? _self.titleSize : titleSize // ignore: cast_nullable_to_non_nullable
as double,bodySize: null == bodySize ? _self.bodySize : bodySize // ignore: cast_nullable_to_non_nullable
as double,labelSize: null == labelSize ? _self.labelSize : labelSize // ignore: cast_nullable_to_non_nullable
as double,captionSize: null == captionSize ? _self.captionSize : captionSize // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RemoteShape {

 double get cardRadius; double get buttonRadius; double get chipRadius; double get dialogRadius; double get sheetRadius; double get avatarRadius;
/// Create a copy of RemoteShape
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteShapeCopyWith<RemoteShape> get copyWith => _$RemoteShapeCopyWithImpl<RemoteShape>(this as RemoteShape, _$identity);

  /// Serializes this RemoteShape to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteShape&&(identical(other.cardRadius, cardRadius) || other.cardRadius == cardRadius)&&(identical(other.buttonRadius, buttonRadius) || other.buttonRadius == buttonRadius)&&(identical(other.chipRadius, chipRadius) || other.chipRadius == chipRadius)&&(identical(other.dialogRadius, dialogRadius) || other.dialogRadius == dialogRadius)&&(identical(other.sheetRadius, sheetRadius) || other.sheetRadius == sheetRadius)&&(identical(other.avatarRadius, avatarRadius) || other.avatarRadius == avatarRadius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cardRadius,buttonRadius,chipRadius,dialogRadius,sheetRadius,avatarRadius);

@override
String toString() {
  return 'RemoteShape(cardRadius: $cardRadius, buttonRadius: $buttonRadius, chipRadius: $chipRadius, dialogRadius: $dialogRadius, sheetRadius: $sheetRadius, avatarRadius: $avatarRadius)';
}


}

/// @nodoc
abstract mixin class $RemoteShapeCopyWith<$Res>  {
  factory $RemoteShapeCopyWith(RemoteShape value, $Res Function(RemoteShape) _then) = _$RemoteShapeCopyWithImpl;
@useResult
$Res call({
 double cardRadius, double buttonRadius, double chipRadius, double dialogRadius, double sheetRadius, double avatarRadius
});




}
/// @nodoc
class _$RemoteShapeCopyWithImpl<$Res>
    implements $RemoteShapeCopyWith<$Res> {
  _$RemoteShapeCopyWithImpl(this._self, this._then);

  final RemoteShape _self;
  final $Res Function(RemoteShape) _then;

/// Create a copy of RemoteShape
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cardRadius = null,Object? buttonRadius = null,Object? chipRadius = null,Object? dialogRadius = null,Object? sheetRadius = null,Object? avatarRadius = null,}) {
  return _then(_self.copyWith(
cardRadius: null == cardRadius ? _self.cardRadius : cardRadius // ignore: cast_nullable_to_non_nullable
as double,buttonRadius: null == buttonRadius ? _self.buttonRadius : buttonRadius // ignore: cast_nullable_to_non_nullable
as double,chipRadius: null == chipRadius ? _self.chipRadius : chipRadius // ignore: cast_nullable_to_non_nullable
as double,dialogRadius: null == dialogRadius ? _self.dialogRadius : dialogRadius // ignore: cast_nullable_to_non_nullable
as double,sheetRadius: null == sheetRadius ? _self.sheetRadius : sheetRadius // ignore: cast_nullable_to_non_nullable
as double,avatarRadius: null == avatarRadius ? _self.avatarRadius : avatarRadius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteShape].
extension RemoteShapePatterns on RemoteShape {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteShape value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteShape() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteShape value)  $default,){
final _that = this;
switch (_that) {
case _RemoteShape():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteShape value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteShape() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double cardRadius,  double buttonRadius,  double chipRadius,  double dialogRadius,  double sheetRadius,  double avatarRadius)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteShape() when $default != null:
return $default(_that.cardRadius,_that.buttonRadius,_that.chipRadius,_that.dialogRadius,_that.sheetRadius,_that.avatarRadius);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double cardRadius,  double buttonRadius,  double chipRadius,  double dialogRadius,  double sheetRadius,  double avatarRadius)  $default,) {final _that = this;
switch (_that) {
case _RemoteShape():
return $default(_that.cardRadius,_that.buttonRadius,_that.chipRadius,_that.dialogRadius,_that.sheetRadius,_that.avatarRadius);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double cardRadius,  double buttonRadius,  double chipRadius,  double dialogRadius,  double sheetRadius,  double avatarRadius)?  $default,) {final _that = this;
switch (_that) {
case _RemoteShape() when $default != null:
return $default(_that.cardRadius,_that.buttonRadius,_that.chipRadius,_that.dialogRadius,_that.sheetRadius,_that.avatarRadius);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteShape implements RemoteShape {
  const _RemoteShape({this.cardRadius = 12.0, this.buttonRadius = 8.0, this.chipRadius = 8.0, this.dialogRadius = 16.0, this.sheetRadius = 20.0, this.avatarRadius = 999.0});
  factory _RemoteShape.fromJson(Map<String, dynamic> json) => _$RemoteShapeFromJson(json);

@override@JsonKey() final  double cardRadius;
@override@JsonKey() final  double buttonRadius;
@override@JsonKey() final  double chipRadius;
@override@JsonKey() final  double dialogRadius;
@override@JsonKey() final  double sheetRadius;
@override@JsonKey() final  double avatarRadius;

/// Create a copy of RemoteShape
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteShapeCopyWith<_RemoteShape> get copyWith => __$RemoteShapeCopyWithImpl<_RemoteShape>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteShapeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteShape&&(identical(other.cardRadius, cardRadius) || other.cardRadius == cardRadius)&&(identical(other.buttonRadius, buttonRadius) || other.buttonRadius == buttonRadius)&&(identical(other.chipRadius, chipRadius) || other.chipRadius == chipRadius)&&(identical(other.dialogRadius, dialogRadius) || other.dialogRadius == dialogRadius)&&(identical(other.sheetRadius, sheetRadius) || other.sheetRadius == sheetRadius)&&(identical(other.avatarRadius, avatarRadius) || other.avatarRadius == avatarRadius));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cardRadius,buttonRadius,chipRadius,dialogRadius,sheetRadius,avatarRadius);

@override
String toString() {
  return 'RemoteShape(cardRadius: $cardRadius, buttonRadius: $buttonRadius, chipRadius: $chipRadius, dialogRadius: $dialogRadius, sheetRadius: $sheetRadius, avatarRadius: $avatarRadius)';
}


}

/// @nodoc
abstract mixin class _$RemoteShapeCopyWith<$Res> implements $RemoteShapeCopyWith<$Res> {
  factory _$RemoteShapeCopyWith(_RemoteShape value, $Res Function(_RemoteShape) _then) = __$RemoteShapeCopyWithImpl;
@override @useResult
$Res call({
 double cardRadius, double buttonRadius, double chipRadius, double dialogRadius, double sheetRadius, double avatarRadius
});




}
/// @nodoc
class __$RemoteShapeCopyWithImpl<$Res>
    implements _$RemoteShapeCopyWith<$Res> {
  __$RemoteShapeCopyWithImpl(this._self, this._then);

  final _RemoteShape _self;
  final $Res Function(_RemoteShape) _then;

/// Create a copy of RemoteShape
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cardRadius = null,Object? buttonRadius = null,Object? chipRadius = null,Object? dialogRadius = null,Object? sheetRadius = null,Object? avatarRadius = null,}) {
  return _then(_RemoteShape(
cardRadius: null == cardRadius ? _self.cardRadius : cardRadius // ignore: cast_nullable_to_non_nullable
as double,buttonRadius: null == buttonRadius ? _self.buttonRadius : buttonRadius // ignore: cast_nullable_to_non_nullable
as double,chipRadius: null == chipRadius ? _self.chipRadius : chipRadius // ignore: cast_nullable_to_non_nullable
as double,dialogRadius: null == dialogRadius ? _self.dialogRadius : dialogRadius // ignore: cast_nullable_to_non_nullable
as double,sheetRadius: null == sheetRadius ? _self.sheetRadius : sheetRadius // ignore: cast_nullable_to_non_nullable
as double,avatarRadius: null == avatarRadius ? _self.avatarRadius : avatarRadius // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RemoteSpacing {

 double get xxs; double get xs; double get sm; double get md; double get lg; double get xl; double get xxl; double get xxxl;
/// Create a copy of RemoteSpacing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteSpacingCopyWith<RemoteSpacing> get copyWith => _$RemoteSpacingCopyWithImpl<RemoteSpacing>(this as RemoteSpacing, _$identity);

  /// Serializes this RemoteSpacing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteSpacing&&(identical(other.xxs, xxs) || other.xxs == xxs)&&(identical(other.xs, xs) || other.xs == xs)&&(identical(other.sm, sm) || other.sm == sm)&&(identical(other.md, md) || other.md == md)&&(identical(other.lg, lg) || other.lg == lg)&&(identical(other.xl, xl) || other.xl == xl)&&(identical(other.xxl, xxl) || other.xxl == xxl)&&(identical(other.xxxl, xxxl) || other.xxxl == xxxl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xxs,xs,sm,md,lg,xl,xxl,xxxl);

@override
String toString() {
  return 'RemoteSpacing(xxs: $xxs, xs: $xs, sm: $sm, md: $md, lg: $lg, xl: $xl, xxl: $xxl, xxxl: $xxxl)';
}


}

/// @nodoc
abstract mixin class $RemoteSpacingCopyWith<$Res>  {
  factory $RemoteSpacingCopyWith(RemoteSpacing value, $Res Function(RemoteSpacing) _then) = _$RemoteSpacingCopyWithImpl;
@useResult
$Res call({
 double xxs, double xs, double sm, double md, double lg, double xl, double xxl, double xxxl
});




}
/// @nodoc
class _$RemoteSpacingCopyWithImpl<$Res>
    implements $RemoteSpacingCopyWith<$Res> {
  _$RemoteSpacingCopyWithImpl(this._self, this._then);

  final RemoteSpacing _self;
  final $Res Function(RemoteSpacing) _then;

/// Create a copy of RemoteSpacing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? xxs = null,Object? xs = null,Object? sm = null,Object? md = null,Object? lg = null,Object? xl = null,Object? xxl = null,Object? xxxl = null,}) {
  return _then(_self.copyWith(
xxs: null == xxs ? _self.xxs : xxs // ignore: cast_nullable_to_non_nullable
as double,xs: null == xs ? _self.xs : xs // ignore: cast_nullable_to_non_nullable
as double,sm: null == sm ? _self.sm : sm // ignore: cast_nullable_to_non_nullable
as double,md: null == md ? _self.md : md // ignore: cast_nullable_to_non_nullable
as double,lg: null == lg ? _self.lg : lg // ignore: cast_nullable_to_non_nullable
as double,xl: null == xl ? _self.xl : xl // ignore: cast_nullable_to_non_nullable
as double,xxl: null == xxl ? _self.xxl : xxl // ignore: cast_nullable_to_non_nullable
as double,xxxl: null == xxxl ? _self.xxxl : xxxl // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteSpacing].
extension RemoteSpacingPatterns on RemoteSpacing {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteSpacing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteSpacing() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteSpacing value)  $default,){
final _that = this;
switch (_that) {
case _RemoteSpacing():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteSpacing value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteSpacing() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double xxs,  double xs,  double sm,  double md,  double lg,  double xl,  double xxl,  double xxxl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteSpacing() when $default != null:
return $default(_that.xxs,_that.xs,_that.sm,_that.md,_that.lg,_that.xl,_that.xxl,_that.xxxl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double xxs,  double xs,  double sm,  double md,  double lg,  double xl,  double xxl,  double xxxl)  $default,) {final _that = this;
switch (_that) {
case _RemoteSpacing():
return $default(_that.xxs,_that.xs,_that.sm,_that.md,_that.lg,_that.xl,_that.xxl,_that.xxxl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double xxs,  double xs,  double sm,  double md,  double lg,  double xl,  double xxl,  double xxxl)?  $default,) {final _that = this;
switch (_that) {
case _RemoteSpacing() when $default != null:
return $default(_that.xxs,_that.xs,_that.sm,_that.md,_that.lg,_that.xl,_that.xxl,_that.xxxl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteSpacing implements RemoteSpacing {
  const _RemoteSpacing({this.xxs = 2.0, this.xs = 4.0, this.sm = 8.0, this.md = 12.0, this.lg = 16.0, this.xl = 20.0, this.xxl = 24.0, this.xxxl = 32.0});
  factory _RemoteSpacing.fromJson(Map<String, dynamic> json) => _$RemoteSpacingFromJson(json);

@override@JsonKey() final  double xxs;
@override@JsonKey() final  double xs;
@override@JsonKey() final  double sm;
@override@JsonKey() final  double md;
@override@JsonKey() final  double lg;
@override@JsonKey() final  double xl;
@override@JsonKey() final  double xxl;
@override@JsonKey() final  double xxxl;

/// Create a copy of RemoteSpacing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteSpacingCopyWith<_RemoteSpacing> get copyWith => __$RemoteSpacingCopyWithImpl<_RemoteSpacing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteSpacingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteSpacing&&(identical(other.xxs, xxs) || other.xxs == xxs)&&(identical(other.xs, xs) || other.xs == xs)&&(identical(other.sm, sm) || other.sm == sm)&&(identical(other.md, md) || other.md == md)&&(identical(other.lg, lg) || other.lg == lg)&&(identical(other.xl, xl) || other.xl == xl)&&(identical(other.xxl, xxl) || other.xxl == xxl)&&(identical(other.xxxl, xxxl) || other.xxxl == xxxl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,xxs,xs,sm,md,lg,xl,xxl,xxxl);

@override
String toString() {
  return 'RemoteSpacing(xxs: $xxs, xs: $xs, sm: $sm, md: $md, lg: $lg, xl: $xl, xxl: $xxl, xxxl: $xxxl)';
}


}

/// @nodoc
abstract mixin class _$RemoteSpacingCopyWith<$Res> implements $RemoteSpacingCopyWith<$Res> {
  factory _$RemoteSpacingCopyWith(_RemoteSpacing value, $Res Function(_RemoteSpacing) _then) = __$RemoteSpacingCopyWithImpl;
@override @useResult
$Res call({
 double xxs, double xs, double sm, double md, double lg, double xl, double xxl, double xxxl
});




}
/// @nodoc
class __$RemoteSpacingCopyWithImpl<$Res>
    implements _$RemoteSpacingCopyWith<$Res> {
  __$RemoteSpacingCopyWithImpl(this._self, this._then);

  final _RemoteSpacing _self;
  final $Res Function(_RemoteSpacing) _then;

/// Create a copy of RemoteSpacing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? xxs = null,Object? xs = null,Object? sm = null,Object? md = null,Object? lg = null,Object? xl = null,Object? xxl = null,Object? xxxl = null,}) {
  return _then(_RemoteSpacing(
xxs: null == xxs ? _self.xxs : xxs // ignore: cast_nullable_to_non_nullable
as double,xs: null == xs ? _self.xs : xs // ignore: cast_nullable_to_non_nullable
as double,sm: null == sm ? _self.sm : sm // ignore: cast_nullable_to_non_nullable
as double,md: null == md ? _self.md : md // ignore: cast_nullable_to_non_nullable
as double,lg: null == lg ? _self.lg : lg // ignore: cast_nullable_to_non_nullable
as double,xl: null == xl ? _self.xl : xl // ignore: cast_nullable_to_non_nullable
as double,xxl: null == xxl ? _self.xxl : xxl // ignore: cast_nullable_to_non_nullable
as double,xxxl: null == xxxl ? _self.xxxl : xxxl // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RemoteElevation {

 String get level1Color; double get level1Blur; double get level1OffsetY; String get level2Color; double get level2Blur; double get level2OffsetY; String get level3Color; double get level3Blur; double get level3OffsetY;
/// Create a copy of RemoteElevation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteElevationCopyWith<RemoteElevation> get copyWith => _$RemoteElevationCopyWithImpl<RemoteElevation>(this as RemoteElevation, _$identity);

  /// Serializes this RemoteElevation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteElevation&&(identical(other.level1Color, level1Color) || other.level1Color == level1Color)&&(identical(other.level1Blur, level1Blur) || other.level1Blur == level1Blur)&&(identical(other.level1OffsetY, level1OffsetY) || other.level1OffsetY == level1OffsetY)&&(identical(other.level2Color, level2Color) || other.level2Color == level2Color)&&(identical(other.level2Blur, level2Blur) || other.level2Blur == level2Blur)&&(identical(other.level2OffsetY, level2OffsetY) || other.level2OffsetY == level2OffsetY)&&(identical(other.level3Color, level3Color) || other.level3Color == level3Color)&&(identical(other.level3Blur, level3Blur) || other.level3Blur == level3Blur)&&(identical(other.level3OffsetY, level3OffsetY) || other.level3OffsetY == level3OffsetY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level1Color,level1Blur,level1OffsetY,level2Color,level2Blur,level2OffsetY,level3Color,level3Blur,level3OffsetY);

@override
String toString() {
  return 'RemoteElevation(level1Color: $level1Color, level1Blur: $level1Blur, level1OffsetY: $level1OffsetY, level2Color: $level2Color, level2Blur: $level2Blur, level2OffsetY: $level2OffsetY, level3Color: $level3Color, level3Blur: $level3Blur, level3OffsetY: $level3OffsetY)';
}


}

/// @nodoc
abstract mixin class $RemoteElevationCopyWith<$Res>  {
  factory $RemoteElevationCopyWith(RemoteElevation value, $Res Function(RemoteElevation) _then) = _$RemoteElevationCopyWithImpl;
@useResult
$Res call({
 String level1Color, double level1Blur, double level1OffsetY, String level2Color, double level2Blur, double level2OffsetY, String level3Color, double level3Blur, double level3OffsetY
});




}
/// @nodoc
class _$RemoteElevationCopyWithImpl<$Res>
    implements $RemoteElevationCopyWith<$Res> {
  _$RemoteElevationCopyWithImpl(this._self, this._then);

  final RemoteElevation _self;
  final $Res Function(RemoteElevation) _then;

/// Create a copy of RemoteElevation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level1Color = null,Object? level1Blur = null,Object? level1OffsetY = null,Object? level2Color = null,Object? level2Blur = null,Object? level2OffsetY = null,Object? level3Color = null,Object? level3Blur = null,Object? level3OffsetY = null,}) {
  return _then(_self.copyWith(
level1Color: null == level1Color ? _self.level1Color : level1Color // ignore: cast_nullable_to_non_nullable
as String,level1Blur: null == level1Blur ? _self.level1Blur : level1Blur // ignore: cast_nullable_to_non_nullable
as double,level1OffsetY: null == level1OffsetY ? _self.level1OffsetY : level1OffsetY // ignore: cast_nullable_to_non_nullable
as double,level2Color: null == level2Color ? _self.level2Color : level2Color // ignore: cast_nullable_to_non_nullable
as String,level2Blur: null == level2Blur ? _self.level2Blur : level2Blur // ignore: cast_nullable_to_non_nullable
as double,level2OffsetY: null == level2OffsetY ? _self.level2OffsetY : level2OffsetY // ignore: cast_nullable_to_non_nullable
as double,level3Color: null == level3Color ? _self.level3Color : level3Color // ignore: cast_nullable_to_non_nullable
as String,level3Blur: null == level3Blur ? _self.level3Blur : level3Blur // ignore: cast_nullable_to_non_nullable
as double,level3OffsetY: null == level3OffsetY ? _self.level3OffsetY : level3OffsetY // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteElevation].
extension RemoteElevationPatterns on RemoteElevation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteElevation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteElevation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteElevation value)  $default,){
final _that = this;
switch (_that) {
case _RemoteElevation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteElevation value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteElevation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String level1Color,  double level1Blur,  double level1OffsetY,  String level2Color,  double level2Blur,  double level2OffsetY,  String level3Color,  double level3Blur,  double level3OffsetY)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteElevation() when $default != null:
return $default(_that.level1Color,_that.level1Blur,_that.level1OffsetY,_that.level2Color,_that.level2Blur,_that.level2OffsetY,_that.level3Color,_that.level3Blur,_that.level3OffsetY);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String level1Color,  double level1Blur,  double level1OffsetY,  String level2Color,  double level2Blur,  double level2OffsetY,  String level3Color,  double level3Blur,  double level3OffsetY)  $default,) {final _that = this;
switch (_that) {
case _RemoteElevation():
return $default(_that.level1Color,_that.level1Blur,_that.level1OffsetY,_that.level2Color,_that.level2Blur,_that.level2OffsetY,_that.level3Color,_that.level3Blur,_that.level3OffsetY);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String level1Color,  double level1Blur,  double level1OffsetY,  String level2Color,  double level2Blur,  double level2OffsetY,  String level3Color,  double level3Blur,  double level3OffsetY)?  $default,) {final _that = this;
switch (_that) {
case _RemoteElevation() when $default != null:
return $default(_that.level1Color,_that.level1Blur,_that.level1OffsetY,_that.level2Color,_that.level2Blur,_that.level2OffsetY,_that.level3Color,_that.level3Blur,_that.level3OffsetY);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteElevation implements RemoteElevation {
  const _RemoteElevation({this.level1Color = '#0A000000', this.level1Blur = 4.0, this.level1OffsetY = 1.0, this.level2Color = '#14000000', this.level2Blur = 8.0, this.level2OffsetY = 2.0, this.level3Color = '#1F000000', this.level3Blur = 16.0, this.level3OffsetY = 4.0});
  factory _RemoteElevation.fromJson(Map<String, dynamic> json) => _$RemoteElevationFromJson(json);

@override@JsonKey() final  String level1Color;
@override@JsonKey() final  double level1Blur;
@override@JsonKey() final  double level1OffsetY;
@override@JsonKey() final  String level2Color;
@override@JsonKey() final  double level2Blur;
@override@JsonKey() final  double level2OffsetY;
@override@JsonKey() final  String level3Color;
@override@JsonKey() final  double level3Blur;
@override@JsonKey() final  double level3OffsetY;

/// Create a copy of RemoteElevation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteElevationCopyWith<_RemoteElevation> get copyWith => __$RemoteElevationCopyWithImpl<_RemoteElevation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteElevationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteElevation&&(identical(other.level1Color, level1Color) || other.level1Color == level1Color)&&(identical(other.level1Blur, level1Blur) || other.level1Blur == level1Blur)&&(identical(other.level1OffsetY, level1OffsetY) || other.level1OffsetY == level1OffsetY)&&(identical(other.level2Color, level2Color) || other.level2Color == level2Color)&&(identical(other.level2Blur, level2Blur) || other.level2Blur == level2Blur)&&(identical(other.level2OffsetY, level2OffsetY) || other.level2OffsetY == level2OffsetY)&&(identical(other.level3Color, level3Color) || other.level3Color == level3Color)&&(identical(other.level3Blur, level3Blur) || other.level3Blur == level3Blur)&&(identical(other.level3OffsetY, level3OffsetY) || other.level3OffsetY == level3OffsetY));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,level1Color,level1Blur,level1OffsetY,level2Color,level2Blur,level2OffsetY,level3Color,level3Blur,level3OffsetY);

@override
String toString() {
  return 'RemoteElevation(level1Color: $level1Color, level1Blur: $level1Blur, level1OffsetY: $level1OffsetY, level2Color: $level2Color, level2Blur: $level2Blur, level2OffsetY: $level2OffsetY, level3Color: $level3Color, level3Blur: $level3Blur, level3OffsetY: $level3OffsetY)';
}


}

/// @nodoc
abstract mixin class _$RemoteElevationCopyWith<$Res> implements $RemoteElevationCopyWith<$Res> {
  factory _$RemoteElevationCopyWith(_RemoteElevation value, $Res Function(_RemoteElevation) _then) = __$RemoteElevationCopyWithImpl;
@override @useResult
$Res call({
 String level1Color, double level1Blur, double level1OffsetY, String level2Color, double level2Blur, double level2OffsetY, String level3Color, double level3Blur, double level3OffsetY
});




}
/// @nodoc
class __$RemoteElevationCopyWithImpl<$Res>
    implements _$RemoteElevationCopyWith<$Res> {
  __$RemoteElevationCopyWithImpl(this._self, this._then);

  final _RemoteElevation _self;
  final $Res Function(_RemoteElevation) _then;

/// Create a copy of RemoteElevation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level1Color = null,Object? level1Blur = null,Object? level1OffsetY = null,Object? level2Color = null,Object? level2Blur = null,Object? level2OffsetY = null,Object? level3Color = null,Object? level3Blur = null,Object? level3OffsetY = null,}) {
  return _then(_RemoteElevation(
level1Color: null == level1Color ? _self.level1Color : level1Color // ignore: cast_nullable_to_non_nullable
as String,level1Blur: null == level1Blur ? _self.level1Blur : level1Blur // ignore: cast_nullable_to_non_nullable
as double,level1OffsetY: null == level1OffsetY ? _self.level1OffsetY : level1OffsetY // ignore: cast_nullable_to_non_nullable
as double,level2Color: null == level2Color ? _self.level2Color : level2Color // ignore: cast_nullable_to_non_nullable
as String,level2Blur: null == level2Blur ? _self.level2Blur : level2Blur // ignore: cast_nullable_to_non_nullable
as double,level2OffsetY: null == level2OffsetY ? _self.level2OffsetY : level2OffsetY // ignore: cast_nullable_to_non_nullable
as double,level3Color: null == level3Color ? _self.level3Color : level3Color // ignore: cast_nullable_to_non_nullable
as String,level3Blur: null == level3Blur ? _self.level3Blur : level3Blur // ignore: cast_nullable_to_non_nullable
as double,level3OffsetY: null == level3OffsetY ? _self.level3OffsetY : level3OffsetY // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RemoteAssets {

 String? get logoUrl; String? get splashUrl;
/// Create a copy of RemoteAssets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteAssetsCopyWith<RemoteAssets> get copyWith => _$RemoteAssetsCopyWithImpl<RemoteAssets>(this as RemoteAssets, _$identity);

  /// Serializes this RemoteAssets to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteAssets&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.splashUrl, splashUrl) || other.splashUrl == splashUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logoUrl,splashUrl);

@override
String toString() {
  return 'RemoteAssets(logoUrl: $logoUrl, splashUrl: $splashUrl)';
}


}

/// @nodoc
abstract mixin class $RemoteAssetsCopyWith<$Res>  {
  factory $RemoteAssetsCopyWith(RemoteAssets value, $Res Function(RemoteAssets) _then) = _$RemoteAssetsCopyWithImpl;
@useResult
$Res call({
 String? logoUrl, String? splashUrl
});




}
/// @nodoc
class _$RemoteAssetsCopyWithImpl<$Res>
    implements $RemoteAssetsCopyWith<$Res> {
  _$RemoteAssetsCopyWithImpl(this._self, this._then);

  final RemoteAssets _self;
  final $Res Function(RemoteAssets) _then;

/// Create a copy of RemoteAssets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? logoUrl = freezed,Object? splashUrl = freezed,}) {
  return _then(_self.copyWith(
logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,splashUrl: freezed == splashUrl ? _self.splashUrl : splashUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteAssets].
extension RemoteAssetsPatterns on RemoteAssets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteAssets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteAssets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteAssets value)  $default,){
final _that = this;
switch (_that) {
case _RemoteAssets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteAssets value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteAssets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? logoUrl,  String? splashUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteAssets() when $default != null:
return $default(_that.logoUrl,_that.splashUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? logoUrl,  String? splashUrl)  $default,) {final _that = this;
switch (_that) {
case _RemoteAssets():
return $default(_that.logoUrl,_that.splashUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? logoUrl,  String? splashUrl)?  $default,) {final _that = this;
switch (_that) {
case _RemoteAssets() when $default != null:
return $default(_that.logoUrl,_that.splashUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteAssets implements RemoteAssets {
  const _RemoteAssets({this.logoUrl, this.splashUrl});
  factory _RemoteAssets.fromJson(Map<String, dynamic> json) => _$RemoteAssetsFromJson(json);

@override final  String? logoUrl;
@override final  String? splashUrl;

/// Create a copy of RemoteAssets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteAssetsCopyWith<_RemoteAssets> get copyWith => __$RemoteAssetsCopyWithImpl<_RemoteAssets>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteAssetsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteAssets&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.splashUrl, splashUrl) || other.splashUrl == splashUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,logoUrl,splashUrl);

@override
String toString() {
  return 'RemoteAssets(logoUrl: $logoUrl, splashUrl: $splashUrl)';
}


}

/// @nodoc
abstract mixin class _$RemoteAssetsCopyWith<$Res> implements $RemoteAssetsCopyWith<$Res> {
  factory _$RemoteAssetsCopyWith(_RemoteAssets value, $Res Function(_RemoteAssets) _then) = __$RemoteAssetsCopyWithImpl;
@override @useResult
$Res call({
 String? logoUrl, String? splashUrl
});




}
/// @nodoc
class __$RemoteAssetsCopyWithImpl<$Res>
    implements _$RemoteAssetsCopyWith<$Res> {
  __$RemoteAssetsCopyWithImpl(this._self, this._then);

  final _RemoteAssets _self;
  final $Res Function(_RemoteAssets) _then;

/// Create a copy of RemoteAssets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? logoUrl = freezed,Object? splashUrl = freezed,}) {
  return _then(_RemoteAssets(
logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,splashUrl: freezed == splashUrl ? _self.splashUrl : splashUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
