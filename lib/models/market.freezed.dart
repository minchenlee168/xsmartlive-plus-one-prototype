// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'market.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Market {

 int get id; int get storeId; int get marketType; String get marketTypeLabel; String? get name; int get purchaseCount; int get totalAmount; bool get isActive; String get startedAt; String get endedAt; String get createdAt; String get updatedAt;
/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarketCopyWith<Market> get copyWith => _$MarketCopyWithImpl<Market>(this as Market, _$identity);

  /// Serializes this Market to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Market&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.marketType, marketType) || other.marketType == marketType)&&(identical(other.marketTypeLabel, marketTypeLabel) || other.marketTypeLabel == marketTypeLabel)&&(identical(other.name, name) || other.name == name)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,marketType,marketTypeLabel,name,purchaseCount,totalAmount,isActive,startedAt,endedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Market(id: $id, storeId: $storeId, marketType: $marketType, marketTypeLabel: $marketTypeLabel, name: $name, purchaseCount: $purchaseCount, totalAmount: $totalAmount, isActive: $isActive, startedAt: $startedAt, endedAt: $endedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MarketCopyWith<$Res>  {
  factory $MarketCopyWith(Market value, $Res Function(Market) _then) = _$MarketCopyWithImpl;
@useResult
$Res call({
 int id, int storeId, int marketType, String marketTypeLabel, String? name, int purchaseCount, int totalAmount, bool isActive, String startedAt, String endedAt, String createdAt, String updatedAt
});




}
/// @nodoc
class _$MarketCopyWithImpl<$Res>
    implements $MarketCopyWith<$Res> {
  _$MarketCopyWithImpl(this._self, this._then);

  final Market _self;
  final $Res Function(Market) _then;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? marketType = null,Object? marketTypeLabel = null,Object? name = freezed,Object? purchaseCount = null,Object? totalAmount = null,Object? isActive = null,Object? startedAt = null,Object? endedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,marketType: null == marketType ? _self.marketType : marketType // ignore: cast_nullable_to_non_nullable
as int,marketTypeLabel: null == marketTypeLabel ? _self.marketTypeLabel : marketTypeLabel // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Market].
extension MarketPatterns on Market {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Market value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Market() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Market value)  $default,){
final _that = this;
switch (_that) {
case _Market():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Market value)?  $default,){
final _that = this;
switch (_that) {
case _Market() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int storeId,  int marketType,  String marketTypeLabel,  String? name,  int purchaseCount,  int totalAmount,  bool isActive,  String startedAt,  String endedAt,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Market() when $default != null:
return $default(_that.id,_that.storeId,_that.marketType,_that.marketTypeLabel,_that.name,_that.purchaseCount,_that.totalAmount,_that.isActive,_that.startedAt,_that.endedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int storeId,  int marketType,  String marketTypeLabel,  String? name,  int purchaseCount,  int totalAmount,  bool isActive,  String startedAt,  String endedAt,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Market():
return $default(_that.id,_that.storeId,_that.marketType,_that.marketTypeLabel,_that.name,_that.purchaseCount,_that.totalAmount,_that.isActive,_that.startedAt,_that.endedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int storeId,  int marketType,  String marketTypeLabel,  String? name,  int purchaseCount,  int totalAmount,  bool isActive,  String startedAt,  String endedAt,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Market() when $default != null:
return $default(_that.id,_that.storeId,_that.marketType,_that.marketTypeLabel,_that.name,_that.purchaseCount,_that.totalAmount,_that.isActive,_that.startedAt,_that.endedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Market implements Market {
  const _Market({required this.id, required this.storeId, required this.marketType, required this.marketTypeLabel, this.name, this.purchaseCount = 0, this.totalAmount = 0, this.isActive = false, required this.startedAt, required this.endedAt, required this.createdAt, required this.updatedAt});
  factory _Market.fromJson(Map<String, dynamic> json) => _$MarketFromJson(json);

@override final  int id;
@override final  int storeId;
@override final  int marketType;
@override final  String marketTypeLabel;
@override final  String? name;
@override@JsonKey() final  int purchaseCount;
@override@JsonKey() final  int totalAmount;
@override@JsonKey() final  bool isActive;
@override final  String startedAt;
@override final  String endedAt;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MarketCopyWith<_Market> get copyWith => __$MarketCopyWithImpl<_Market>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MarketToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Market&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.marketType, marketType) || other.marketType == marketType)&&(identical(other.marketTypeLabel, marketTypeLabel) || other.marketTypeLabel == marketTypeLabel)&&(identical(other.name, name) || other.name == name)&&(identical(other.purchaseCount, purchaseCount) || other.purchaseCount == purchaseCount)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,marketType,marketTypeLabel,name,purchaseCount,totalAmount,isActive,startedAt,endedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Market(id: $id, storeId: $storeId, marketType: $marketType, marketTypeLabel: $marketTypeLabel, name: $name, purchaseCount: $purchaseCount, totalAmount: $totalAmount, isActive: $isActive, startedAt: $startedAt, endedAt: $endedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MarketCopyWith<$Res> implements $MarketCopyWith<$Res> {
  factory _$MarketCopyWith(_Market value, $Res Function(_Market) _then) = __$MarketCopyWithImpl;
@override @useResult
$Res call({
 int id, int storeId, int marketType, String marketTypeLabel, String? name, int purchaseCount, int totalAmount, bool isActive, String startedAt, String endedAt, String createdAt, String updatedAt
});




}
/// @nodoc
class __$MarketCopyWithImpl<$Res>
    implements _$MarketCopyWith<$Res> {
  __$MarketCopyWithImpl(this._self, this._then);

  final _Market _self;
  final $Res Function(_Market) _then;

/// Create a copy of Market
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? marketType = null,Object? marketTypeLabel = null,Object? name = freezed,Object? purchaseCount = null,Object? totalAmount = null,Object? isActive = null,Object? startedAt = null,Object? endedAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Market(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,marketType: null == marketType ? _self.marketType : marketType // ignore: cast_nullable_to_non_nullable
as int,marketTypeLabel: null == marketTypeLabel ? _self.marketTypeLabel : marketTypeLabel // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,purchaseCount: null == purchaseCount ? _self.purchaseCount : purchaseCount // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as String,endedAt: null == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
