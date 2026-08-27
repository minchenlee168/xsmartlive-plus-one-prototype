// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_stream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LiveStream {

 String get id; String get title; String get streamer; String get thumbnail; int get viewers; int get likes; bool get isLive; String? get streamUrl; String? get startTime;
/// Create a copy of LiveStream
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveStreamCopyWith<LiveStream> get copyWith => _$LiveStreamCopyWithImpl<LiveStream>(this as LiveStream, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveStream&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.streamer, streamer) || other.streamer == streamer)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.viewers, viewers) || other.viewers == viewers)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.startTime, startTime) || other.startTime == startTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,streamer,thumbnail,viewers,likes,isLive,streamUrl,startTime);

@override
String toString() {
  return 'LiveStream(id: $id, title: $title, streamer: $streamer, thumbnail: $thumbnail, viewers: $viewers, likes: $likes, isLive: $isLive, streamUrl: $streamUrl, startTime: $startTime)';
}


}

/// @nodoc
abstract mixin class $LiveStreamCopyWith<$Res>  {
  factory $LiveStreamCopyWith(LiveStream value, $Res Function(LiveStream) _then) = _$LiveStreamCopyWithImpl;
@useResult
$Res call({
 String id, String title, String streamer, String thumbnail, int viewers, int likes, bool isLive, String? streamUrl, String? startTime
});




}
/// @nodoc
class _$LiveStreamCopyWithImpl<$Res>
    implements $LiveStreamCopyWith<$Res> {
  _$LiveStreamCopyWithImpl(this._self, this._then);

  final LiveStream _self;
  final $Res Function(LiveStream) _then;

/// Create a copy of LiveStream
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? streamer = null,Object? thumbnail = null,Object? viewers = null,Object? likes = null,Object? isLive = null,Object? streamUrl = freezed,Object? startTime = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,streamer: null == streamer ? _self.streamer : streamer // ignore: cast_nullable_to_non_nullable
as String,thumbnail: null == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveStream].
extension LiveStreamPatterns on LiveStream {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveStream value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveStream() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveStream value)  $default,){
final _that = this;
switch (_that) {
case _LiveStream():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveStream value)?  $default,){
final _that = this;
switch (_that) {
case _LiveStream() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String streamer,  String thumbnail,  int viewers,  int likes,  bool isLive,  String? streamUrl,  String? startTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveStream() when $default != null:
return $default(_that.id,_that.title,_that.streamer,_that.thumbnail,_that.viewers,_that.likes,_that.isLive,_that.streamUrl,_that.startTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String streamer,  String thumbnail,  int viewers,  int likes,  bool isLive,  String? streamUrl,  String? startTime)  $default,) {final _that = this;
switch (_that) {
case _LiveStream():
return $default(_that.id,_that.title,_that.streamer,_that.thumbnail,_that.viewers,_that.likes,_that.isLive,_that.streamUrl,_that.startTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String streamer,  String thumbnail,  int viewers,  int likes,  bool isLive,  String? streamUrl,  String? startTime)?  $default,) {final _that = this;
switch (_that) {
case _LiveStream() when $default != null:
return $default(_that.id,_that.title,_that.streamer,_that.thumbnail,_that.viewers,_that.likes,_that.isLive,_that.streamUrl,_that.startTime);case _:
  return null;

}
}

}

/// @nodoc


class _LiveStream implements LiveStream {
  const _LiveStream({required this.id, required this.title, required this.streamer, required this.thumbnail, this.viewers = 0, this.likes = 0, this.isLive = true, this.streamUrl, this.startTime});
  

@override final  String id;
@override final  String title;
@override final  String streamer;
@override final  String thumbnail;
@override@JsonKey() final  int viewers;
@override@JsonKey() final  int likes;
@override@JsonKey() final  bool isLive;
@override final  String? streamUrl;
@override final  String? startTime;

/// Create a copy of LiveStream
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveStreamCopyWith<_LiveStream> get copyWith => __$LiveStreamCopyWithImpl<_LiveStream>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveStream&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.streamer, streamer) || other.streamer == streamer)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.viewers, viewers) || other.viewers == viewers)&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.isLive, isLive) || other.isLive == isLive)&&(identical(other.streamUrl, streamUrl) || other.streamUrl == streamUrl)&&(identical(other.startTime, startTime) || other.startTime == startTime));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,streamer,thumbnail,viewers,likes,isLive,streamUrl,startTime);

@override
String toString() {
  return 'LiveStream(id: $id, title: $title, streamer: $streamer, thumbnail: $thumbnail, viewers: $viewers, likes: $likes, isLive: $isLive, streamUrl: $streamUrl, startTime: $startTime)';
}


}

/// @nodoc
abstract mixin class _$LiveStreamCopyWith<$Res> implements $LiveStreamCopyWith<$Res> {
  factory _$LiveStreamCopyWith(_LiveStream value, $Res Function(_LiveStream) _then) = __$LiveStreamCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String streamer, String thumbnail, int viewers, int likes, bool isLive, String? streamUrl, String? startTime
});




}
/// @nodoc
class __$LiveStreamCopyWithImpl<$Res>
    implements _$LiveStreamCopyWith<$Res> {
  __$LiveStreamCopyWithImpl(this._self, this._then);

  final _LiveStream _self;
  final $Res Function(_LiveStream) _then;

/// Create a copy of LiveStream
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? streamer = null,Object? thumbnail = null,Object? viewers = null,Object? likes = null,Object? isLive = null,Object? streamUrl = freezed,Object? startTime = freezed,}) {
  return _then(_LiveStream(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,streamer: null == streamer ? _self.streamer : streamer // ignore: cast_nullable_to_non_nullable
as String,thumbnail: null == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String,viewers: null == viewers ? _self.viewers : viewers // ignore: cast_nullable_to_non_nullable
as int,likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,isLive: null == isLive ? _self.isLive : isLive // ignore: cast_nullable_to_non_nullable
as bool,streamUrl: freezed == streamUrl ? _self.streamUrl : streamUrl // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LiveComment {

 String get id; String get username; String get message; String? get avatar; String get time;
/// Create a copy of LiveComment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LiveCommentCopyWith<LiveComment> get copyWith => _$LiveCommentCopyWithImpl<LiveComment>(this as LiveComment, _$identity);

  /// Serializes this LiveComment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LiveComment&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.message, message) || other.message == message)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,message,avatar,time);

@override
String toString() {
  return 'LiveComment(id: $id, username: $username, message: $message, avatar: $avatar, time: $time)';
}


}

/// @nodoc
abstract mixin class $LiveCommentCopyWith<$Res>  {
  factory $LiveCommentCopyWith(LiveComment value, $Res Function(LiveComment) _then) = _$LiveCommentCopyWithImpl;
@useResult
$Res call({
 String id, String username, String message, String? avatar, String time
});




}
/// @nodoc
class _$LiveCommentCopyWithImpl<$Res>
    implements $LiveCommentCopyWith<$Res> {
  _$LiveCommentCopyWithImpl(this._self, this._then);

  final LiveComment _self;
  final $Res Function(LiveComment) _then;

/// Create a copy of LiveComment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? message = null,Object? avatar = freezed,Object? time = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LiveComment].
extension LiveCommentPatterns on LiveComment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LiveComment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LiveComment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LiveComment value)  $default,){
final _that = this;
switch (_that) {
case _LiveComment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LiveComment value)?  $default,){
final _that = this;
switch (_that) {
case _LiveComment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String message,  String? avatar,  String time)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LiveComment() when $default != null:
return $default(_that.id,_that.username,_that.message,_that.avatar,_that.time);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String message,  String? avatar,  String time)  $default,) {final _that = this;
switch (_that) {
case _LiveComment():
return $default(_that.id,_that.username,_that.message,_that.avatar,_that.time);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String message,  String? avatar,  String time)?  $default,) {final _that = this;
switch (_that) {
case _LiveComment() when $default != null:
return $default(_that.id,_that.username,_that.message,_that.avatar,_that.time);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LiveComment implements LiveComment {
  const _LiveComment({required this.id, required this.username, required this.message, this.avatar, this.time = ''});
  factory _LiveComment.fromJson(Map<String, dynamic> json) => _$LiveCommentFromJson(json);

@override final  String id;
@override final  String username;
@override final  String message;
@override final  String? avatar;
@override@JsonKey() final  String time;

/// Create a copy of LiveComment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LiveCommentCopyWith<_LiveComment> get copyWith => __$LiveCommentCopyWithImpl<_LiveComment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LiveCommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LiveComment&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.message, message) || other.message == message)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.time, time) || other.time == time));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,message,avatar,time);

@override
String toString() {
  return 'LiveComment(id: $id, username: $username, message: $message, avatar: $avatar, time: $time)';
}


}

/// @nodoc
abstract mixin class _$LiveCommentCopyWith<$Res> implements $LiveCommentCopyWith<$Res> {
  factory _$LiveCommentCopyWith(_LiveComment value, $Res Function(_LiveComment) _then) = __$LiveCommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String message, String? avatar, String time
});




}
/// @nodoc
class __$LiveCommentCopyWithImpl<$Res>
    implements _$LiveCommentCopyWith<$Res> {
  __$LiveCommentCopyWithImpl(this._self, this._then);

  final _LiveComment _self;
  final $Res Function(_LiveComment) _then;

/// Create a copy of LiveComment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? message = null,Object? avatar = freezed,Object? time = null,}) {
  return _then(_LiveComment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
