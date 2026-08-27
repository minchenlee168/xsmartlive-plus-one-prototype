import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/claimable_coupon.dart';
import '../models/member_coupon.dart';
import 'repository_providers.dart';

/// Composite filter for [memberCouponsProvider]. Keeps `used` and `expired`
/// in a single value so the FutureProvider family key changes whenever
/// either toggle changes. `const` defaults to "all coupons".
class MemberCouponFilter {
  const MemberCouponFilter({this.used, this.expired});

  /// `false` = unused, `true` = used, `null` = all.
  final bool? used;

  /// 2026-05 spec rev — server-side expired filter. `true` for the 過期
  /// tab, `false` to exclude expired entries, `null` to leave it off.
  final bool? expired;

  static const all = MemberCouponFilter();

  @override
  bool operator ==(Object other) =>
      other is MemberCouponFilter &&
      other.used == used &&
      other.expired == expired;

  @override
  int get hashCode => Object.hash(used, expired);
}

/// Fetches member coupons honouring the supplied [MemberCouponFilter].
final memberCouponsProvider = FutureProvider.family<List<MemberCoupon>,
    MemberCouponFilter>((ref, filter) async {
  return ref.read(couponRepositoryProvider).fetchMemberCoupons(
        used: filter.used,
        expired: filter.expired,
      );
});

/// Fetches coupons that the member can claim.
final claimableCouponsProvider =
    FutureProvider<List<ClaimableCoupon>>((ref) async {
  return ref.read(couponRepositoryProvider).fetchClaimableCoupons();
});

/// Session-scoped record of claimable coupon IDs the user has already
/// claimed in this app run. Used to hide them from the claimable list even
/// if the backend keeps returning them (e.g. multi-quota coupons): once
/// claimed, the user shouldn't be able to tap "領取" again until app restart.
/// Cleared on app process restart — that's intentional, the membership list
/// is the source of truth after a cold start.
final claimedCouponIdsProvider =
    NotifierProvider<ClaimedCouponIdsNotifier, Set<int>>(
  ClaimedCouponIdsNotifier.new,
);

class ClaimedCouponIdsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void markClaimed(int id) {
    if (state.contains(id)) return;
    state = {...state, id};
  }
}
