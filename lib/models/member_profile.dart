class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.topup,
    required this.bonus,
    required this.couponCount,
    required this.hasBoundMobile,
    this.email,
    this.gender,
    this.birthday,
    this.mobile,
  });

  final int id;
  final String name;
  final String? avatarUrl;
  final int topup;
  final int bonus;
  final int couponCount;
  final bool hasBoundMobile;
  final String? email;
  final int? gender;
  final String? birthday;
  final String? mobile;

  factory MemberProfile.fromJson(Map<String, dynamic> json) => MemberProfile(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
        topup: (json['topup'] as num?)?.toInt() ?? 0,
        bonus: (json['bonus'] as num?)?.toInt() ?? 0,
        couponCount: (json['coupon_count'] as num?)?.toInt() ?? 0,
        hasBoundMobile: json['has_bound_mobile'] as bool? ?? false,
        email: json['email'] as String?,
        gender: _genderToInt(json['gender']),
        birthday: json['birthday'] as String?,
        mobile: json['mobile'] as String?,
      );

  MemberProfile copyWith({
    String? name,
    String? avatarUrl,
    int? topup,
    int? bonus,
    int? couponCount,
    bool? hasBoundMobile,
    String? email,
    int? gender,
    String? birthday,
    String? mobile,
  }) {
    return MemberProfile(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      topup: topup ?? this.topup,
      bonus: bonus ?? this.bonus,
      couponCount: couponCount ?? this.couponCount,
      hasBoundMobile: hasBoundMobile ?? this.hasBoundMobile,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      mobile: mobile ?? this.mobile,
    );
  }
}

/// Backend may serialise gender as either int (1/2/3) or numeric string.
int? _genderToInt(Object? raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  if (raw is String) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }
  return null;
}
