import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_stream.freezed.dart';
part 'live_stream.g.dart';

@freezed
abstract class LiveStream with _$LiveStream {
  const factory LiveStream({
    required String id,
    required String title,
    required String streamer,
    required String thumbnail,
    @Default(0) int viewers,
    @Default(0) int likes,
    @Default(true) bool isLive,
    String? streamUrl,
    String? startTime,
  }) = _LiveStream;

  /// Maps the `/mall/store/{id}/market/live` envelope
  /// (market wrapping a `live` object) onto our flat [LiveStream] shape.
  factory LiveStream.fromJson(Map<String, dynamic> json) {
    final live = json['live'] as Map<String, dynamic>?;
    final rawId = live?['id'] ?? json['id'];
    return LiveStream(
      id: rawId?.toString() ?? '',
      title: (json['name'] as String?) ?? '',
      streamer: '',
      thumbnail: '',
      isLive: json['is_active'] as bool? ?? false,
      streamUrl: live?['provider_stream_id'] as String?,
      startTime: json['started_at'] as String?,
    );
  }
}

@freezed
abstract class LiveComment with _$LiveComment {
  const factory LiveComment({
    required String id,
    required String username,
    required String message,
    String? avatar,
    @Default('') String time,
  }) = _LiveComment;

  factory LiveComment.fromJson(Map<String, dynamic> json) =>
      _$LiveCommentFromJson(json);
}
