// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart_api.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CartApi {

 int get id; int get skuCount; double get subtotal; double get discount; double get total; List<CartApiItem> get items;/// `false` when the merchant disables 棄標 (member abandon). When
/// false, the UI must hide the per-item delete affordance — the
/// destroy endpoint will return `20313: 無法移除購物車項目` if called.
 bool get canAbandon; String get createdAt; String get updatedAt;
/// Create a copy of CartApi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartApiCopyWith<CartApi> get copyWith => _$CartApiCopyWithImpl<CartApi>(this as CartApi, _$identity);

  /// Serializes this CartApi to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartApi&&(identical(other.id, id) || other.id == id)&&(identical(other.skuCount, skuCount) || other.skuCount == skuCount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.canAbandon, canAbandon) || other.canAbandon == canAbandon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,skuCount,subtotal,discount,total,const DeepCollectionEquality().hash(items),canAbandon,createdAt,updatedAt);

@override
String toString() {
  return 'CartApi(id: $id, skuCount: $skuCount, subtotal: $subtotal, discount: $discount, total: $total, items: $items, canAbandon: $canAbandon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CartApiCopyWith<$Res>  {
  factory $CartApiCopyWith(CartApi value, $Res Function(CartApi) _then) = _$CartApiCopyWithImpl;
@useResult
$Res call({
 int id, int skuCount, double subtotal, double discount, double total, List<CartApiItem> items, bool canAbandon, String createdAt, String updatedAt
});




}
/// @nodoc
class _$CartApiCopyWithImpl<$Res>
    implements $CartApiCopyWith<$Res> {
  _$CartApiCopyWithImpl(this._self, this._then);

  final CartApi _self;
  final $Res Function(CartApi) _then;

/// Create a copy of CartApi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? skuCount = null,Object? subtotal = null,Object? discount = null,Object? total = null,Object? items = null,Object? canAbandon = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,skuCount: null == skuCount ? _self.skuCount : skuCount // ignore: cast_nullable_to_non_nullable
as int,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartApiItem>,canAbandon: null == canAbandon ? _self.canAbandon : canAbandon // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CartApi].
extension CartApiPatterns on CartApi {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartApi value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartApi() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartApi value)  $default,){
final _that = this;
switch (_that) {
case _CartApi():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartApi value)?  $default,){
final _that = this;
switch (_that) {
case _CartApi() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int skuCount,  double subtotal,  double discount,  double total,  List<CartApiItem> items,  bool canAbandon,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartApi() when $default != null:
return $default(_that.id,_that.skuCount,_that.subtotal,_that.discount,_that.total,_that.items,_that.canAbandon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int skuCount,  double subtotal,  double discount,  double total,  List<CartApiItem> items,  bool canAbandon,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CartApi():
return $default(_that.id,_that.skuCount,_that.subtotal,_that.discount,_that.total,_that.items,_that.canAbandon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int skuCount,  double subtotal,  double discount,  double total,  List<CartApiItem> items,  bool canAbandon,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CartApi() when $default != null:
return $default(_that.id,_that.skuCount,_that.subtotal,_that.discount,_that.total,_that.items,_that.canAbandon,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CartApi implements CartApi {
  const _CartApi({required this.id, required this.skuCount, required this.subtotal, required this.discount, required this.total, final  List<CartApiItem> items = const [], this.canAbandon = true, required this.createdAt, required this.updatedAt}): _items = items;
  factory _CartApi.fromJson(Map<String, dynamic> json) => _$CartApiFromJson(json);

@override final  int id;
@override final  int skuCount;
@override final  double subtotal;
@override final  double discount;
@override final  double total;
 final  List<CartApiItem> _items;
@override@JsonKey() List<CartApiItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

/// `false` when the merchant disables 棄標 (member abandon). When
/// false, the UI must hide the per-item delete affordance — the
/// destroy endpoint will return `20313: 無法移除購物車項目` if called.
@override@JsonKey() final  bool canAbandon;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of CartApi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartApiCopyWith<_CartApi> get copyWith => __$CartApiCopyWithImpl<_CartApi>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartApiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartApi&&(identical(other.id, id) || other.id == id)&&(identical(other.skuCount, skuCount) || other.skuCount == skuCount)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.canAbandon, canAbandon) || other.canAbandon == canAbandon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,skuCount,subtotal,discount,total,const DeepCollectionEquality().hash(_items),canAbandon,createdAt,updatedAt);

@override
String toString() {
  return 'CartApi(id: $id, skuCount: $skuCount, subtotal: $subtotal, discount: $discount, total: $total, items: $items, canAbandon: $canAbandon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CartApiCopyWith<$Res> implements $CartApiCopyWith<$Res> {
  factory _$CartApiCopyWith(_CartApi value, $Res Function(_CartApi) _then) = __$CartApiCopyWithImpl;
@override @useResult
$Res call({
 int id, int skuCount, double subtotal, double discount, double total, List<CartApiItem> items, bool canAbandon, String createdAt, String updatedAt
});




}
/// @nodoc
class __$CartApiCopyWithImpl<$Res>
    implements _$CartApiCopyWith<$Res> {
  __$CartApiCopyWithImpl(this._self, this._then);

  final _CartApi _self;
  final $Res Function(_CartApi) _then;

/// Create a copy of CartApi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? skuCount = null,Object? subtotal = null,Object? discount = null,Object? total = null,Object? items = null,Object? canAbandon = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CartApi(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,skuCount: null == skuCount ? _self.skuCount : skuCount // ignore: cast_nullable_to_non_nullable
as int,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discount: null == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartApiItem>,canAbandon: null == canAbandon ? _self.canAbandon : canAbandon // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CartApiItem {

 int get id; int get cartId; int? get bidId; int? get productId; int? get productVariantId; int get quantity; int get unitPrice; String? get image;@JsonKey(readValue: _readProduct) CartApiProduct get product; String get createdAt; String get updatedAt;
/// Create a copy of CartApiItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartApiItemCopyWith<CartApiItem> get copyWith => _$CartApiItemCopyWithImpl<CartApiItem>(this as CartApiItem, _$identity);

  /// Serializes this CartApiItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartApiItem&&(identical(other.id, id) || other.id == id)&&(identical(other.cartId, cartId) || other.cartId == cartId)&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productVariantId, productVariantId) || other.productVariantId == productVariantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.image, image) || other.image == image)&&(identical(other.product, product) || other.product == product)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cartId,bidId,productId,productVariantId,quantity,unitPrice,image,product,createdAt,updatedAt);

@override
String toString() {
  return 'CartApiItem(id: $id, cartId: $cartId, bidId: $bidId, productId: $productId, productVariantId: $productVariantId, quantity: $quantity, unitPrice: $unitPrice, image: $image, product: $product, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CartApiItemCopyWith<$Res>  {
  factory $CartApiItemCopyWith(CartApiItem value, $Res Function(CartApiItem) _then) = _$CartApiItemCopyWithImpl;
@useResult
$Res call({
 int id, int cartId, int? bidId, int? productId, int? productVariantId, int quantity, int unitPrice, String? image,@JsonKey(readValue: _readProduct) CartApiProduct product, String createdAt, String updatedAt
});


$CartApiProductCopyWith<$Res> get product;

}
/// @nodoc
class _$CartApiItemCopyWithImpl<$Res>
    implements $CartApiItemCopyWith<$Res> {
  _$CartApiItemCopyWithImpl(this._self, this._then);

  final CartApiItem _self;
  final $Res Function(CartApiItem) _then;

/// Create a copy of CartApiItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cartId = null,Object? bidId = freezed,Object? productId = freezed,Object? productVariantId = freezed,Object? quantity = null,Object? unitPrice = null,Object? image = freezed,Object? product = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cartId: null == cartId ? _self.cartId : cartId // ignore: cast_nullable_to_non_nullable
as int,bidId: freezed == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as int?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,productVariantId: freezed == productVariantId ? _self.productVariantId : productVariantId // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as CartApiProduct,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of CartApiItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartApiProductCopyWith<$Res> get product {
  
  return $CartApiProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// Adds pattern-matching-related methods to [CartApiItem].
extension CartApiItemPatterns on CartApiItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartApiItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartApiItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartApiItem value)  $default,){
final _that = this;
switch (_that) {
case _CartApiItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartApiItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartApiItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int cartId,  int? bidId,  int? productId,  int? productVariantId,  int quantity,  int unitPrice,  String? image, @JsonKey(readValue: _readProduct)  CartApiProduct product,  String createdAt,  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartApiItem() when $default != null:
return $default(_that.id,_that.cartId,_that.bidId,_that.productId,_that.productVariantId,_that.quantity,_that.unitPrice,_that.image,_that.product,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int cartId,  int? bidId,  int? productId,  int? productVariantId,  int quantity,  int unitPrice,  String? image, @JsonKey(readValue: _readProduct)  CartApiProduct product,  String createdAt,  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CartApiItem():
return $default(_that.id,_that.cartId,_that.bidId,_that.productId,_that.productVariantId,_that.quantity,_that.unitPrice,_that.image,_that.product,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int cartId,  int? bidId,  int? productId,  int? productVariantId,  int quantity,  int unitPrice,  String? image, @JsonKey(readValue: _readProduct)  CartApiProduct product,  String createdAt,  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CartApiItem() when $default != null:
return $default(_that.id,_that.cartId,_that.bidId,_that.productId,_that.productVariantId,_that.quantity,_that.unitPrice,_that.image,_that.product,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CartApiItem implements CartApiItem {
  const _CartApiItem({required this.id, required this.cartId, this.bidId, this.productId, this.productVariantId, required this.quantity, required this.unitPrice, this.image, @JsonKey(readValue: _readProduct) required this.product, required this.createdAt, required this.updatedAt});
  factory _CartApiItem.fromJson(Map<String, dynamic> json) => _$CartApiItemFromJson(json);

@override final  int id;
@override final  int cartId;
@override final  int? bidId;
@override final  int? productId;
@override final  int? productVariantId;
@override final  int quantity;
@override final  int unitPrice;
@override final  String? image;
@override@JsonKey(readValue: _readProduct) final  CartApiProduct product;
@override final  String createdAt;
@override final  String updatedAt;

/// Create a copy of CartApiItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartApiItemCopyWith<_CartApiItem> get copyWith => __$CartApiItemCopyWithImpl<_CartApiItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartApiItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartApiItem&&(identical(other.id, id) || other.id == id)&&(identical(other.cartId, cartId) || other.cartId == cartId)&&(identical(other.bidId, bidId) || other.bidId == bidId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productVariantId, productVariantId) || other.productVariantId == productVariantId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.image, image) || other.image == image)&&(identical(other.product, product) || other.product == product)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,cartId,bidId,productId,productVariantId,quantity,unitPrice,image,product,createdAt,updatedAt);

@override
String toString() {
  return 'CartApiItem(id: $id, cartId: $cartId, bidId: $bidId, productId: $productId, productVariantId: $productVariantId, quantity: $quantity, unitPrice: $unitPrice, image: $image, product: $product, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CartApiItemCopyWith<$Res> implements $CartApiItemCopyWith<$Res> {
  factory _$CartApiItemCopyWith(_CartApiItem value, $Res Function(_CartApiItem) _then) = __$CartApiItemCopyWithImpl;
@override @useResult
$Res call({
 int id, int cartId, int? bidId, int? productId, int? productVariantId, int quantity, int unitPrice, String? image,@JsonKey(readValue: _readProduct) CartApiProduct product, String createdAt, String updatedAt
});


@override $CartApiProductCopyWith<$Res> get product;

}
/// @nodoc
class __$CartApiItemCopyWithImpl<$Res>
    implements _$CartApiItemCopyWith<$Res> {
  __$CartApiItemCopyWithImpl(this._self, this._then);

  final _CartApiItem _self;
  final $Res Function(_CartApiItem) _then;

/// Create a copy of CartApiItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cartId = null,Object? bidId = freezed,Object? productId = freezed,Object? productVariantId = freezed,Object? quantity = null,Object? unitPrice = null,Object? image = freezed,Object? product = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CartApiItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cartId: null == cartId ? _self.cartId : cartId // ignore: cast_nullable_to_non_nullable
as int,bidId: freezed == bidId ? _self.bidId : bidId // ignore: cast_nullable_to_non_nullable
as int?,productId: freezed == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as int?,productVariantId: freezed == productVariantId ? _self.productVariantId : productVariantId // ignore: cast_nullable_to_non_nullable
as int?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as int,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,product: null == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as CartApiProduct,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of CartApiItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CartApiProductCopyWith<$Res> get product {
  
  return $CartApiProductCopyWith<$Res>(_self.product, (value) {
    return _then(_self.copyWith(product: value));
  });
}
}


/// @nodoc
mixin _$CartApiProduct {

 int? get id; String? get name;
/// Create a copy of CartApiProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartApiProductCopyWith<CartApiProduct> get copyWith => _$CartApiProductCopyWithImpl<CartApiProduct>(this as CartApiProduct, _$identity);

  /// Serializes this CartApiProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartApiProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CartApiProduct(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $CartApiProductCopyWith<$Res>  {
  factory $CartApiProductCopyWith(CartApiProduct value, $Res Function(CartApiProduct) _then) = _$CartApiProductCopyWithImpl;
@useResult
$Res call({
 int? id, String? name
});




}
/// @nodoc
class _$CartApiProductCopyWithImpl<$Res>
    implements $CartApiProductCopyWith<$Res> {
  _$CartApiProductCopyWithImpl(this._self, this._then);

  final CartApiProduct _self;
  final $Res Function(CartApiProduct) _then;

/// Create a copy of CartApiProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartApiProduct].
extension CartApiProductPatterns on CartApiProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartApiProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartApiProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartApiProduct value)  $default,){
final _that = this;
switch (_that) {
case _CartApiProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartApiProduct value)?  $default,){
final _that = this;
switch (_that) {
case _CartApiProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartApiProduct() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name)  $default,) {final _that = this;
switch (_that) {
case _CartApiProduct():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _CartApiProduct() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartApiProduct implements CartApiProduct {
  const _CartApiProduct({this.id, this.name});
  factory _CartApiProduct.fromJson(Map<String, dynamic> json) => _$CartApiProductFromJson(json);

@override final  int? id;
@override final  String? name;

/// Create a copy of CartApiProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartApiProductCopyWith<_CartApiProduct> get copyWith => __$CartApiProductCopyWithImpl<_CartApiProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartApiProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartApiProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'CartApiProduct(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$CartApiProductCopyWith<$Res> implements $CartApiProductCopyWith<$Res> {
  factory _$CartApiProductCopyWith(_CartApiProduct value, $Res Function(_CartApiProduct) _then) = __$CartApiProductCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name
});




}
/// @nodoc
class __$CartApiProductCopyWithImpl<$Res>
    implements _$CartApiProductCopyWith<$Res> {
  __$CartApiProductCopyWithImpl(this._self, this._then);

  final _CartApiProduct _self;
  final $Res Function(_CartApiProduct) _then;

/// Create a copy of CartApiProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_CartApiProduct(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
