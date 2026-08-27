import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/member_profile.dart';
import 'repository_providers.dart';

class MemberProfileNotifier extends AsyncNotifier<MemberProfile?> {
  @override
  Future<MemberProfile?> build() async {
    try {
      return await ref.read(authRepositoryProvider).fetchMe();
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).fetchMe(),
    );
  }

  /// 更新會員基本資料；成功後立即把回傳的 [MemberProfile] 寫回 state，
  /// 不再額外打一次 `/me`。
  Future<MemberProfile> updateProfile({
    required String name,
    String? email,
    int? gender,
    String? birthday,
  }) async {
    final updated = await ref.read(authRepositoryProvider).updateMe(
          name: name,
          email: email,
          gender: gender,
          birthday: birthday,
        );
    state = AsyncData(updated);
    return updated;
  }
}

final memberProfileProvider =
    AsyncNotifierProvider<MemberProfileNotifier, MemberProfile?>(
  MemberProfileNotifier.new,
);
