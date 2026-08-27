// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 int get memberId; String get name; String? get providerMemberId; int? get memberProviderId; String? get avatarUrl; bool get wasRecentlyCreated;// Profile display fields — not returned by login API; populated separately.
 String get email; String get level; int get points; bool get isVip;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.providerMemberId, providerMemberId) || other.providerMemberId == providerMemberId)&&(identical(other.memberProviderId, memberProviderId) || other.memberProviderId == memberProviderId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.wasRecentlyCreated, wasRecentlyCreated) || other.wasRecentlyCreated == wasRecentlyCreated)&&(identical(other.email, email) || other.email == email)&&(identical(other.level, level) || other.level == level)&&(identical(other.points, points) || other.points == points)&&(identical(other.isVip, isVip) || other.isVip == isVip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,providerMemberId,memberProviderId,avatarUrl,wasRecentlyCreated,email,level,points,isVip);

@override
String toString() {
  return 'User(memberId: $memberId, name: $name, providerMemberId: $providerMemberId, memberProviderId: $memberProviderId, avatarUrl: $avatarUrl, wasRecentlyCreated: $wasRecentlyCreated, email: $email, level: $level, points: $points, isVip: $isVip)';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 int memberId, String name, String? providerMemberId, int? memberProviderId, String? avatarUrl, bool wasRecentlyCreated, String email, String level, int points, bool isVip
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memberId = null,Object? name = null,Object? providerMemberId = freezed,Object? memberProviderId = freezed,Object? avatarUrl = freezed,Object? wasRecentlyCreated = null,Object? email = null,Object? level = null,Object? points = null,Object? isVip = null,}) {
  return _then(_self.copyWith(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,providerMemberId: freezed == providerMemberId ? _self.providerMemberId : providerMemberId // ignore: cast_nullable_to_non_nullable
as String?,memberProviderId: freezed == memberProviderId ? _self.memberProviderId : memberProviderId // ignore: cast_nullable_to_non_nullable
as int?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,wasRecentlyCreated: null == wasRecentlyCreated ? _self.wasRecentlyCreated : wasRecentlyCreated // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isVip: null == isVip ? _self.isVip : isVip // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int memberId,  String name,  String? providerMemberId,  int? memberProviderId,  String? avatarUrl,  bool wasRecentlyCreated,  String email,  String level,  int points,  bool isVip)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.memberId,_that.name,_that.providerMemberId,_that.memberProviderId,_that.avatarUrl,_that.wasRecentlyCreated,_that.email,_that.level,_that.points,_that.isVip);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int memberId,  String name,  String? providerMemberId,  int? memberProviderId,  String? avatarUrl,  bool wasRecentlyCreated,  String email,  String level,  int points,  bool isVip)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.memberId,_that.name,_that.providerMemberId,_that.memberProviderId,_that.avatarUrl,_that.wasRecentlyCreated,_that.email,_that.level,_that.points,_that.isVip);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int memberId,  String name,  String? providerMemberId,  int? memberProviderId,  String? avatarUrl,  bool wasRecentlyCreated,  String email,  String level,  int points,  bool isVip)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.memberId,_that.name,_that.providerMemberId,_that.memberProviderId,_that.avatarUrl,_that.wasRecentlyCreated,_that.email,_that.level,_that.points,_that.isVip);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.memberId, required this.name, this.providerMemberId, this.memberProviderId, this.avatarUrl, this.wasRecentlyCreated = false, this.email = '', this.level = 'Lv.1', this.points = 0, this.isVip = false});
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  int memberId;
@override final  String name;
@override final  String? providerMemberId;
@override final  int? memberProviderId;
@override final  String? avatarUrl;
@override@JsonKey() final  bool wasRecentlyCreated;
// Profile display fields — not returned by login API; populated separately.
@override@JsonKey() final  String email;
@override@JsonKey() final  String level;
@override@JsonKey() final  int points;
@override@JsonKey() final  bool isVip;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.name, name) || other.name == name)&&(identical(other.providerMemberId, providerMemberId) || other.providerMemberId == providerMemberId)&&(identical(other.memberProviderId, memberProviderId) || other.memberProviderId == memberProviderId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.wasRecentlyCreated, wasRecentlyCreated) || other.wasRecentlyCreated == wasRecentlyCreated)&&(identical(other.email, email) || other.email == email)&&(identical(other.level, level) || other.level == level)&&(identical(other.points, points) || other.points == points)&&(identical(other.isVip, isVip) || other.isVip == isVip));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,memberId,name,providerMemberId,memberProviderId,avatarUrl,wasRecentlyCreated,email,level,points,isVip);

@override
String toString() {
  return 'User(memberId: $memberId, name: $name, providerMemberId: $providerMemberId, memberProviderId: $memberProviderId, avatarUrl: $avatarUrl, wasRecentlyCreated: $wasRecentlyCreated, email: $email, level: $level, points: $points, isVip: $isVip)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 int memberId, String name, String? providerMemberId, int? memberProviderId, String? avatarUrl, bool wasRecentlyCreated, String email, String level, int points, bool isVip
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memberId = null,Object? name = null,Object? providerMemberId = freezed,Object? memberProviderId = freezed,Object? avatarUrl = freezed,Object? wasRecentlyCreated = null,Object? email = null,Object? level = null,Object? points = null,Object? isVip = null,}) {
  return _then(_User(
memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,providerMemberId: freezed == providerMemberId ? _self.providerMemberId : providerMemberId // ignore: cast_nullable_to_non_nullable
as String?,memberProviderId: freezed == memberProviderId ? _self.memberProviderId : memberProviderId // ignore: cast_nullable_to_non_nullable
as int?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,wasRecentlyCreated: null == wasRecentlyCreated ? _self.wasRecentlyCreated : wasRecentlyCreated // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,isVip: null == isVip ? _self.isVip : isVip // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
