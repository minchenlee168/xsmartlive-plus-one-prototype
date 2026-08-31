import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/flavor_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/purchase.dart';
import '../../providers/app_info_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bonus_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../theme/app_theme_extension.dart';

/// Profile screen — corresponds to prototype `src/screens/profile.jsx`.
///
/// Sections (in render order, mirrors profile.jsx):
///   1. Gradient header: avatar (64) + name/email + settings icon, with
///      4-stat row INSIDE the header (white text on gradient)
///   2. Orders 4-icon grid card (待付款 / 待出貨 / 已完成 / 退款)
///   3. 近期訂單 — top 3 from purchasesProvider
///   4. Menu list (rounded card with rows, plain icons no background tile)
///   5. Logout outlined button
///   6. {appName} · v1.0.0 footer
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _refresh();
    }
  }

  void _refresh() {
    ref.invalidate(purchaseCountsProvider);
    ref.invalidate(memberCouponsProvider(const MemberCouponFilter(used: false, expired: false)));
  }

  Future<void> _pushAndRefresh(String path) async {
    await context.push(path);
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final authUser = ref.watch(authNotifierProvider).valueOrNull;
    final profile = ref.watch(memberProfileProvider).valueOrNull;
    final counts = ref.watch(purchaseCountsProvider).valueOrNull;
    final unusedCoupons =
        ref.watch(memberCouponsProvider(const MemberCouponFilter(used: false, expired: false))).valueOrNull?.length ?? 0;
    // 紅利點數以「紅利點數頁」的可用點數為準（bonusOverviewProvider），
    // 讓頭部統計與點進去的頁面數字一致；未取得時退回 /me 的 bonus 欄位。
    final bonusPoints =
        ref.watch(bonusOverviewProvider).valueOrNull?.availablePoints;

    final displayName = profile?.name ?? authUser?.name ?? '—';
    final avatarInitial = displayName.isNotEmpty ? displayName[0] : '?';
    final email = authUser?.email ?? '';
    final bonus = profile?.bonus ?? 0;
    final bonusValue =
        bonusPoints != null ? bonusPoints.toStringAsFixed(0) : '$bonus';
    final brandName = FlavorConfig.instance.appName;
    final appVersion = ref.watch(appVersionProvider).valueOrNull;

    return Container(
      color: appTheme.bg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _GradientHeader(
            avatarInitial: avatarInitial,
            name: displayName,
            email: email,
            unboundMobile:
                profile != null && !profile.hasBoundMobile,
            unboundLabel: l10n.profileUnboundMobile,
            stats: [
              (
                label: '紅利',
                value: bonusValue,
                onTap: () => context.push('/bonus'),
              ),
              (
                label: '優惠券',
                value: '$unusedCoupons',
                onTap: () => _pushAndRefresh('/coupons'),
              ),
              (
                label: '收藏',
                value: '0',
                onTap: () => _pushAndRefresh('/favorites'),
              ),
              (
                label: '追蹤',
                value: '0',
                onTap: () => context.push('/following'),
              ),
            ],
            onLogoutTap: () =>
                ref.read(authNotifierProvider.notifier).logout(),
            // Route the "尚未綁定手機" hint to the bind-mobile flow (B4) when
            // the member has no mobile yet; otherwise to change-mobile.
            onChangeMobileTap: () => context.push(
              profile != null && !profile.hasBoundMobile
                  ? '/settings/bind-mobile'
                  : '/settings/mobile',
            ),
          ),
          const SizedBox(height: 14),
          _OrdersIconGrid(
            title: l10n.profileMyOrders,
            viewAllLabel: l10n.profileViewAll,
            onViewAll: () => _pushAndRefresh('/orders'),
            items: [
              (
                label: l10n.profilePendingPayment,
                icon: Icons.account_balance_wallet_outlined,
                count: counts?.pending ?? 0,
              ),
              (
                label: l10n.profilePendingShipment,
                icon: Icons.inventory_2_outlined,
                count: counts?.paid ?? 0,
              ),
              (
                label: l10n.profileCompleted,
                icon: Icons.check_circle_outline,
                count: counts?.completed ?? 0,
              ),
              (
                label: '退款',
                icon: Icons.info_outline,
                count: 0,
              ),
            ],
            onItemTap: () => _pushAndRefresh('/orders'),
          ),
          const SizedBox(height: 14),
          _RecentOrdersSection(onTapOrder: () => _pushAndRefresh('/orders')),
          const SizedBox(height: 6),
          _MenuList(
            items: [
              (
                label: l10n.menuFavorites,
                icon: Icons.favorite_border,
                value: null,
                badge: 0,
                route: '/favorites',
              ),
              (
                label: l10n.menuCoupons,
                icon: Icons.local_offer_outlined,
                value: '$unusedCoupons 張',
                badge: unusedCoupons,
                route: '/coupons',
              ),
              (
                label: '我的追蹤',
                icon: Icons.podcasts,
                value: null,
                badge: 0,
                route: '/following',
              ),
              (
                label: '語言 / Language',
                icon: Icons.language,
                value: null,
                badge: 0,
                route: '/settings/language',
              ),
              (
                // Dynamic row — accounts that have not yet bound a mobile
                // (e.g. social-login users) see "綁定手機" pointing at the
                // bind-mobile flow; bound users see the regular change-mobile
                // entry. Same row, conditional behaviour, so unbound users
                // always have a discoverable path even if the gradient-header
                // hint is hidden.
                label: profile != null && !profile.hasBoundMobile
                    ? '綁定手機'
                    : '更改手機號碼',
                icon: Icons.phone_iphone,
                value: null,
                badge: 0,
                route: profile != null && !profile.hasBoundMobile
                    ? '/settings/bind-mobile'
                    : '/settings/mobile',
              ),
              (
                label: '修改密碼',
                icon: Icons.lock_outline,
                value: null,
                badge: 0,
                route: '/settings/password',
              ),
              (
                label: '收件地址',
                icon: Icons.location_on_outlined,
                value: null,
                badge: 0,
                route: '/settings/address',
              ),
              (
                label: l10n.menuTheme,
                icon: Icons.palette_outlined,
                value: null,
                badge: 0,
                route: '/settings/themes',
              ),
              (
                label: '通知設定',
                icon: Icons.notifications_none_outlined,
                value: null,
                badge: 0,
                route: '/notifications',
              ),
              (
                label: l10n.menuHelp,
                icon: Icons.help_outline,
                value: null,
                badge: 0,
                route: '/support',
              ),
            ],
            onTap: (route) {
              if (route == '/coupons' || route == '/favorites') {
                _pushAndRefresh(route);
              } else {
                context.push(route);
              }
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              appVersion == null
                  ? brandName
                  : '$brandName · v$appVersion',
              style: TextStyle(fontSize: 11, color: appTheme.fgMuted),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Gradient header — avatar + name/email + settings icon + 4-stat row
// (stats live INSIDE the gradient, white text — matches profile.jsx)
// ───────────────────────────────────────────────────────────────────────────
class _GradientHeader extends StatelessWidget {
  const _GradientHeader({
    required this.avatarInitial,
    required this.name,
    required this.email,
    required this.unboundMobile,
    required this.unboundLabel,
    required this.stats,
    required this.onLogoutTap,
    required this.onChangeMobileTap,
  });

  final String avatarInitial;
  final String name;
  final String email;
  final bool unboundMobile;
  final String unboundLabel;
  final List<({String label, String value, VoidCallback? onTap})> stats;
  final VoidCallback onLogoutTap;
  final VoidCallback onChangeMobileTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 30),
      decoration: BoxDecoration(
        gradient: appTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(appTheme.radiusLg),
          bottomRight: Radius.circular(appTheme.radiusLg),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  avatarInitial,
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: appTheme.brandPalette.tone500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : '—',
                      style: GoogleFonts.getFont(
                        appTheme.fontDisplay,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    if (unboundMobile)
                      Padding(
                        padding: EdgeInsets.only(top: email.isEmpty ? 0 : 2),
                        child: InkWell(
                        onTap: onChangeMobileTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              unboundLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.chevron_right,
                                size: 14,
                                color: Colors.white
                                    .withValues(alpha: 0.85)),
                          ],
                        ),
                      ),
                      ),
                  ],
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.22),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onLogoutTap,
                  child: const Tooltip(
                    message: '登出',
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(Icons.logout,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: stats
                .map((s) => Expanded(
                      child: GestureDetector(
                        onTap: s.onTap,
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          children: [
                            Text(
                              s.value,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.label,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Orders 4-icon grid card
// ───────────────────────────────────────────────────────────────────────────
class _OrdersIconGrid extends StatelessWidget {
  const _OrdersIconGrid({
    required this.title,
    required this.viewAllLabel,
    required this.onViewAll,
    required this.items,
    required this.onItemTap,
  });

  final String title;
  final String viewAllLabel;
  final VoidCallback onViewAll;
  final List<({String label, IconData icon, int count})> items;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          border: Border.all(color: appTheme.divider),
          boxShadow: appTheme.elevation1,
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: appTheme.fontWeightDisplay,
                      color: appTheme.fg,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '$viewAllLabel ›',
                      style: TextStyle(
                        fontSize: 12,
                        color: appTheme.fgMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: items
                  .map((s) => Expanded(
                        child: GestureDetector(
                          onTap: onItemTap,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(s.icon,
                                        size: 26, color: appTheme.fg),
                                    if (s.count > 0)
                                      Positioned(
                                        top: -4,
                                        right: -8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: appTheme
                                                .brandPalette.tone500,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '${s.count}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  s.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: appTheme.fgMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 近期訂單 — top 3 from purchasesProvider, prototype-styled cards.
// ───────────────────────────────────────────────────────────────────────────
class _RecentOrdersSection extends ConsumerWidget {
  const _RecentOrdersSection({required this.onTapOrder});
  final VoidCallback onTapOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final filter = (
      status: null,
      page: 1,
      startTime: null,
      endTime: null,
      mallType: null,
      keyword: null,
    ) as PurchasesFilter;
    final ordersAsync = ref.watch(purchasesProvider(filter));

    return ordersAsync.maybeWhen(
      data: (collection) {
        final orders = collection.data.take(3).toList(growable: false);
        if (orders.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
                child: Text(
                  '近期訂單',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: appTheme.fgMuted,
                  ),
                ),
              ),
              for (final o in orders)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RecentOrderCard(
                    order: o,
                    onTap: onTapOrder,
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order, required this.onTap});
  final Purchase order;
  final VoidCallback onTap;

  /// Prototype shows a clean `2026/04/18` (date only, slash separated).
  /// API may send ISO (`2026-04-29T02:56:53Z`) or `yyyy-MM-dd HH:mm:ss`.
  static String _formatDate(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      final local = dt.toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${local.year}/${two(local.month)}/${two(local.day)}';
    }
    final datePart = raw.split(RegExp(r'[ T]')).first;
    return datePart.replaceAll('-', '/');
  }

  ({String label, Color color}) _statusMeta(BuildContext context) {
    final appTheme = context.appTheme;
    switch (order.status) {
      case 'pending':
        return (label: '待付款', color: appTheme.warning);
      case 'paid':
        return (label: '待出貨', color: appTheme.info);
      case 'shipped':
        return (label: '配送中', color: appTheme.info);
      case 'completed':
        return (label: '已完成', color: appTheme.success);
      case 'cancelled':
        return (label: '已取消', color: appTheme.fgMuted);
      default:
        return (label: order.status ?? '處理中', color: appTheme.fgMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final status = _statusMeta(context);
    final dateOnly = _formatDate(order.createdAt);
    // 結構刻意與「我的訂單」(_OrdersIconGrid) 完全一致：
    // 由 Container 的 BoxDecoration 提供 bgElev 白底，外層不再用
    // Material(color:) ── 後者在 M3 會套 surface tint 讓白底偏灰
    // (#F5F5F5)，導致與 #FFFFFF 的「我的訂單」卡看起來不同色。
    // 點擊漣漪改用透明 Material 承載，不影響填色。
    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
        boxShadow: appTheme.elevation1,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: appTheme.fgMuted,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: status.color.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: status.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$dateOnly · ${order.itemCount} 件',
                    style: TextStyle(
                      fontSize: 12,
                      color: appTheme.fgMuted,
                    ),
                  ),
                  Text(
                    '\$${_format(order.amount)}',
                    style: GoogleFonts.getFont(
                      appTheme.fontDisplay,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: appTheme.brandPalette.tone500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Menu list (rounded card with rows, plain icons — no background tile)
// ───────────────────────────────────────────────────────────────────────────
class _MenuList extends StatelessWidget {
  const _MenuList({required this.items, required this.onTap});

  final List<
      ({
        String label,
        IconData icon,
        String? value,
        int badge,
        String route
      })> items;
  final void Function(String route) onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          border: Border.all(color: appTheme.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          child: Column(
            children: List.generate(items.length, (i) {
              final m = items[i];
              return InkWell(
                onTap: () => onTap(m.route),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: i < items.length - 1
                          ? BorderSide(color: appTheme.divider)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(m.icon, size: 20, color: appTheme.fg),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 14,
                            color: appTheme.fg,
                          ),
                        ),
                      ),
                      if (m.value != null && m.value!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            m.value!,
                            style: TextStyle(
                              fontSize: 12,
                              color: appTheme.fgMuted,
                            ),
                          ),
                        )
                      else if (m.badge > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: appTheme.danger,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${m.badge}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      Icon(Icons.chevron_right,
                          size: 16, color: appTheme.fgMuted),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Tiny number-formatter helper — adds thousands separators.
// ─────────────────────────────────────────────────────────────────────────
String _format(num value) {
  final intPart = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return buf.toString();
}
