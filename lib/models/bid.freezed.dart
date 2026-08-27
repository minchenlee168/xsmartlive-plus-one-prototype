// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bid {

 int get id; int get storeId; int get memberId; int get marketId; int get productCardId; int get productId; String get productName; int get productVariantId; int get quantity; int get unitPrice; int get totalAmount; String? get remark; bool get isAbandoned; String get createdAt; String get updatedAt;
/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BidCopyWith<Bid> get copyWith => _$BidCopyWithImpl<Bid>(this as Bid, _$identity);

  /// Serializes this Bid to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.productCardId, productCardId) || other.productCardId == productCardId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productVariantId, productVariantId) || other.productVariantId == productVariantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.remark, remark) || other.remark == remark)&&(identical(other.isAbandoned, isAbandoned) || other.isAbandoned == isAbandoned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,memberId,marketId,productCardId,productId,productName,productVariantId,quantity,unitPrice,totalAmount,remark,isAbandoned,createdAt,updatedAt);

@override
String toString() {
  return 'Bid(id: $id, storeId: $storeId, memberId: $memberId, marketId: $marketId, productCardId: $productCardId, productId: $productId, productName: $productName, productVariantId: $productVariantId, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount, remark: $remark, isAbandoned: $isAbandoned, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BidCopyWith<$Res>  {
  factory $BidCopyWith(Bid value, $Res Function(Bid) _then) = _$BidCopyWithImpl;
@useResult
$Res call({
 int id, int storeId, int memberId, int marketId, int productCardId, int productId, String productName, int productVariantId, int quantity, int unitPrice, int totalAmount, String? remark, bool isAbandoned, String createdAt, String updatedAt
});




}
/// @nodoc
class _$BidCopyWithImpl<$Res>
    implements $BidCopyWith<$Res> {
  _$BidCopyWithImpl(this._self, this._then);

  final Bid _self;
  final $Res Function(Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? storeId = null,Object? memberId = null,Object? marketId = null,Object? productCardId = null,Object? productId = null,Object? productName = null,Object? productVariantId = null,Object? quantity = null,Object? unitPrice = null,Object? totalAmount = null,Object? remark = freezed,Object? isAbandoned = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as int,marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,productCardId: null == productCardId ? _self.productCardId : productCardId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productVariantId: null == productVariantId ? _self.productVariantId : productVariantId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,remark: freezed == remark ? _self.remark : remark // ignore: cast_nullable_to_non_nullable
as String?,isAbandoned: null == isAbandoned ? _self.isAbandoned : isAbandoned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Bid].
extension BidPatterns on Bid {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bid value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bid value)  $default,){
final _that = this;
switch (_that) {
case _Bid():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bid value)?  $default,){
final _that = this;
switch (_that) {
case _Bid() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int storeId,  int memberId,  int marketId,  int productCardId,  int productId,  String productName,  int productVariantId,  int quantity,  int unitPrice,  int totalAmount,  String? remark,  bool isAbandoned,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.storeId,_that.memberId,_that.marketId,_that.productCardId,_that.productId,_that.productName,_that.productVariantId,_that.quantity,_that.unitPrice,_that.totalAmount,_that.remark,_that.isAbandoned,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int storeId,  int memberId,  int marketId,  int productCardId,  int productId,  String productName,  int productVariantId,  int quantity,  int unitPrice,  int totalAmount,  String? remark,  bool isAbandoned,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Bid():
return $default(_that.id,_that.storeId,_that.memberId,_that.marketId,_that.productCardId,_that.productId,_that.productName,_that.productVariantId,_that.quantity,_that.unitPrice,_that.totalAmount,_that.remark,_that.isAbandoned,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int storeId,  int memberId,  int marketId,  int productCardId,  int productId,  String productName,  int productVariantId,  int quantity,  int unitPrice,  int totalAmount,  String? remark,  bool isAbandoned,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Bid() when $default != null:
return $default(_that.id,_that.storeId,_that.memberId,_that.marketId,_that.productCardId,_that.productId,_that.productName,_that.productVariantId,_that.quantity,_that.unitPrice,_that.totalAmount,_that.remark,_that.isAbandoned,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bid implements Bid {
  const _Bid({required this.id, required this.storeId, required this.memberId, required this.marketId, required this.productCardId, required this.productId, required this.productName, required this.productVariantId, required this.quantity, required this.unitPrice, required this.totalAmount, this.remark, this.isAbandoned = false, required this.createdAt, required this.updatedAt});
  factory _Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

@override final  int id;
@override final  int storeId;
@override final  int memberId;
@override final  int marketId;
@override final  int productCardId;
@override final  int productId;
@override final  String productName;
@override final  int productVariantId;
@override final  int quantity;
@override final  int unitPrice;
@override final  int totalAmount;
@override final  String? remark;
@override@JsonKey() final  bool isAbandoned;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BidCopyWith<_Bid> get copyWith => __$BidCopyWithImpl<_Bid>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BidToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bid&&(identical(other.id, id) || other.id == id)&&(identical(other.storeId, storeId) || other.storeId == storeId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.marketId, marketId) || other.marketId == marketId)&&(identical(other.productCardId, productCardId) || other.productCardId == productCardId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productVariantId, productVariantId) || other.productVariantId == productVariantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.remark, remark) || other.remark == remark)&&(identical(other.isAbandoned, isAbandoned) || other.isAbandoned == isAbandoned)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,storeId,memberId,marketId,productCardId,productId,productName,productVariantId,quantity,unitPrice,totalAmount,remark,isAbandoned,createdAt,updatedAt);

@override
String toString() {
  return 'Bid(id: $id, storeId: $storeId, memberId: $memberId, marketId: $marketId, productCardId: $productCardId, productId: $productId, productName: $productName, productVariantId: $productVariantId, quantity: $quantity, unitPrice: $unitPrice, totalAmount: $totalAmount, remark: $remark, isAbandoned: $isAbandoned, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BidCopyWith<$Res> implements $BidCopyWith<$Res> {
  factory _$BidCopyWith(_Bid value, $Res Function(_Bid) _then) = __$BidCopyWithImpl;
@override @useResult
$Res call({
 int id, int storeId, int memberId, int marketId, int productCardId, int productId, String productName, int productVariantId, int quantity, int unitPrice, int totalAmount, String? remark, bool isAbandoned, String createdAt, String updatedAt
});




}
/// @nodoc
class __$BidCopyWithImpl<$Res>
    implements _$BidCopyWith<$Res> {
  __$BidCopyWithImpl(this._self, this._then);

  final _Bid _self;
  final $Res Function(_Bid) _then;

/// Create a copy of Bid
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? storeId = null,Object? memberId = null,Object? marketId = null,Object? productCardId = null,Object? productId = null,Object? productName = null,Object? productVariantId = null,Object? quantity = null,Object? unitPrice = null,Object? totalAmount = null,Object? remark = freezed,Object? isAbandoned = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Bid(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,storeId: null == storeId ? _self.storeId : storeId // ignore: cast_nullable_to_non_nullable
as int,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as int,marketId: null == marketId ? _self.marketId : marketId // ignore: cast_nullable_to_non_nullable
as int,productCardId: null == productCardId ? _self.productCardId : productCardId // ignore: cast_nullable_to_non_nullable
as int,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productVariantId: null == productVariantId ? _self.productVariantId : productVariantId // ignore: cast_nullable_to_non_nullable
as int,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,remark: freezed == remark ? _self.remark : remark // ignore: cast_nullable_to_non_nullable
as String?,isAbandoned: null == isAbandoned ? _self.isAbandoned : isAbandoned // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
