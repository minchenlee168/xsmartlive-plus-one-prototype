import 'package:flutter/foundation.dart' show kIsWeb;
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
///
/// Web 預覽（跳過登入 + 跨來源 CORS）打不到需要授權的 `/coupons`，會丟出
/// 例外。此時回退到設計用範例優惠券，讓預覽畫面有內容可看；真機登入後
/// 走真實 API，不受影響。畫面本身仍以 `used` / 到期時間做分頁過濾，因此
/// 各分頁（未使用 / 已使用 / 已過期）都能正確分流。
final memberCouponsProvider = FutureProvider.family<List<MemberCoupon>,
    MemberCouponFilter>((ref, filter) async {
  // Web 預覽無法登入（後端以 200 + code 40000 表示 session 失效，不會丟例外，
  // 會回空清單），因此直接用範例資料。依 filter（used / expired）先過濾，
  // 讓「未使用」等分頁數量（含「我的」頁的未使用張數）正確反映。
  if (kIsWeb) {
    return _sampleMemberCoupons.where((c) {
      if (filter.used != null && c.used != filter.used) return false;
      if (filter.expired != null &&
          _isSampleExpired(c.usableEndTime) != filter.expired) {
        return false;
      }
      return true;
    }).toList(growable: false);
  }
  try {
    return await ref.read(couponRepositoryProvider).fetchMemberCoupons(
          used: filter.used,
          expired: filter.expired,
        );
  } catch (_) {
    return _sampleMemberCoupons;
  }
});

/// Fetches coupons that the member can claim. 同上，失敗時回退範例資料。
final claimableCouponsProvider =
    FutureProvider<List<ClaimableCoupon>>((ref) async {
  if (kIsWeb) return _sampleClaimableCoupons;
  try {
    return await ref.read(couponRepositoryProvider).fetchClaimableCoupons();
  } catch (_) {
    return _sampleClaimableCoupons;
  }
});

/// 範例券是否已過期（依 usable_end_time 與現在時間比較）。
bool _isSampleExpired(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  final dt = DateTime.tryParse(raw);
  return dt != null && dt.isBefore(DateTime.now());
}

// ── 範例資料（web 預覽 / 未登入 fallback）────────────────────────────────
// 涵蓋 未使用 / 已使用 / 已過期 三種狀態，以及兩張可領取券。
// 今日為 2026-08-31：未到期用未來日期、已過期用過去日期。
const List<MemberCoupon> _sampleMemberCoupons = [
  MemberCoupon(
    id: 9001,
    name: '滿 \$1000 折 \$100',
    description: '全站訂單滿千即可折抵，不限商品。',
    discountAmount: '100',
    minOrderAmount: '1000',
    code: 'WELCOME100',
    status: 'active',
    usableEndTime: '2026-12-31T23:59:59',
    used: false,
  ),
  MemberCoupon(
    id: 9002,
    name: '生鮮直播專屬折抵',
    description: '生鮮冷凍類商品專用。',
    discountAmount: '50',
    code: 'FRESH50',
    status: 'active',
    usableEndTime: '2026-10-31T23:59:59',
    used: false,
  ),
  MemberCoupon(
    id: 9003,
    name: '雙 11 限時折抵',
    description: '雙 11 檔期限定。',
    discountAmount: '200',
    code: 'D11-200',
    status: 'used',
    usableEndTime: '2026-11-30T23:59:59',
    used: true,
    usedAt: '2026-08-12T10:30:00',
  ),
  MemberCoupon(
    id: 9004,
    name: '週年慶折價券',
    description: '週年慶檔期券，已逾期。',
    discountPercent: '15',
    code: 'ANNIV15',
    status: 'expired',
    usableEndTime: '2025-12-31T23:59:59',
    used: false,
  ),
  MemberCoupon(
    id: 9005,
    name: '指定商品 85 折',
    description: '限定彩妝品類。',
    discountPercent: '15',
    code: 'MAKEUP85',
    status: 'active',
    usableEndTime: '2026-11-15T23:59:59',
    used: false,
  ),
  MemberCoupon(
    id: 9006,
    name: '滿 \$3000 折 \$300',
    description: '大額訂單專屬。',
    discountAmount: '300',
    minOrderAmount: '3000',
    code: 'SUPER300',
    status: 'active',
    usableEndTime: '2026-12-15T23:59:59',
    used: false,
  ),
  MemberCoupon(
    id: 9007,
    name: '中秋加碼折抵',
    description: '中秋活動券，已使用。',
    discountAmount: '120',
    code: 'MOON120',
    status: 'used',
    usableEndTime: '2026-09-30T23:59:59',
    used: true,
    usedAt: '2026-08-20T14:05:00',
  ),
];

const List<ClaimableCoupon> _sampleClaimableCoupons = [
  ClaimableCoupon(
    id: 9101,
    name: '全站現折 \$80',
    description: '不限金額，全站可用。',
    enable: 1,
    discountType: 1,
    discountAmount: '80',
    totalQuota: 100,
    expiresAt: '2026-12-31T23:59:59',
    status: 'active',
    scope: '適用範圍：全站',
  ),
  ClaimableCoupon(
    id: 9102,
    name: '直播專場 92 折',
    description: '指定直播場次限定。',
    enable: 1,
    discountType: 2,
    discountPercent: '8',
    totalQuota: 50,
    expiresAt: '2026-11-30T23:59:59',
    status: 'active',
    scope: '適用範圍（直播場次）：週末美妝直播',
  ),
  ClaimableCoupon(
    id: 9103,
    name: '新戶首購 \$150',
    description: '首次下單專屬。',
    enable: 1,
    discountType: 1,
    discountAmount: '150',
    totalQuota: 200,
    expiresAt: '2026-12-31T23:59:59',
    status: 'active',
    scope: '適用範圍：全站',
  ),
  ClaimableCoupon(
    id: 9104,
    name: '週末限定 88 折',
    description: '週末下單享 88 折。',
    enable: 1,
    discountType: 2,
    discountPercent: '12',
    totalQuota: 80,
    expiresAt: '2026-10-31T23:59:59',
    status: 'active',
    scope: '適用範圍：全站',
  ),
];

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
