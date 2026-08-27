import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int memberId,
    required String name,
    String? providerMemberId,
    int? memberProviderId,
    String? avatarUrl,
    @Default(false) bool wasRecentlyCreated,
    // Profile display fields — not returned by login API; populated separately.
    @Default('') String email,
    @Default('Lv.1') String level,
    @Default(0) int points,
    @Default(false) bool isVip,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
