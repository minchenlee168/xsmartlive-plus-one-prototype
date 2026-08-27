// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coupon.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Coupon {

 int get id; String get name; int get enable; int get discountType; int? get totalQuota; String? get usableEndTime; String get status;// 2026-05 spec rev: CouponResource now exposes concrete discount /
// min-order numbers alongside the existing scope list. All optional
// so the codegen JSON adapter copes with legacy responses.
 double? get discountAmount; double? get discountPercent; double? get minOrderAmount; String? get code; List<dynamic> get scopes;
/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CouponCopyWith<Coupon> get copyWith => _$CouponCopyWithImpl<Coupon>(this as Coupon, _$identity);

  /// Serializes this Coupon to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coupon&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.totalQuota, totalQuota) || other.totalQuota == totalQuota)&&(identical(other.usableEndTime, usableEndTime) || other.usableEndTime == usableEndTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.minOrderAmount, minOrderAmount) || other.minOrderAmount == minOrderAmount)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other.scopes, scopes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enable,discountType,totalQuota,usableEndTime,status,discountAmount,discountPercent,minOrderAmount,code,const DeepCollectionEquality().hash(scopes));

@override
String toString() {
  return 'Coupon(id: $id, name: $name, enable: $enable, discountType: $discountType, totalQuota: $totalQuota, usableEndTime: $usableEndTime, status: $status, discountAmount: $discountAmount, discountPercent: $discountPercent, minOrderAmount: $minOrderAmount, code: $code, scopes: $scopes)';
}


}

/// @nodoc
abstract mixin class $CouponCopyWith<$Res>  {
  factory $CouponCopyWith(Coupon value, $Res Function(Coupon) _then) = _$CouponCopyWithImpl;
@useResult
$Res call({
 int id, String name, int enable, int discountType, int? totalQuota, String? usableEndTime, String status, double? discountAmount, double? discountPercent, double? minOrderAmount, String? code, List<dynamic> scopes
});




}
/// @nodoc
class _$CouponCopyWithImpl<$Res>
    implements $CouponCopyWith<$Res> {
  _$CouponCopyWithImpl(this._self, this._then);

  final Coupon _self;
  final $Res Function(Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? enable = null,Object? discountType = null,Object? totalQuota = freezed,Object? usableEndTime = freezed,Object? status = null,Object? discountAmount = freezed,Object? discountPercent = freezed,Object? minOrderAmount = freezed,Object? code = freezed,Object? scopes = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as int,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as int,totalQuota: freezed == totalQuota ? _self.totalQuota : totalQuota // ignore: cast_nullable_to_non_nullable
as int?,usableEndTime: freezed == usableEndTime ? _self.usableEndTime : usableEndTime // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,minOrderAmount: freezed == minOrderAmount ? _self.minOrderAmount : minOrderAmount // ignore: cast_nullable_to_non_nullable
as double?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,scopes: null == scopes ? _self.scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Coupon].
extension CouponPatterns on Coupon {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coupon value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coupon value)  $default,){
final _that = this;
switch (_that) {
case _Coupon():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coupon value)?  $default,){
final _that = this;
switch (_that) {
case _Coupon() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  int enable,  int discountType,  int? totalQuota,  String? usableEndTime,  String status,  double? discountAmount,  double? discountPercent,  double? minOrderAmount,  String? code,  List<dynamic> scopes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.id,_that.name,_that.enable,_that.discountType,_that.totalQuota,_that.usableEndTime,_that.status,_that.discountAmount,_that.discountPercent,_that.minOrderAmount,_that.code,_that.scopes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  int enable,  int discountType,  int? totalQuota,  String? usableEndTime,  String status,  double? discountAmount,  double? discountPercent,  double? minOrderAmount,  String? code,  List<dynamic> scopes)  $default,) {final _that = this;
switch (_that) {
case _Coupon():
return $default(_that.id,_that.name,_that.enable,_that.discountType,_that.totalQuota,_that.usableEndTime,_that.status,_that.discountAmount,_that.discountPercent,_that.minOrderAmount,_that.code,_that.scopes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  int enable,  int discountType,  int? totalQuota,  String? usableEndTime,  String status,  double? discountAmount,  double? discountPercent,  double? minOrderAmount,  String? code,  List<dynamic> scopes)?  $default,) {final _that = this;
switch (_that) {
case _Coupon() when $default != null:
return $default(_that.id,_that.name,_that.enable,_that.discountType,_that.totalQuota,_that.usableEndTime,_that.status,_that.discountAmount,_that.discountPercent,_that.minOrderAmount,_that.code,_that.scopes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coupon implements Coupon {
  const _Coupon({required this.id, required this.name, required this.enable, required this.discountType, this.totalQuota, this.usableEndTime, required this.status, this.discountAmount, this.discountPercent, this.minOrderAmount, this.code, final  List<dynamic> scopes = const <dynamic>[]}): _scopes = scopes;
  factory _Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

@override final  int id;
@override final  String name;
@override final  int enable;
@override final  int discountType;
@override final  int? totalQuota;
@override final  String? usableEndTime;
@override final  String status;
// 2026-05 spec rev: CouponResource now exposes concrete discount /
// min-order numbers alongside the existing scope list. All optional
// so the codegen JSON adapter copes with legacy responses.
@override final  double? discountAmount;
@override final  double? discountPercent;
@override final  double? minOrderAmount;
@override final  String? code;
 final  List<dynamic> _scopes;
@override@JsonKey() List<dynamic> get scopes {
  if (_scopes is EqualUnmodifiableListView) return _scopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scopes);
}


/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CouponCopyWith<_Coupon> get copyWith => __$CouponCopyWithImpl<_Coupon>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CouponToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coupon&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.enable, enable) || other.enable == enable)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.totalQuota, totalQuota) || other.totalQuota == totalQuota)&&(identical(other.usableEndTime, usableEndTime) || other.usableEndTime == usableEndTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&(identical(other.minOrderAmount, minOrderAmount) || other.minOrderAmount == minOrderAmount)&&(identical(other.code, code) || other.code == code)&&const DeepCollectionEquality().equals(other._scopes, _scopes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,enable,discountType,totalQuota,usableEndTime,status,discountAmount,discountPercent,minOrderAmount,code,const DeepCollectionEquality().hash(_scopes));

@override
String toString() {
  return 'Coupon(id: $id, name: $name, enable: $enable, discountType: $discountType, totalQuota: $totalQuota, usableEndTime: $usableEndTime, status: $status, discountAmount: $discountAmount, discountPercent: $discountPercent, minOrderAmount: $minOrderAmount, code: $code, scopes: $scopes)';
}


}

/// @nodoc
abstract mixin class _$CouponCopyWith<$Res> implements $CouponCopyWith<$Res> {
  factory _$CouponCopyWith(_Coupon value, $Res Function(_Coupon) _then) = __$CouponCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, int enable, int discountType, int? totalQuota, String? usableEndTime, String status, double? discountAmount, double? discountPercent, double? minOrderAmount, String? code, List<dynamic> scopes
});




}
/// @nodoc
class __$CouponCopyWithImpl<$Res>
    implements _$CouponCopyWith<$Res> {
  __$CouponCopyWithImpl(this._self, this._then);

  final _Coupon _self;
  final $Res Function(_Coupon) _then;

/// Create a copy of Coupon
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? enable = null,Object? discountType = null,Object? totalQuota = freezed,Object? usableEndTime = freezed,Object? status = null,Object? discountAmount = freezed,Object? discountPercent = freezed,Object? minOrderAmount = freezed,Object? code = freezed,Object? scopes = null,}) {
  return _then(_Coupon(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,enable: null == enable ? _self.enable : enable // ignore: cast_nullable_to_non_nullable
as int,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as int,totalQuota: freezed == totalQuota ? _self.totalQuota : totalQuota // ignore: cast_nullable_to_non_nullable
as int?,usableEndTime: freezed == usableEndTime ? _self.usableEndTime : usableEndTime // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as double?,discountPercent: freezed == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as double?,minOrderAmount: freezed == minOrderAmount ? _self.minOrderAmount : minOrderAmount // ignore: cast_nullable_to_non_nullable
as double?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,scopes: null == scopes ? _self._scopes : scopes // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

// dart format on
