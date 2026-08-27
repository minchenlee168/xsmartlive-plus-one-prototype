// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bonus.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BonusBalance {

 int get pointBalance; String get updatedAt; String get expiringPoints; String get expiringAt;
/// Create a copy of BonusBalance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BonusBalanceCopyWith<BonusBalance> get copyWith => _$BonusBalanceCopyWithImpl<BonusBalance>(this as BonusBalance, _$identity);

  /// Serializes this BonusBalance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BonusBalance&&(identical(other.pointBalance, pointBalance) || other.pointBalance == pointBalance)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.expiringPoints, expiringPoints) || other.expiringPoints == expiringPoints)&&(identical(other.expiringAt, expiringAt) || other.expiringAt == expiringAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pointBalance,updatedAt,expiringPoints,expiringAt);

@override
String toString() {
  return 'BonusBalance(pointBalance: $pointBalance, updatedAt: $updatedAt, expiringPoints: $expiringPoints, expiringAt: $expiringAt)';
}


}

/// @nodoc
abstract mixin class $BonusBalanceCopyWith<$Res>  {
  factory $BonusBalanceCopyWith(BonusBalance value, $Res Function(BonusBalance) _then) = _$BonusBalanceCopyWithImpl;
@useResult
$Res call({
 int pointBalance, String updatedAt, String expiringPoints, String expiringAt
});




}
/// @nodoc
class _$BonusBalanceCopyWithImpl<$Res>
    implements $BonusBalanceCopyWith<$Res> {
  _$BonusBalanceCopyWithImpl(this._self, this._then);

  final BonusBalance _self;
  final $Res Function(BonusBalance) _then;

/// Create a copy of BonusBalance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pointBalance = null,Object? updatedAt = null,Object? expiringPoints = null,Object? expiringAt = null,}) {
  return _then(_self.copyWith(
pointBalance: null == pointBalance ? _self.pointBalance : pointBalance // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,expiringPoints: null == expiringPoints ? _self.expiringPoints : expiringPoints // ignore: cast_nullable_to_non_nullable
as String,expiringAt: null == expiringAt ? _self.expiringAt : expiringAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BonusBalance].
extension BonusBalancePatterns on BonusBalance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BonusBalance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BonusBalance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BonusBalance value)  $default,){
final _that = this;
switch (_that) {
case _BonusBalance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BonusBalance value)?  $default,){
final _that = this;
switch (_that) {
case _BonusBalance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pointBalance,  String updatedAt,  String expiringPoints,  String expiringAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BonusBalance() when $default != null:
return $default(_that.pointBalance,_that.updatedAt,_that.expiringPoints,_that.expiringAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pointBalance,  String updatedAt,  String expiringPoints,  String expiringAt)  $default,) {final _that = this;
switch (_that) {
case _BonusBalance():
return $default(_that.pointBalance,_that.updatedAt,_that.expiringPoints,_that.expiringAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pointBalance,  String updatedAt,  String expiringPoints,  String expiringAt)?  $default,) {final _that = this;
switch (_that) {
case _BonusBalance() when $default != null:
return $default(_that.pointBalance,_that.updatedAt,_that.expiringPoints,_that.expiringAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BonusBalance implements BonusBalance {
  const _BonusBalance({required this.pointBalance, required this.updatedAt, required this.expiringPoints, required this.expiringAt});
  factory _BonusBalance.fromJson(Map<String, dynamic> json) => _$BonusBalanceFromJson(json);

@override final  int pointBalance;
@override final  String updatedAt;
@override final  String expiringPoints;
@override final  String expiringAt;

/// Create a copy of BonusBalance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BonusBalanceCopyWith<_BonusBalance> get copyWith => __$BonusBalanceCopyWithImpl<_BonusBalance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BonusBalanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BonusBalance&&(identical(other.pointBalance, pointBalance) || other.pointBalance == pointBalance)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.expiringPoints, expiringPoints) || other.expiringPoints == expiringPoints)&&(identical(other.expiringAt, expiringAt) || other.expiringAt == expiringAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pointBalance,updatedAt,expiringPoints,expiringAt);

@override
String toString() {
  return 'BonusBalance(pointBalance: $pointBalance, updatedAt: $updatedAt, expiringPoints: $expiringPoints, expiringAt: $expiringAt)';
}


}

/// @nodoc
abstract mixin class _$BonusBalanceCopyWith<$Res> implements $BonusBalanceCopyWith<$Res> {
  factory _$BonusBalanceCopyWith(_BonusBalance value, $Res Function(_BonusBalance) _then) = __$BonusBalanceCopyWithImpl;
@override @useResult
$Res call({
 int pointBalance, String updatedAt, String expiringPoints, String expiringAt
});




}
/// @nodoc
class __$BonusBalanceCopyWithImpl<$Res>
    implements _$BonusBalanceCopyWith<$Res> {
  __$BonusBalanceCopyWithImpl(this._self, this._then);

  final _BonusBalance _self;
  final $Res Function(_BonusBalance) _then;

/// Create a copy of BonusBalance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pointBalance = null,Object? updatedAt = null,Object? expiringPoints = null,Object? expiringAt = null,}) {
  return _then(_BonusBalance(
pointBalance: null == pointBalance ? _self.pointBalance : pointBalance // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,expiringPoints: null == expiringPoints ? _self.expiringPoints : expiringPoints // ignore: cast_nullable_to_non_nullable
as String,expiringAt: null == expiringAt ? _self.expiringAt : expiringAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$BonusUsage {

 int get id; int get memberId; int get purchaseId; int get pointUsed; double get convertedAmount; String? get note; String get createdAt;
/// Create a copy of BonusUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BonusUsageCopyWith<BonusUsage> get copyWith => _$BonusUsageCopyWithImpl<BonusUsage>(this as BonusUsage, _$identity);

  /// Serializes this BonusUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BonusUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId)&&(identical(other.pointUsed, pointUsed) || other.pointUsed == pointUsed)&&(identical(other.convertedAmount, convertedAmount) || other.convertedAmount == convertedAmount)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,purchaseId,pointUsed,convertedAmount,note,createdAt);

@override
String toString() {
  return 'BonusUsage(id: $id, memberId: $memberId, purchaseId: $purchaseId, pointUsed: $pointUsed, convertedAmount: $convertedAmount, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BonusUsageCopyWith<$Res>  {
  factory $BonusUsageCopyWith(BonusUsage value, $Res Function(BonusUsage) _then) = _$BonusUsageCopyWithImpl;
@useResult
$Res call({
 int id, int memberId, int purchaseId, int pointUsed, double convertedAmount, String? note, String createdAt
});




}
/// @nodoc
class _$BonusUsageCopyWithImpl<$Res>
    implements $BonusUsageCopyWith<$Res> {
  _$BonusUsageCopyWithImpl(this._self, this._then);

  final BonusUsage _self;
  final $Res Function(BonusUsage) _then;

/// Create a copy of BonusUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? purchaseId = null,Object? pointUsed = null,Object? convertedAmount = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as int,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as int,pointUsed: null == pointUsed ? _self.pointUsed : pointUsed // ignore: cast_nullable_to_non_nullable
as int,convertedAmount: null == convertedAmount ? _self.convertedAmount : convertedAmount // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BonusUsage].
extension BonusUsagePatterns on BonusUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BonusUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BonusUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BonusUsage value)  $default,){
final _that = this;
switch (_that) {
case _BonusUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BonusUsage value)?  $default,){
final _that = this;
switch (_that) {
case _BonusUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int memberId,  int purchaseId,  int pointUsed,  double convertedAmount,  String? note,  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BonusUsage() when $default != null:
return $default(_that.id,_that.memberId,_that.purchaseId,_that.pointUsed,_that.convertedAmount,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int memberId,  int purchaseId,  int pointUsed,  double convertedAmount,  String? note,  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _BonusUsage():
return $default(_that.id,_that.memberId,_that.purchaseId,_that.pointUsed,_that.convertedAmount,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int memberId,  int purchaseId,  int pointUsed,  double convertedAmount,  String? note,  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BonusUsage() when $default != null:
return $default(_that.id,_that.memberId,_that.purchaseId,_that.pointUsed,_that.convertedAmount,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BonusUsage implements BonusUsage {
  const _BonusUsage({required this.id, required this.memberId, required this.purchaseId, required this.pointUsed, required this.convertedAmount, this.note, required this.createdAt});
  factory _BonusUsage.fromJson(Map<String, dynamic> json) => _$BonusUsageFromJson(json);

@override final  int id;
@override final  int memberId;
@override final  int purchaseId;
@override final  int pointUsed;
@override final  double convertedAmount;
@override final  String? note;
@override final  String createdAt;

/// Create a copy of BonusUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BonusUsageCopyWith<_BonusUsage> get copyWith => __$BonusUsageCopyWithImpl<_BonusUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BonusUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BonusUsage&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.purchaseId, purchaseId) || other.purchaseId == purchaseId)&&(identical(other.pointUsed, pointUsed) || other.pointUsed == pointUsed)&&(identical(other.convertedAmount, convertedAmount) || other.convertedAmount == convertedAmount)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,purchaseId,pointUsed,convertedAmount,note,createdAt);

@override
String toString() {
  return 'BonusUsage(id: $id, memberId: $memberId, purchaseId: $purchaseId, pointUsed: $pointUsed, convertedAmount: $convertedAmount, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BonusUsageCopyWith<$Res> implements $BonusUsageCopyWith<$Res> {
  factory _$BonusUsageCopyWith(_BonusUsage value, $Res Function(_BonusUsage) _then) = __$BonusUsageCopyWithImpl;
@override @useResult
$Res call({
 int id, int memberId, int purchaseId, int pointUsed, double convertedAmount, String? note, String createdAt
});




}
/// @nodoc
class __$BonusUsageCopyWithImpl<$Res>
    implements _$BonusUsageCopyWith<$Res> {
  __$BonusUsageCopyWithImpl(this._self, this._then);

  final _BonusUsage _self;
  final $Res Function(_BonusUsage) _then;

/// Create a copy of BonusUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? purchaseId = null,Object? pointUsed = null,Object? convertedAmount = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_BonusUsage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as int,purchaseId: null == purchaseId ? _self.purchaseId : purchaseId // ignore: cast_nullable_to_non_nullable
as int,pointUsed: null == pointUsed ? _self.pointUsed : pointUsed // ignore: cast_nullable_to_non_nullable
as int,convertedAmount: null == convertedAmount ? _self.convertedAmount : convertedAmount // ignore: cast_nullable_to_non_nullable
as double,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
