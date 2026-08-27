// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Purchase {

 int get id; String get createdAt; int get itemCount; num get amount; String? get paymentMethod; String? get shippingMethod; String? get mallType; String? get status;
/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseCopyWith<Purchase> get copyWith => _$PurchaseCopyWithImpl<Purchase>(this as Purchase, _$identity);

  /// Serializes this Purchase to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Purchase&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.mallType, mallType) || other.mallType == mallType)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,itemCount,amount,paymentMethod,shippingMethod,mallType,status);

@override
String toString() {
  return 'Purchase(id: $id, createdAt: $createdAt, itemCount: $itemCount, amount: $amount, paymentMethod: $paymentMethod, shippingMethod: $shippingMethod, mallType: $mallType, status: $status)';
}


}

/// @nodoc
abstract mixin class $PurchaseCopyWith<$Res>  {
  factory $PurchaseCopyWith(Purchase value, $Res Function(Purchase) _then) = _$PurchaseCopyWithImpl;
@useResult
$Res call({
 int id, String createdAt, int itemCount, num amount, String? paymentMethod, String? shippingMethod, String? mallType, String? status
});




}
/// @nodoc
class _$PurchaseCopyWithImpl<$Res>
    implements $PurchaseCopyWith<$Res> {
  _$PurchaseCopyWithImpl(this._self, this._then);

  final Purchase _self;
  final $Res Function(Purchase) _then;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? itemCount = null,Object? amount = null,Object? paymentMethod = freezed,Object? shippingMethod = freezed,Object? mallType = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,mallType: freezed == mallType ? _self.mallType : mallType // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Purchase].
extension PurchasePatterns on Purchase {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Purchase value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Purchase() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Purchase value)  $default,){
final _that = this;
switch (_that) {
case _Purchase():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Purchase value)?  $default,){
final _that = this;
switch (_that) {
case _Purchase() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String createdAt,  int itemCount,  num amount,  String? paymentMethod,  String? shippingMethod,  String? mallType,  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Purchase() when $default != null:
return $default(_that.id,_that.createdAt,_that.itemCount,_that.amount,_that.paymentMethod,_that.shippingMethod,_that.mallType,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String createdAt,  int itemCount,  num amount,  String? paymentMethod,  String? shippingMethod,  String? mallType,  String? status)  $default,) {final _that = this;
switch (_that) {
case _Purchase():
return $default(_that.id,_that.createdAt,_that.itemCount,_that.amount,_that.paymentMethod,_that.shippingMethod,_that.mallType,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String createdAt,  int itemCount,  num amount,  String? paymentMethod,  String? shippingMethod,  String? mallType,  String? status)?  $default,) {final _that = this;
switch (_that) {
case _Purchase() when $default != null:
return $default(_that.id,_that.createdAt,_that.itemCount,_that.amount,_that.paymentMethod,_that.shippingMethod,_that.mallType,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Purchase implements Purchase {
  const _Purchase({required this.id, required this.createdAt, required this.itemCount, required this.amount, this.paymentMethod, this.shippingMethod, this.mallType, this.status});
  factory _Purchase.fromJson(Map<String, dynamic> json) => _$PurchaseFromJson(json);

@override final  int id;
@override final  String createdAt;
@override final  int itemCount;
@override final  num amount;
@override final  String? paymentMethod;
@override final  String? shippingMethod;
@override final  String? mallType;
@override final  String? status;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseCopyWith<_Purchase> get copyWith => __$PurchaseCopyWithImpl<_Purchase>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Purchase&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.shippingMethod, shippingMethod) || other.shippingMethod == shippingMethod)&&(identical(other.mallType, mallType) || other.mallType == mallType)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,itemCount,amount,paymentMethod,shippingMethod,mallType,status);

@override
String toString() {
  return 'Purchase(id: $id, createdAt: $createdAt, itemCount: $itemCount, amount: $amount, paymentMethod: $paymentMethod, shippingMethod: $shippingMethod, mallType: $mallType, status: $status)';
}


}

/// @nodoc
abstract mixin class _$PurchaseCopyWith<$Res> implements $PurchaseCopyWith<$Res> {
  factory _$PurchaseCopyWith(_Purchase value, $Res Function(_Purchase) _then) = __$PurchaseCopyWithImpl;
@override @useResult
$Res call({
 int id, String createdAt, int itemCount, num amount, String? paymentMethod, String? shippingMethod, String? mallType, String? status
});




}
/// @nodoc
class __$PurchaseCopyWithImpl<$Res>
    implements _$PurchaseCopyWith<$Res> {
  __$PurchaseCopyWithImpl(this._self, this._then);

  final _Purchase _self;
  final $Res Function(_Purchase) _then;

/// Create a copy of Purchase
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? itemCount = null,Object? amount = null,Object? paymentMethod = freezed,Object? shippingMethod = freezed,Object? mallType = freezed,Object? status = freezed,}) {
  return _then(_Purchase(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,shippingMethod: freezed == shippingMethod ? _self.shippingMethod : shippingMethod // ignore: cast_nullable_to_non_nullable
as String?,mallType: freezed == mallType ? _self.mallType : mallType // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PurchaseCollection {

 List<Purchase> get data; PurchasePagination? get meta;
/// Create a copy of PurchaseCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseCollectionCopyWith<PurchaseCollection> get copyWith => _$PurchaseCollectionCopyWithImpl<PurchaseCollection>(this as PurchaseCollection, _$identity);

  /// Serializes this PurchaseCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseCollection&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),meta);

@override
String toString() {
  return 'PurchaseCollection(data: $data, meta: $meta)';
}


}

/// @nodoc
abstract mixin class $PurchaseCollectionCopyWith<$Res>  {
  factory $PurchaseCollectionCopyWith(PurchaseCollection value, $Res Function(PurchaseCollection) _then) = _$PurchaseCollectionCopyWithImpl;
@useResult
$Res call({
 List<Purchase> data, PurchasePagination? meta
});


$PurchasePaginationCopyWith<$Res>? get meta;

}
/// @nodoc
class _$PurchaseCollectionCopyWithImpl<$Res>
    implements $PurchaseCollectionCopyWith<$Res> {
  _$PurchaseCollectionCopyWithImpl(this._self, this._then);

  final PurchaseCollection _self;
  final $Res Function(PurchaseCollection) _then;

/// Create a copy of PurchaseCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? meta = freezed,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as List<Purchase>,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PurchasePagination?,
  ));
}
/// Create a copy of PurchaseCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchasePaginationCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $PurchasePaginationCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// Adds pattern-matching-related methods to [PurchaseCollection].
extension PurchaseCollectionPatterns on PurchaseCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseCollection value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseCollection value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Purchase> data,  PurchasePagination? meta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseCollection() when $default != null:
return $default(_that.data,_that.meta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Purchase> data,  PurchasePagination? meta)  $default,) {final _that = this;
switch (_that) {
case _PurchaseCollection():
return $default(_that.data,_that.meta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Purchase> data,  PurchasePagination? meta)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseCollection() when $default != null:
return $default(_that.data,_that.meta);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseCollection implements PurchaseCollection {
  const _PurchaseCollection({required final  List<Purchase> data, this.meta}): _data = data;
  factory _PurchaseCollection.fromJson(Map<String, dynamic> json) => _$PurchaseCollectionFromJson(json);

 final  List<Purchase> _data;
@override List<Purchase> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}

@override final  PurchasePagination? meta;

/// Create a copy of PurchaseCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseCollectionCopyWith<_PurchaseCollection> get copyWith => __$PurchaseCollectionCopyWithImpl<_PurchaseCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseCollection&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.meta, meta) || other.meta == meta));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),meta);

@override
String toString() {
  return 'PurchaseCollection(data: $data, meta: $meta)';
}


}

/// @nodoc
abstract mixin class _$PurchaseCollectionCopyWith<$Res> implements $PurchaseCollectionCopyWith<$Res> {
  factory _$PurchaseCollectionCopyWith(_PurchaseCollection value, $Res Function(_PurchaseCollection) _then) = __$PurchaseCollectionCopyWithImpl;
@override @useResult
$Res call({
 List<Purchase> data, PurchasePagination? meta
});


@override $PurchasePaginationCopyWith<$Res>? get meta;

}
/// @nodoc
class __$PurchaseCollectionCopyWithImpl<$Res>
    implements _$PurchaseCollectionCopyWith<$Res> {
  __$PurchaseCollectionCopyWithImpl(this._self, this._then);

  final _PurchaseCollection _self;
  final $Res Function(_PurchaseCollection) _then;

/// Create a copy of PurchaseCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? meta = freezed,}) {
  return _then(_PurchaseCollection(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<Purchase>,meta: freezed == meta ? _self.meta : meta // ignore: cast_nullable_to_non_nullable
as PurchasePagination?,
  ));
}

/// Create a copy of PurchaseCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchasePaginationCopyWith<$Res>? get meta {
    if (_self.meta == null) {
    return null;
  }

  return $PurchasePaginationCopyWith<$Res>(_self.meta!, (value) {
    return _then(_self.copyWith(meta: value));
  });
}
}


/// @nodoc
mixin _$PurchasePagination {

 String get currentPage; String get pageSize; String get totalPages; String get totalNumber;
/// Create a copy of PurchasePagination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchasePaginationCopyWith<PurchasePagination> get copyWith => _$PurchasePaginationCopyWithImpl<PurchasePagination>(this as PurchasePagination, _$identity);

  /// Serializes this PurchasePagination to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchasePagination&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalNumber, totalNumber) || other.totalNumber == totalNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,pageSize,totalPages,totalNumber);

@override
String toString() {
  return 'PurchasePagination(currentPage: $currentPage, pageSize: $pageSize, totalPages: $totalPages, totalNumber: $totalNumber)';
}


}

/// @nodoc
abstract mixin class $PurchasePaginationCopyWith<$Res>  {
  factory $PurchasePaginationCopyWith(PurchasePagination value, $Res Function(PurchasePagination) _then) = _$PurchasePaginationCopyWithImpl;
@useResult
$Res call({
 String currentPage, String pageSize, String totalPages, String totalNumber
});




}
/// @nodoc
class _$PurchasePaginationCopyWithImpl<$Res>
    implements $PurchasePaginationCopyWith<$Res> {
  _$PurchasePaginationCopyWithImpl(this._self, this._then);

  final PurchasePagination _self;
  final $Res Function(PurchasePagination) _then;

/// Create a copy of PurchasePagination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPage = null,Object? pageSize = null,Object? totalPages = null,Object? totalNumber = null,}) {
  return _then(_self.copyWith(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as String,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as String,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as String,totalNumber: null == totalNumber ? _self.totalNumber : totalNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchasePagination].
extension PurchasePaginationPatterns on PurchasePagination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchasePagination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchasePagination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchasePagination value)  $default,){
final _that = this;
switch (_that) {
case _PurchasePagination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchasePagination value)?  $default,){
final _that = this;
switch (_that) {
case _PurchasePagination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentPage,  String pageSize,  String totalPages,  String totalNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchasePagination() when $default != null:
return $default(_that.currentPage,_that.pageSize,_that.totalPages,_that.totalNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentPage,  String pageSize,  String totalPages,  String totalNumber)  $default,) {final _that = this;
switch (_that) {
case _PurchasePagination():
return $default(_that.currentPage,_that.pageSize,_that.totalPages,_that.totalNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentPage,  String pageSize,  String totalPages,  String totalNumber)?  $default,) {final _that = this;
switch (_that) {
case _PurchasePagination() when $default != null:
return $default(_that.currentPage,_that.pageSize,_that.totalPages,_that.totalNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchasePagination implements PurchasePagination {
  const _PurchasePagination({required this.currentPage, required this.pageSize, required this.totalPages, required this.totalNumber});
  factory _PurchasePagination.fromJson(Map<String, dynamic> json) => _$PurchasePaginationFromJson(json);

@override final  String currentPage;
@override final  String pageSize;
@override final  String totalPages;
@override final  String totalNumber;

/// Create a copy of PurchasePagination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchasePaginationCopyWith<_PurchasePagination> get copyWith => __$PurchasePaginationCopyWithImpl<_PurchasePagination>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchasePaginationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchasePagination&&(identical(other.currentPage, currentPage) || other.currentPage == currentPage)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalNumber, totalNumber) || other.totalNumber == totalNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currentPage,pageSize,totalPages,totalNumber);

@override
String toString() {
  return 'PurchasePagination(currentPage: $currentPage, pageSize: $pageSize, totalPages: $totalPages, totalNumber: $totalNumber)';
}


}

/// @nodoc
abstract mixin class _$PurchasePaginationCopyWith<$Res> implements $PurchasePaginationCopyWith<$Res> {
  factory _$PurchasePaginationCopyWith(_PurchasePagination value, $Res Function(_PurchasePagination) _then) = __$PurchasePaginationCopyWithImpl;
@override @useResult
$Res call({
 String currentPage, String pageSize, String totalPages, String totalNumber
});




}
/// @nodoc
class __$PurchasePaginationCopyWithImpl<$Res>
    implements _$PurchasePaginationCopyWith<$Res> {
  __$PurchasePaginationCopyWithImpl(this._self, this._then);

  final _PurchasePagination _self;
  final $Res Function(_PurchasePagination) _then;

/// Create a copy of PurchasePagination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPage = null,Object? pageSize = null,Object? totalPages = null,Object? totalNumber = null,}) {
  return _then(_PurchasePagination(
currentPage: null == currentPage ? _self.currentPage : currentPage // ignore: cast_nullable_to_non_nullable
as String,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as String,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as String,totalNumber: null == totalNumber ? _self.totalNumber : totalNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PurchaseDetail {

 int get id; List<PurchaseDetailItem> get items; PurchaseShipment? get shipment;
/// Create a copy of PurchaseDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseDetailCopyWith<PurchaseDetail> get copyWith => _$PurchaseDetailCopyWithImpl<PurchaseDetail>(this as PurchaseDetail, _$identity);

  /// Serializes this PurchaseDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseDetail&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.shipment, shipment) || other.shipment == shipment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(items),shipment);

@override
String toString() {
  return 'PurchaseDetail(id: $id, items: $items, shipment: $shipment)';
}


}

/// @nodoc
abstract mixin class $PurchaseDetailCopyWith<$Res>  {
  factory $PurchaseDetailCopyWith(PurchaseDetail value, $Res Function(PurchaseDetail) _then) = _$PurchaseDetailCopyWithImpl;
@useResult
$Res call({
 int id, List<PurchaseDetailItem> items, PurchaseShipment? shipment
});


$PurchaseShipmentCopyWith<$Res>? get shipment;

}
/// @nodoc
class _$PurchaseDetailCopyWithImpl<$Res>
    implements $PurchaseDetailCopyWith<$Res> {
  _$PurchaseDetailCopyWithImpl(this._self, this._then);

  final PurchaseDetail _self;
  final $Res Function(PurchaseDetail) _then;

/// Create a copy of PurchaseDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? shipment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PurchaseDetailItem>,shipment: freezed == shipment ? _self.shipment : shipment // ignore: cast_nullable_to_non_nullable
as PurchaseShipment?,
  ));
}
/// Create a copy of PurchaseDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchaseShipmentCopyWith<$Res>? get shipment {
    if (_self.shipment == null) {
    return null;
  }

  return $PurchaseShipmentCopyWith<$Res>(_self.shipment!, (value) {
    return _then(_self.copyWith(shipment: value));
  });
}
}


/// Adds pattern-matching-related methods to [PurchaseDetail].
extension PurchaseDetailPatterns on PurchaseDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseDetail value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  List<PurchaseDetailItem> items,  PurchaseShipment? shipment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseDetail() when $default != null:
return $default(_that.id,_that.items,_that.shipment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  List<PurchaseDetailItem> items,  PurchaseShipment? shipment)  $default,) {final _that = this;
switch (_that) {
case _PurchaseDetail():
return $default(_that.id,_that.items,_that.shipment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  List<PurchaseDetailItem> items,  PurchaseShipment? shipment)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseDetail() when $default != null:
return $default(_that.id,_that.items,_that.shipment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseDetail implements PurchaseDetail {
  const _PurchaseDetail({required this.id, required final  List<PurchaseDetailItem> items, this.shipment}): _items = items;
  factory _PurchaseDetail.fromJson(Map<String, dynamic> json) => _$PurchaseDetailFromJson(json);

@override final  int id;
 final  List<PurchaseDetailItem> _items;
@override List<PurchaseDetailItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  PurchaseShipment? shipment;

/// Create a copy of PurchaseDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseDetailCopyWith<_PurchaseDetail> get copyWith => __$PurchaseDetailCopyWithImpl<_PurchaseDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseDetail&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.shipment, shipment) || other.shipment == shipment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items),shipment);

@override
String toString() {
  return 'PurchaseDetail(id: $id, items: $items, shipment: $shipment)';
}


}

/// @nodoc
abstract mixin class _$PurchaseDetailCopyWith<$Res> implements $PurchaseDetailCopyWith<$Res> {
  factory _$PurchaseDetailCopyWith(_PurchaseDetail value, $Res Function(_PurchaseDetail) _then) = __$PurchaseDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, List<PurchaseDetailItem> items, PurchaseShipment? shipment
});


@override $PurchaseShipmentCopyWith<$Res>? get shipment;

}
/// @nodoc
class __$PurchaseDetailCopyWithImpl<$Res>
    implements _$PurchaseDetailCopyWith<$Res> {
  __$PurchaseDetailCopyWithImpl(this._self, this._then);

  final _PurchaseDetail _self;
  final $Res Function(_PurchaseDetail) _then;

/// Create a copy of PurchaseDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? shipment = freezed,}) {
  return _then(_PurchaseDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PurchaseDetailItem>,shipment: freezed == shipment ? _self.shipment : shipment // ignore: cast_nullable_to_non_nullable
as PurchaseShipment?,
  ));
}

/// Create a copy of PurchaseDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PurchaseShipmentCopyWith<$Res>? get shipment {
    if (_self.shipment == null) {
    return null;
  }

  return $PurchaseShipmentCopyWith<$Res>(_self.shipment!, (value) {
    return _then(_self.copyWith(shipment: value));
  });
}
}


/// @nodoc
mixin _$PurchaseShipment {

 String? get deliveryType; String? get pickupProvider; int? get shippingMethodId; String? get shippingMethodName; String? get recipientName; String? get recipientPhone; String? get recipientAddress; String? get convenienceStoreCode; String? get trackingNo; String? get trackingUrl;
/// Create a copy of PurchaseShipment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseShipmentCopyWith<PurchaseShipment> get copyWith => _$PurchaseShipmentCopyWithImpl<PurchaseShipment>(this as PurchaseShipment, _$identity);

  /// Serializes this PurchaseShipment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseShipment&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.pickupProvider, pickupProvider) || other.pickupProvider == pickupProvider)&&(identical(other.shippingMethodId, shippingMethodId) || other.shippingMethodId == shippingMethodId)&&(identical(other.shippingMethodName, shippingMethodName) || other.shippingMethodName == shippingMethodName)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.recipientPhone, recipientPhone) || other.recipientPhone == recipientPhone)&&(identical(other.recipientAddress, recipientAddress) || other.recipientAddress == recipientAddress)&&(identical(other.convenienceStoreCode, convenienceStoreCode) || other.convenienceStoreCode == convenienceStoreCode)&&(identical(other.trackingNo, trackingNo) || other.trackingNo == trackingNo)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deliveryType,pickupProvider,shippingMethodId,shippingMethodName,recipientName,recipientPhone,recipientAddress,convenienceStoreCode,trackingNo,trackingUrl);

@override
String toString() {
  return 'PurchaseShipment(deliveryType: $deliveryType, pickupProvider: $pickupProvider, shippingMethodId: $shippingMethodId, shippingMethodName: $shippingMethodName, recipientName: $recipientName, recipientPhone: $recipientPhone, recipientAddress: $recipientAddress, convenienceStoreCode: $convenienceStoreCode, trackingNo: $trackingNo, trackingUrl: $trackingUrl)';
}


}

/// @nodoc
abstract mixin class $PurchaseShipmentCopyWith<$Res>  {
  factory $PurchaseShipmentCopyWith(PurchaseShipment value, $Res Function(PurchaseShipment) _then) = _$PurchaseShipmentCopyWithImpl;
@useResult
$Res call({
 String? deliveryType, String? pickupProvider, int? shippingMethodId, String? shippingMethodName, String? recipientName, String? recipientPhone, String? recipientAddress, String? convenienceStoreCode, String? trackingNo, String? trackingUrl
});




}
/// @nodoc
class _$PurchaseShipmentCopyWithImpl<$Res>
    implements $PurchaseShipmentCopyWith<$Res> {
  _$PurchaseShipmentCopyWithImpl(this._self, this._then);

  final PurchaseShipment _self;
  final $Res Function(PurchaseShipment) _then;

/// Create a copy of PurchaseShipment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deliveryType = freezed,Object? pickupProvider = freezed,Object? shippingMethodId = freezed,Object? shippingMethodName = freezed,Object? recipientName = freezed,Object? recipientPhone = freezed,Object? recipientAddress = freezed,Object? convenienceStoreCode = freezed,Object? trackingNo = freezed,Object? trackingUrl = freezed,}) {
  return _then(_self.copyWith(
deliveryType: freezed == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as String?,pickupProvider: freezed == pickupProvider ? _self.pickupProvider : pickupProvider // ignore: cast_nullable_to_non_nullable
as String?,shippingMethodId: freezed == shippingMethodId ? _self.shippingMethodId : shippingMethodId // ignore: cast_nullable_to_non_nullable
as int?,shippingMethodName: freezed == shippingMethodName ? _self.shippingMethodName : shippingMethodName // ignore: cast_nullable_to_non_nullable
as String?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,recipientPhone: freezed == recipientPhone ? _self.recipientPhone : recipientPhone // ignore: cast_nullable_to_non_nullable
as String?,recipientAddress: freezed == recipientAddress ? _self.recipientAddress : recipientAddress // ignore: cast_nullable_to_non_nullable
as String?,convenienceStoreCode: freezed == convenienceStoreCode ? _self.convenienceStoreCode : convenienceStoreCode // ignore: cast_nullable_to_non_nullable
as String?,trackingNo: freezed == trackingNo ? _self.trackingNo : trackingNo // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseShipment].
extension PurchaseShipmentPatterns on PurchaseShipment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseShipment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseShipment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseShipment value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseShipment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseShipment value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseShipment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? deliveryType,  String? pickupProvider,  int? shippingMethodId,  String? shippingMethodName,  String? recipientName,  String? recipientPhone,  String? recipientAddress,  String? convenienceStoreCode,  String? trackingNo,  String? trackingUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseShipment() when $default != null:
return $default(_that.deliveryType,_that.pickupProvider,_that.shippingMethodId,_that.shippingMethodName,_that.recipientName,_that.recipientPhone,_that.recipientAddress,_that.convenienceStoreCode,_that.trackingNo,_that.trackingUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? deliveryType,  String? pickupProvider,  int? shippingMethodId,  String? shippingMethodName,  String? recipientName,  String? recipientPhone,  String? recipientAddress,  String? convenienceStoreCode,  String? trackingNo,  String? trackingUrl)  $default,) {final _that = this;
switch (_that) {
case _PurchaseShipment():
return $default(_that.deliveryType,_that.pickupProvider,_that.shippingMethodId,_that.shippingMethodName,_that.recipientName,_that.recipientPhone,_that.recipientAddress,_that.convenienceStoreCode,_that.trackingNo,_that.trackingUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? deliveryType,  String? pickupProvider,  int? shippingMethodId,  String? shippingMethodName,  String? recipientName,  String? recipientPhone,  String? recipientAddress,  String? convenienceStoreCode,  String? trackingNo,  String? trackingUrl)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseShipment() when $default != null:
return $default(_that.deliveryType,_that.pickupProvider,_that.shippingMethodId,_that.shippingMethodName,_that.recipientName,_that.recipientPhone,_that.recipientAddress,_that.convenienceStoreCode,_that.trackingNo,_that.trackingUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseShipment implements PurchaseShipment {
  const _PurchaseShipment({this.deliveryType, this.pickupProvider, this.shippingMethodId, this.shippingMethodName, this.recipientName, this.recipientPhone, this.recipientAddress, this.convenienceStoreCode, this.trackingNo, this.trackingUrl});
  factory _PurchaseShipment.fromJson(Map<String, dynamic> json) => _$PurchaseShipmentFromJson(json);

@override final  String? deliveryType;
@override final  String? pickupProvider;
@override final  int? shippingMethodId;
@override final  String? shippingMethodName;
@override final  String? recipientName;
@override final  String? recipientPhone;
@override final  String? recipientAddress;
@override final  String? convenienceStoreCode;
@override final  String? trackingNo;
@override final  String? trackingUrl;

/// Create a copy of PurchaseShipment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseShipmentCopyWith<_PurchaseShipment> get copyWith => __$PurchaseShipmentCopyWithImpl<_PurchaseShipment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseShipmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseShipment&&(identical(other.deliveryType, deliveryType) || other.deliveryType == deliveryType)&&(identical(other.pickupProvider, pickupProvider) || other.pickupProvider == pickupProvider)&&(identical(other.shippingMethodId, shippingMethodId) || other.shippingMethodId == shippingMethodId)&&(identical(other.shippingMethodName, shippingMethodName) || other.shippingMethodName == shippingMethodName)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.recipientPhone, recipientPhone) || other.recipientPhone == recipientPhone)&&(identical(other.recipientAddress, recipientAddress) || other.recipientAddress == recipientAddress)&&(identical(other.convenienceStoreCode, convenienceStoreCode) || other.convenienceStoreCode == convenienceStoreCode)&&(identical(other.trackingNo, trackingNo) || other.trackingNo == trackingNo)&&(identical(other.trackingUrl, trackingUrl) || other.trackingUrl == trackingUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deliveryType,pickupProvider,shippingMethodId,shippingMethodName,recipientName,recipientPhone,recipientAddress,convenienceStoreCode,trackingNo,trackingUrl);

@override
String toString() {
  return 'PurchaseShipment(deliveryType: $deliveryType, pickupProvider: $pickupProvider, shippingMethodId: $shippingMethodId, shippingMethodName: $shippingMethodName, recipientName: $recipientName, recipientPhone: $recipientPhone, recipientAddress: $recipientAddress, convenienceStoreCode: $convenienceStoreCode, trackingNo: $trackingNo, trackingUrl: $trackingUrl)';
}


}

/// @nodoc
abstract mixin class _$PurchaseShipmentCopyWith<$Res> implements $PurchaseShipmentCopyWith<$Res> {
  factory _$PurchaseShipmentCopyWith(_PurchaseShipment value, $Res Function(_PurchaseShipment) _then) = __$PurchaseShipmentCopyWithImpl;
@override @useResult
$Res call({
 String? deliveryType, String? pickupProvider, int? shippingMethodId, String? shippingMethodName, String? recipientName, String? recipientPhone, String? recipientAddress, String? convenienceStoreCode, String? trackingNo, String? trackingUrl
});




}
/// @nodoc
class __$PurchaseShipmentCopyWithImpl<$Res>
    implements _$PurchaseShipmentCopyWith<$Res> {
  __$PurchaseShipmentCopyWithImpl(this._self, this._then);

  final _PurchaseShipment _self;
  final $Res Function(_PurchaseShipment) _then;

/// Create a copy of PurchaseShipment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deliveryType = freezed,Object? pickupProvider = freezed,Object? shippingMethodId = freezed,Object? shippingMethodName = freezed,Object? recipientName = freezed,Object? recipientPhone = freezed,Object? recipientAddress = freezed,Object? convenienceStoreCode = freezed,Object? trackingNo = freezed,Object? trackingUrl = freezed,}) {
  return _then(_PurchaseShipment(
deliveryType: freezed == deliveryType ? _self.deliveryType : deliveryType // ignore: cast_nullable_to_non_nullable
as String?,pickupProvider: freezed == pickupProvider ? _self.pickupProvider : pickupProvider // ignore: cast_nullable_to_non_nullable
as String?,shippingMethodId: freezed == shippingMethodId ? _self.shippingMethodId : shippingMethodId // ignore: cast_nullable_to_non_nullable
as int?,shippingMethodName: freezed == shippingMethodName ? _self.shippingMethodName : shippingMethodName // ignore: cast_nullable_to_non_nullable
as String?,recipientName: freezed == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String?,recipientPhone: freezed == recipientPhone ? _self.recipientPhone : recipientPhone // ignore: cast_nullable_to_non_nullable
as String?,recipientAddress: freezed == recipientAddress ? _self.recipientAddress : recipientAddress // ignore: cast_nullable_to_non_nullable
as String?,convenienceStoreCode: freezed == convenienceStoreCode ? _self.convenienceStoreCode : convenienceStoreCode // ignore: cast_nullable_to_non_nullable
as String?,trackingNo: freezed == trackingNo ? _self.trackingNo : trackingNo // ignore: cast_nullable_to_non_nullable
as String?,trackingUrl: freezed == trackingUrl ? _self.trackingUrl : trackingUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PurchaseDetailItem {

 int get id; String? get productName; String? get variantName; String? get imageUrl; num? get unitPrice; int get quantity; List<PurchaseFulfillment> get fulfillments;
/// Create a copy of PurchaseDetailItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseDetailItemCopyWith<PurchaseDetailItem> get copyWith => _$PurchaseDetailItemCopyWithImpl<PurchaseDetailItem>(this as PurchaseDetailItem, _$identity);

  /// Serializes this PurchaseDetailItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseDetailItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.fulfillments, fulfillments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName,variantName,imageUrl,unitPrice,quantity,const DeepCollectionEquality().hash(fulfillments));

@override
String toString() {
  return 'PurchaseDetailItem(id: $id, productName: $productName, variantName: $variantName, imageUrl: $imageUrl, unitPrice: $unitPrice, quantity: $quantity, fulfillments: $fulfillments)';
}


}

/// @nodoc
abstract mixin class $PurchaseDetailItemCopyWith<$Res>  {
  factory $PurchaseDetailItemCopyWith(PurchaseDetailItem value, $Res Function(PurchaseDetailItem) _then) = _$PurchaseDetailItemCopyWithImpl;
@useResult
$Res call({
 int id, String? productName, String? variantName, String? imageUrl, num? unitPrice, int quantity, List<PurchaseFulfillment> fulfillments
});




}
/// @nodoc
class _$PurchaseDetailItemCopyWithImpl<$Res>
    implements $PurchaseDetailItemCopyWith<$Res> {
  _$PurchaseDetailItemCopyWithImpl(this._self, this._then);

  final PurchaseDetailItem _self;
  final $Res Function(PurchaseDetailItem) _then;

/// Create a copy of PurchaseDetailItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productName = freezed,Object? variantName = freezed,Object? imageUrl = freezed,Object? unitPrice = freezed,Object? quantity = null,Object? fulfillments = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as num?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,fulfillments: null == fulfillments ? _self.fulfillments : fulfillments // ignore: cast_nullable_to_non_nullable
as List<PurchaseFulfillment>,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseDetailItem].
extension PurchaseDetailItemPatterns on PurchaseDetailItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseDetailItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseDetailItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseDetailItem value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseDetailItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseDetailItem value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseDetailItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? productName,  String? variantName,  String? imageUrl,  num? unitPrice,  int quantity,  List<PurchaseFulfillment> fulfillments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseDetailItem() when $default != null:
return $default(_that.id,_that.productName,_that.variantName,_that.imageUrl,_that.unitPrice,_that.quantity,_that.fulfillments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? productName,  String? variantName,  String? imageUrl,  num? unitPrice,  int quantity,  List<PurchaseFulfillment> fulfillments)  $default,) {final _that = this;
switch (_that) {
case _PurchaseDetailItem():
return $default(_that.id,_that.productName,_that.variantName,_that.imageUrl,_that.unitPrice,_that.quantity,_that.fulfillments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? productName,  String? variantName,  String? imageUrl,  num? unitPrice,  int quantity,  List<PurchaseFulfillment> fulfillments)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseDetailItem() when $default != null:
return $default(_that.id,_that.productName,_that.variantName,_that.imageUrl,_that.unitPrice,_that.quantity,_that.fulfillments);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseDetailItem implements PurchaseDetailItem {
  const _PurchaseDetailItem({required this.id, this.productName, this.variantName, this.imageUrl, this.unitPrice, required this.quantity, required final  List<PurchaseFulfillment> fulfillments}): _fulfillments = fulfillments;
  factory _PurchaseDetailItem.fromJson(Map<String, dynamic> json) => _$PurchaseDetailItemFromJson(json);

@override final  int id;
@override final  String? productName;
@override final  String? variantName;
@override final  String? imageUrl;
@override final  num? unitPrice;
@override final  int quantity;
 final  List<PurchaseFulfillment> _fulfillments;
@override List<PurchaseFulfillment> get fulfillments {
  if (_fulfillments is EqualUnmodifiableListView) return _fulfillments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fulfillments);
}


/// Create a copy of PurchaseDetailItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseDetailItemCopyWith<_PurchaseDetailItem> get copyWith => __$PurchaseDetailItemCopyWithImpl<_PurchaseDetailItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseDetailItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseDetailItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.variantName, variantName) || other.variantName == variantName)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other._fulfillments, _fulfillments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productName,variantName,imageUrl,unitPrice,quantity,const DeepCollectionEquality().hash(_fulfillments));

@override
String toString() {
  return 'PurchaseDetailItem(id: $id, productName: $productName, variantName: $variantName, imageUrl: $imageUrl, unitPrice: $unitPrice, quantity: $quantity, fulfillments: $fulfillments)';
}


}

/// @nodoc
abstract mixin class _$PurchaseDetailItemCopyWith<$Res> implements $PurchaseDetailItemCopyWith<$Res> {
  factory _$PurchaseDetailItemCopyWith(_PurchaseDetailItem value, $Res Function(_PurchaseDetailItem) _then) = __$PurchaseDetailItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String? productName, String? variantName, String? imageUrl, num? unitPrice, int quantity, List<PurchaseFulfillment> fulfillments
});




}
/// @nodoc
class __$PurchaseDetailItemCopyWithImpl<$Res>
    implements _$PurchaseDetailItemCopyWith<$Res> {
  __$PurchaseDetailItemCopyWithImpl(this._self, this._then);

  final _PurchaseDetailItem _self;
  final $Res Function(_PurchaseDetailItem) _then;

/// Create a copy of PurchaseDetailItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productName = freezed,Object? variantName = freezed,Object? imageUrl = freezed,Object? unitPrice = freezed,Object? quantity = null,Object? fulfillments = null,}) {
  return _then(_PurchaseDetailItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,productName: freezed == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String?,variantName: freezed == variantName ? _self.variantName : variantName // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: freezed == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as num?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,fulfillments: null == fulfillments ? _self._fulfillments : fulfillments // ignore: cast_nullable_to_non_nullable
as List<PurchaseFulfillment>,
  ));
}


}


/// @nodoc
mixin _$PurchaseFulfillment {

 int get id; int get status; String get statusLabel; String get itemQuantity; String? get paidAt; String? get shippedAt; String? get deliveredAt; String? get completedAt;
/// Create a copy of PurchaseFulfillment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PurchaseFulfillmentCopyWith<PurchaseFulfillment> get copyWith => _$PurchaseFulfillmentCopyWithImpl<PurchaseFulfillment>(this as PurchaseFulfillment, _$identity);

  /// Serializes this PurchaseFulfillment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseFulfillment&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.itemQuantity, itemQuantity) || other.itemQuantity == itemQuantity)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,statusLabel,itemQuantity,paidAt,shippedAt,deliveredAt,completedAt);

@override
String toString() {
  return 'PurchaseFulfillment(id: $id, status: $status, statusLabel: $statusLabel, itemQuantity: $itemQuantity, paidAt: $paidAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $PurchaseFulfillmentCopyWith<$Res>  {
  factory $PurchaseFulfillmentCopyWith(PurchaseFulfillment value, $Res Function(PurchaseFulfillment) _then) = _$PurchaseFulfillmentCopyWithImpl;
@useResult
$Res call({
 int id, int status, String statusLabel, String itemQuantity, String? paidAt, String? shippedAt, String? deliveredAt, String? completedAt
});




}
/// @nodoc
class _$PurchaseFulfillmentCopyWithImpl<$Res>
    implements $PurchaseFulfillmentCopyWith<$Res> {
  _$PurchaseFulfillmentCopyWithImpl(this._self, this._then);

  final PurchaseFulfillment _self;
  final $Res Function(PurchaseFulfillment) _then;

/// Create a copy of PurchaseFulfillment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? statusLabel = null,Object? itemQuantity = null,Object? paidAt = freezed,Object? shippedAt = freezed,Object? deliveredAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,itemQuantity: null == itemQuantity ? _self.itemQuantity : itemQuantity // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PurchaseFulfillment].
extension PurchaseFulfillmentPatterns on PurchaseFulfillment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PurchaseFulfillment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PurchaseFulfillment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PurchaseFulfillment value)  $default,){
final _that = this;
switch (_that) {
case _PurchaseFulfillment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PurchaseFulfillment value)?  $default,){
final _that = this;
switch (_that) {
case _PurchaseFulfillment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int status,  String statusLabel,  String itemQuantity,  String? paidAt,  String? shippedAt,  String? deliveredAt,  String? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PurchaseFulfillment() when $default != null:
return $default(_that.id,_that.status,_that.statusLabel,_that.itemQuantity,_that.paidAt,_that.shippedAt,_that.deliveredAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int status,  String statusLabel,  String itemQuantity,  String? paidAt,  String? shippedAt,  String? deliveredAt,  String? completedAt)  $default,) {final _that = this;
switch (_that) {
case _PurchaseFulfillment():
return $default(_that.id,_that.status,_that.statusLabel,_that.itemQuantity,_that.paidAt,_that.shippedAt,_that.deliveredAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int status,  String statusLabel,  String itemQuantity,  String? paidAt,  String? shippedAt,  String? deliveredAt,  String? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _PurchaseFulfillment() when $default != null:
return $default(_that.id,_that.status,_that.statusLabel,_that.itemQuantity,_that.paidAt,_that.shippedAt,_that.deliveredAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PurchaseFulfillment implements PurchaseFulfillment {
  const _PurchaseFulfillment({required this.id, required this.status, required this.statusLabel, required this.itemQuantity, this.paidAt, this.shippedAt, this.deliveredAt, this.completedAt});
  factory _PurchaseFulfillment.fromJson(Map<String, dynamic> json) => _$PurchaseFulfillmentFromJson(json);

@override final  int id;
@override final  int status;
@override final  String statusLabel;
@override final  String itemQuantity;
@override final  String? paidAt;
@override final  String? shippedAt;
@override final  String? deliveredAt;
@override final  String? completedAt;

/// Create a copy of PurchaseFulfillment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PurchaseFulfillmentCopyWith<_PurchaseFulfillment> get copyWith => __$PurchaseFulfillmentCopyWithImpl<_PurchaseFulfillment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PurchaseFulfillmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PurchaseFulfillment&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.statusLabel, statusLabel) || other.statusLabel == statusLabel)&&(identical(other.itemQuantity, itemQuantity) || other.itemQuantity == itemQuantity)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.shippedAt, shippedAt) || other.shippedAt == shippedAt)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,status,statusLabel,itemQuantity,paidAt,shippedAt,deliveredAt,completedAt);

@override
String toString() {
  return 'PurchaseFulfillment(id: $id, status: $status, statusLabel: $statusLabel, itemQuantity: $itemQuantity, paidAt: $paidAt, shippedAt: $shippedAt, deliveredAt: $deliveredAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$PurchaseFulfillmentCopyWith<$Res> implements $PurchaseFulfillmentCopyWith<$Res> {
  factory _$PurchaseFulfillmentCopyWith(_PurchaseFulfillment value, $Res Function(_PurchaseFulfillment) _then) = __$PurchaseFulfillmentCopyWithImpl;
@override @useResult
$Res call({
 int id, int status, String statusLabel, String itemQuantity, String? paidAt, String? shippedAt, String? deliveredAt, String? completedAt
});




}
/// @nodoc
class __$PurchaseFulfillmentCopyWithImpl<$Res>
    implements _$PurchaseFulfillmentCopyWith<$Res> {
  __$PurchaseFulfillmentCopyWithImpl(this._self, this._then);

  final _PurchaseFulfillment _self;
  final $Res Function(_PurchaseFulfillment) _then;

/// Create a copy of PurchaseFulfillment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? statusLabel = null,Object? itemQuantity = null,Object? paidAt = freezed,Object? shippedAt = freezed,Object? deliveredAt = freezed,Object? completedAt = freezed,}) {
  return _then(_PurchaseFulfillment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,statusLabel: null == statusLabel ? _self.statusLabel : statusLabel // ignore: cast_nullable_to_non_nullable
as String,itemQuantity: null == itemQuantity ? _self.itemQuantity : itemQuantity // ignore: cast_nullable_to_non_nullable
as String,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String?,shippedAt: freezed == shippedAt ? _self.shippedAt : shippedAt // ignore: cast_nullable_to_non_nullable
as String?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
