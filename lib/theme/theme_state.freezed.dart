// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ThemeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ThemeState()';
}


}

/// @nodoc
class $ThemeStateCopyWith<$Res>  {
$ThemeStateCopyWith(ThemeState _, $Res Function(ThemeState) __);
}


/// Adds pattern-matching-related methods to [ThemeState].
extension ThemeStatePatterns on ThemeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ThemeInitial value)?  initial,TResult Function( ThemeLoading value)?  loading,TResult Function( ThemeCached value)?  cached,TResult Function( ThemeLoaded value)?  loaded,TResult Function( ThemeError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ThemeInitial() when initial != null:
return initial(_that);case ThemeLoading() when loading != null:
return loading(_that);case ThemeCached() when cached != null:
return cached(_that);case ThemeLoaded() when loaded != null:
return loaded(_that);case ThemeError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ThemeInitial value)  initial,required TResult Function( ThemeLoading value)  loading,required TResult Function( ThemeCached value)  cached,required TResult Function( ThemeLoaded value)  loaded,required TResult Function( ThemeError value)  error,}){
final _that = this;
switch (_that) {
case ThemeInitial():
return initial(_that);case ThemeLoading():
return loading(_that);case ThemeCached():
return cached(_that);case ThemeLoaded():
return loaded(_that);case ThemeError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ThemeInitial value)?  initial,TResult? Function( ThemeLoading value)?  loading,TResult? Function( ThemeCached value)?  cached,TResult? Function( ThemeLoaded value)?  loaded,TResult? Function( ThemeError value)?  error,}){
final _that = this;
switch (_that) {
case ThemeInitial() when initial != null:
return initial(_that);case ThemeLoading() when loading != null:
return loading(_that);case ThemeCached() when cached != null:
return cached(_that);case ThemeLoaded() when loaded != null:
return loaded(_that);case ThemeError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ThemeData theme)?  cached,TResult Function( ThemeData theme)?  loaded,TResult Function( String message,  ThemeData fallback)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ThemeInitial() when initial != null:
return initial();case ThemeLoading() when loading != null:
return loading();case ThemeCached() when cached != null:
return cached(_that.theme);case ThemeLoaded() when loaded != null:
return loaded(_that.theme);case ThemeError() when error != null:
return error(_that.message,_that.fallback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ThemeData theme)  cached,required TResult Function( ThemeData theme)  loaded,required TResult Function( String message,  ThemeData fallback)  error,}) {final _that = this;
switch (_that) {
case ThemeInitial():
return initial();case ThemeLoading():
return loading();case ThemeCached():
return cached(_that.theme);case ThemeLoaded():
return loaded(_that.theme);case ThemeError():
return error(_that.message,_that.fallback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ThemeData theme)?  cached,TResult? Function( ThemeData theme)?  loaded,TResult? Function( String message,  ThemeData fallback)?  error,}) {final _that = this;
switch (_that) {
case ThemeInitial() when initial != null:
return initial();case ThemeLoading() when loading != null:
return loading();case ThemeCached() when cached != null:
return cached(_that.theme);case ThemeLoaded() when loaded != null:
return loaded(_that.theme);case ThemeError() when error != null:
return error(_that.message,_that.fallback);case _:
  return null;

}
}

}

/// @nodoc


class ThemeInitial implements ThemeState {
  const ThemeInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ThemeState.initial()';
}


}




/// @nodoc


class ThemeLoading implements ThemeState {
  const ThemeLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ThemeState.loading()';
}


}




/// @nodoc


class ThemeCached implements ThemeState {
  const ThemeCached(this.theme);
  

 final  ThemeData theme;

/// Create a copy of ThemeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeCachedCopyWith<ThemeCached> get copyWith => _$ThemeCachedCopyWithImpl<ThemeCached>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeCached&&(identical(other.theme, theme) || other.theme == theme));
}


@override
int get hashCode => Object.hash(runtimeType,theme);

@override
String toString() {
  return 'ThemeState.cached(theme: $theme)';
}


}

/// @nodoc
abstract mixin class $ThemeCachedCopyWith<$Res> implements $ThemeStateCopyWith<$Res> {
  factory $ThemeCachedCopyWith(ThemeCached value, $Res Function(ThemeCached) _then) = _$ThemeCachedCopyWithImpl;
@useResult
$Res call({
 ThemeData theme
});




}
/// @nodoc
class _$ThemeCachedCopyWithImpl<$Res>
    implements $ThemeCachedCopyWith<$Res> {
  _$ThemeCachedCopyWithImpl(this._self, this._then);

  final ThemeCached _self;
  final $Res Function(ThemeCached) _then;

/// Create a copy of ThemeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? theme = null,}) {
  return _then(ThemeCached(
null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemeData,
  ));
}


}

/// @nodoc


class ThemeLoaded implements ThemeState {
  const ThemeLoaded(this.theme);
  

 final  ThemeData theme;

/// Create a copy of ThemeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeLoadedCopyWith<ThemeLoaded> get copyWith => _$ThemeLoadedCopyWithImpl<ThemeLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeLoaded&&(identical(other.theme, theme) || other.theme == theme));
}


@override
int get hashCode => Object.hash(runtimeType,theme);

@override
String toString() {
  return 'ThemeState.loaded(theme: $theme)';
}


}

/// @nodoc
abstract mixin class $ThemeLoadedCopyWith<$Res> implements $ThemeStateCopyWith<$Res> {
  factory $ThemeLoadedCopyWith(ThemeLoaded value, $Res Function(ThemeLoaded) _then) = _$ThemeLoadedCopyWithImpl;
@useResult
$Res call({
 ThemeData theme
});




}
/// @nodoc
class _$ThemeLoadedCopyWithImpl<$Res>
    implements $ThemeLoadedCopyWith<$Res> {
  _$ThemeLoadedCopyWithImpl(this._self, this._then);

  final ThemeLoaded _self;
  final $Res Function(ThemeLoaded) _then;

/// Create a copy of ThemeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? theme = null,}) {
  return _then(ThemeLoaded(
null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as ThemeData,
  ));
}


}

/// @nodoc


class ThemeError implements ThemeState {
  const ThemeError(this.message, this.fallback);
  

 final  String message;
 final  ThemeData fallback;

/// Create a copy of ThemeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeErrorCopyWith<ThemeError> get copyWith => _$ThemeErrorCopyWithImpl<ThemeError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeError&&(identical(other.message, message) || other.message == message)&&(identical(other.fallback, fallback) || other.fallback == fallback));
}


@override
int get hashCode => Object.hash(runtimeType,message,fallback);

@override
String toString() {
  return 'ThemeState.error(message: $message, fallback: $fallback)';
}


}

/// @nodoc
abstract mixin class $ThemeErrorCopyWith<$Res> implements $ThemeStateCopyWith<$Res> {
  factory $ThemeErrorCopyWith(ThemeError value, $Res Function(ThemeError) _then) = _$ThemeErrorCopyWithImpl;
@useResult
$Res call({
 String message, ThemeData fallback
});




}
/// @nodoc
class _$ThemeErrorCopyWithImpl<$Res>
    implements $ThemeErrorCopyWith<$Res> {
  _$ThemeErrorCopyWithImpl(this._self, this._then);

  final ThemeError _self;
  final $Res Function(ThemeError) _then;

/// Create a copy of ThemeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? fallback = null,}) {
  return _then(ThemeError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,null == fallback ? _self.fallback : fallback // ignore: cast_nullable_to_non_nullable
as ThemeData,
  ));
}


}

// dart format on
