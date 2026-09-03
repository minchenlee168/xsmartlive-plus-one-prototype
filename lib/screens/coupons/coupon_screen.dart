import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../models/claimable_coupon.dart';
import '../../models/member_coupon.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';

// All-coupons family key — re-used by both the All tab and the post-claim
// refresh path so they always hit the same provider instance.
const MemberCouponFilter _allCouponsKey = MemberCouponFilter.all;

enum _CouponFilter { all, unused, used, expired }

enum _CouponVariant { active, used, expired }

class CouponScreen extends ConsumerStatefulWidget {
  const CouponScreen({super.key});

  @override
  ConsumerState<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends ConsumerState<CouponScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.couponTitle),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          ColoredBox(
            color: colorScheme.surfaceContainerLowest,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              dividerColor: colorScheme.outlineVariant,
              tabs: [
                Tab(text: l10n.couponTabAll),
                Tab(text: l10n.couponTabUnused),
                Tab(text: l10n.couponTabUsed),
                Tab(text: l10n.couponTabExpired),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _AllCouponList(),
                _MemberCouponList(filter: _CouponFilter.unused),
                _MemberCouponList(filter: _CouponFilter.used),
                _MemberCouponList(filter: _CouponFilter.expired),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter helpers ──────────────────────────────────────────────────────────

bool _isExpired(String? raw) {
  if (raw == null || raw.isEmpty) return false;
  try {
    return DateTime.parse(raw).isBefore(DateTime.now());
  } catch (_) {
    return false;
  }
}

_CouponVariant _variantFor(MemberCoupon c) {
  if (c.used) return _CouponVariant.used;
  if (_isExpired(c.expiresAt)) return _CouponVariant.expired;
  return _CouponVariant.active;
}

/// Backend `MemberCouponResource` only marks `id/used/claimed_at` as required,
/// so the dev DB ships rows with every other field null. Those render as a
/// fully blank card — hide them to keep the list clean.
bool _isDisplayable(MemberCoupon c) {
  final hasName = c.name.isNotEmpty;
  final hasCode = c.code != null && c.code!.isNotEmpty;
  final hasDescription = c.description != null && c.description!.isNotEmpty;
  final hasDiscount = _parsePositive(c.discountAmount) != null ||
      _parsePositive(c.discountPercent) != null;
  return hasName || hasCode || hasDescription || hasDiscount;
}

double? _parsePositive(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final v = double.tryParse(raw);
  return (v != null && v > 0) ? v : null;
}

String _fmtNumber(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

String _formatDate(String raw) {
  try {
    final dt = DateTime.parse(raw);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return raw;
  }
}

// ── Filtered member coupon list ──────────────────────────────────────────────

class _MemberCouponList extends ConsumerWidget {
  const _MemberCouponList({required this.filter});

  final _CouponFilter filter;

  /// Server-side filter for the active tab. The expired tab now uses the
  /// 2026-05 `expired: true` flag instead of fetching unused + filtering
  /// client-side, so each tab maps to a distinct provider family key and
  /// the backend can return the right rows directly.
  MemberCouponFilter get _apiFilter {
    switch (filter) {
      case _CouponFilter.used:
        return const MemberCouponFilter(used: true);
      case _CouponFilter.unused:
        return const MemberCouponFilter(used: false, expired: false);
      case _CouponFilter.expired:
        return const MemberCouponFilter(used: false, expired: true);
      case _CouponFilter.all:
        return MemberCouponFilter.all;
    }
  }

  bool _matches(MemberCoupon c) {
    final expired = _isExpired(c.expiresAt);
    switch (filter) {
      case _CouponFilter.used:
        return c.used;
      case _CouponFilter.unused:
        return !c.used && !expired;
      case _CouponFilter.expired:
        return !c.used && expired;
      case _CouponFilter.all:
        return true;
    }
  }

  String _emptyText(AppLocalizations l10n) {
    switch (filter) {
      case _CouponFilter.used:
        return l10n.couponEmptyUsed;
      case _CouponFilter.expired:
        return l10n.couponEmptyExpired;
      case _CouponFilter.unused:
        return l10n.couponEmptyUnused;
      case _CouponFilter.all:
        return l10n.couponEmptyAll;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final async = ref.watch(memberCouponsProvider(_apiFilter));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        onRetry: () => ref.invalidate(memberCouponsProvider(_apiFilter)),
      ),
      data: (coupons) {
        final filtered =
            coupons.where(_isDisplayable).where(_matches).toList();
        if (filtered.isEmpty) {
          return _EmptyView(text: _emptyText(l10n));
        }
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: appTheme.spacingLg,
            vertical: appTheme.spacingMd,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, _) =>
              SizedBox(height: appTheme.spacingMd),
          itemBuilder: (context, index) {
            final c = filtered[index];
            return _CouponCard(
              key: ValueKey('member-${c.id}'),
              coupon: c,
            );
          },
        );
      },
    );
  }
}

// ── "All" tab — member coupons + claim-more divider + claimables ────────────

class _AllCouponList extends ConsumerWidget {
  const _AllCouponList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final memberAsync = ref.watch(memberCouponsProvider(_allCouponsKey));
    final claimableAsync = ref.watch(claimableCouponsProvider);

    return memberAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        onRetry: () {
          ref.invalidate(memberCouponsProvider(_allCouponsKey));
          ref.invalidate(claimableCouponsProvider);
        },
      ),
      data: (coupons) {
        final visibleCoupons = coupons.where(_isDisplayable).toList();
        final claimedIds = ref.watch(claimedCouponIdsProvider);
        final claimables = (claimableAsync.valueOrNull ?? const [])
            .where((c) => !claimedIds.contains(c.id))
            .toList();

        if (visibleCoupons.isEmpty && claimables.isEmpty) {
          return _EmptyView(text: l10n.couponEmptyAll);
        }

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: appTheme.spacingLg,
            vertical: appTheme.spacingMd,
          ),
          children: [
            for (final c in visibleCoupons) ...[
              // Key by coupon id so Flutter tracks each card by identity,
              // not list position. Without this, when a claim filters an
              // entry out the cards above shift up and inherit the prior
              // position's State (`_claimed=true`) — causing the next card
              // to incorrectly render as "已領取".
              _CouponCard(key: ValueKey('member-${c.id}'), coupon: c),
              SizedBox(height: appTheme.spacingMd),
            ],
            if (claimables.isNotEmpty) ...[
              _SectionDivider(label: l10n.couponClaimMore),
              for (final c in claimables) ...[
                _ClaimableCouponCard(
                  key: ValueKey('claimable-${c.id}'),
                  coupon: c,
                ),
                SizedBox(height: appTheme.spacingMd),
              ],
            ],
          ],
        );
      },
    );
  }
}

// ── Section divider ("領取更多優惠") ─────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appTheme = context.appTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: appTheme.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: colorScheme.outlineVariant, thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: appTheme.spacingLg),
            child: Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: colorScheme.outlineVariant, thickness: 1),
          ),
        ],
      ),
    );
  }
}

// ── Member coupon card ──────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  const _CouponCard({super.key, required this.coupon});
  final MemberCoupon coupon;

  String _discountLabel(AppLocalizations l10n) {
    final amount = _parsePositive(coupon.discountAmount);
    if (amount != null) return '折${_fmtNumber(amount)}元';
    final percent = _parsePositive(coupon.discountPercent);
    if (percent != null) return '折${_fmtNumber(percent)}%';
    return l10n.couponDiscount;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final variant = _variantFor(coupon);

    // Title fallback: name → code → generic discount label. Prevents the
    // info panel from collapsing to whitespace when the backend ships a
    // partially-populated coupon row.
    final title = coupon.name.isNotEmpty
        ? coupon.name
        : (coupon.code != null && coupon.code!.isNotEmpty
            ? coupon.code!
            : l10n.couponDiscount);

    return _CouponShell(
      leftPanel: _DiscountPanel(
        label: _discountLabel(l10n),
        variant: variant,
      ),
      rightPanel: _CouponInfoPanel(
        title: title,
        titleEnabled: variant == _CouponVariant.active,
        description: coupon.description,
        expiryText: coupon.expiresAt != null
            ? l10n.couponExpiry(_formatDate(coupon.expiresAt!))
            : null,
        secondaryText: variant == _CouponVariant.used && coupon.usedAt != null
            ? l10n.couponUsedAt(_formatDate(coupon.usedAt!))
            : null,
        action: _CardAction(variant: variant),
      ),
    );
  }
}

// ── Claimable coupon card ───────────────────────────────────────────────────

class _ClaimableCouponCard extends ConsumerStatefulWidget {
  const _ClaimableCouponCard({super.key, required this.coupon});
  final ClaimableCoupon coupon;

  @override
  ConsumerState<_ClaimableCouponCard> createState() =>
      _ClaimableCouponCardState();
}

class _ClaimableCouponCardState extends ConsumerState<_ClaimableCouponCard> {
  // Tracks only the transient "API in-flight" loading state. Whether the
  // coupon has been claimed is derived from `claimedCouponIdsProvider`, NOT
  // a local field — that way Flutter's State reuse across list reorders
  // can't cause the wrong card to render as "已領取".
  bool _claiming = false;

  Future<void> _claim() async {
    final errorMsg = AppLocalizations.of(context)!.couponClaimFailed;
    setState(() => _claiming = true);
    try {
      await ref.read(couponRepositoryProvider).claimCoupon(widget.coupon.id);
      if (!mounted) return;
      // Record the claim before clearing _claiming so the UI transitions
      // straight from spinner → "已領取" (filter then removes the card).
      ref
          .read(claimedCouponIdsProvider.notifier)
          .markClaimed(widget.coupon.id);
      setState(() => _claiming = false);
      // Refresh every family instance — the user could be on any of the
      // 4 tabs (All / Unused / Used / Expired), each backed by a different
      // `used` param. Invalidating the family clears all cached lists at
      // once so switching tabs after a claim never shows stale data.
      ref.invalidate(memberCouponsProvider);
      ref.invalidate(claimableCouponsProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _claiming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coupon = widget.coupon;
    // Derive `claimed` from the global set keyed on coupon.id. Eliminates
    // any per-State storage that could drift onto a neighbouring card after
    // a list reorder.
    final claimed =
        ref.watch(claimedCouponIdsProvider).contains(coupon.id);

    return _CouponShell(
      leftPanel: _DiscountPanel(
        label: coupon.discountLabel,
        variant: _CouponVariant.active,
        emphasized: true,
      ),
      rightPanel: _CouponInfoPanel(
        title: coupon.name,
        titleEnabled: true,
        expiryText: coupon.expiresAt != null
            ? l10n.couponValidUntil(_formatDate(coupon.expiresAt!))
            : null,
        secondaryText: coupon.totalQuota != null
            ? l10n.couponQuotaLeft(coupon.totalQuota!)
            : null,
        action: _ClaimAction(
          claiming: _claiming,
          claimed: claimed,
          onClaim: _claim,
        ),
      ),
    );
  }
}

// ── Shared card shell (white card + dashed divider + shadow) ────────────────

class _CouponShell extends StatelessWidget {
  const _CouponShell({required this.leftPanel, required this.rightPanel});
  final Widget leftPanel;
  final Widget rightPanel;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        // 每張優惠券的外框：用較淡的分隔線色，不要太重。
        border: Border.all(color: appTheme.divider),
        boxShadow: appTheme.elevation2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              leftPanel,
              SizedBox(
                width: 1,
                child: CustomPaint(
                  painter: _DashedDividerPainter(
                    color: colorScheme.outlineVariant,
                  ),
                ),
              ),
              Expanded(child: rightPanel),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left discount panel ─────────────────────────────────────────────────────

class _DiscountPanel extends StatelessWidget {
  const _DiscountPanel({
    required this.label,
    required this.variant,
    this.emphasized = false,
  });

  final String label;
  final _CouponVariant variant;

  /// `true` for claimable coupons: solid primary background + white text.
  /// `false` (default) for member coupons: tinted primary container.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    final palette = appTheme.brandPalette;
    final (bg, fg) = switch ((variant, emphasized)) {
      (_CouponVariant.active, true) => (palette.tone400, Colors.white),
      (_CouponVariant.active, false) => (palette.tone50, palette.tone500),
      (_CouponVariant.used, _) || (_CouponVariant.expired, _) => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
    };

    return Container(
      width: 120,
      padding: EdgeInsets.all(appTheme.spacingLg),
      color: bg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CouponIcon(
            size: 42,
            dimmed: variant != _CouponVariant.active,
            // 領取更多優惠卡（實心品牌底）→ icon 反轉為白色。
            inverted: emphasized,
          ),
          SizedBox(height: appTheme.spacingSm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Right info panel ────────────────────────────────────────────────────────

class _CouponInfoPanel extends StatelessWidget {
  const _CouponInfoPanel({
    required this.title,
    required this.titleEnabled,
    this.description,
    required this.expiryText,
    this.secondaryText,
    required this.action,
  });

  final String title;
  final bool titleEnabled;
  final String? description;
  final String? expiryText;
  final String? secondaryText;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appTheme = context.appTheme;

    return Padding(
      padding: EdgeInsets.all(appTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: titleEnabled
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          if (description != null && description!.isNotEmpty) ...[
            SizedBox(height: appTheme.spacingSm),
            Text(
              description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
          if (expiryText != null) ...[
            SizedBox(height: appTheme.spacingSm),
            Text(
              expiryText!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (secondaryText != null) ...[
            SizedBox(height: appTheme.spacingXs),
            Text(
              secondaryText!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: appTheme.spacingSm),
          Align(alignment: Alignment.centerRight, child: action),
        ],
      ),
    );
  }
}

// ── Card action buttons ─────────────────────────────────────────────────────

class _CardAction extends StatelessWidget {
  const _CardAction({required this.variant});
  final _CouponVariant variant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = context.appTheme;

    final isActive = variant == _CouponVariant.active;
    final label = variant == _CouponVariant.used
        ? l10n.couponUsedStamp
        : variant == _CouponVariant.expired
            ? l10n.couponTabExpired
            : l10n.couponUseNow;

    final palette = appTheme.brandPalette;
    final fg = isActive ? palette.tone500 : colorScheme.onSurfaceVariant;
    final borderColor =
        isActive ? palette.tone200 : colorScheme.outlineVariant;

    return OutlinedButton(
      onPressed: isActive ? () {} : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        disabledForegroundColor: colorScheme.onSurfaceVariant,
        side: BorderSide(color: borderColor),
        padding: EdgeInsets.symmetric(
          horizontal: appTheme.spacingMd,
          vertical: appTheme.spacingSm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        ),
      ),
      child: Text(label),
    );
  }
}

class _ClaimAction extends StatelessWidget {
  const _ClaimAction({
    required this.claiming,
    required this.claimed,
    required this.onClaim,
  });

  final bool claiming;
  final bool claimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final appTheme = context.appTheme;

    if (claimed) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: appTheme.spacingMd,
          vertical: appTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        ),
        child: Text(
          l10n.couponClaimed,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return FilledButton(
      onPressed: claiming ? null : onClaim,
      style: FilledButton.styleFrom(
        backgroundColor: appTheme.brandPalette.tone500,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: appTheme.spacingMd,
          vertical: appTheme.spacingSm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        ),
      ),
      child: claiming
          ? SizedBox(
              width: 14,
              height: 14,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(l10n.couponClaim),
    );
  }
}

// ── Empty / error states ────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appTheme = context.appTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CouponIcon(size: 80, dimmed: true),
          SizedBox(height: appTheme.spacingLg),
          Text(
            text,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appTheme = context.appTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: appTheme.spacingMd),
          Text(
            l10n.couponLoadFailed,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: appTheme.spacingSm),
          TextButton(onPressed: onRetry, child: Text(l10n.couponRetry)),
        ],
      ),
    );
  }
}

// ── Coupon SVG icon (brand-colored by default; gray when dimmed) ───────────
// The asset's fills are SmartLive purple by design; at runtime we remap them
// to the merchant's `brandPalette` tones via flutter_svg's `ColorMapper`, so
// the icon always picks up the white-label theme without shipping per-brand
// SVG variants. The gray (dimmed) variant stays untinted on purpose — it
// signals "used / expired" regardless of brand color.

class _CouponIcon extends StatelessWidget {
  const _CouponIcon({
    required this.size,
    this.dimmed = false,
    this.inverted = false,
  });
  final double size;
  final bool dimmed;

  /// `true` 時把 icon 反轉為白色剪影，用於實心品牌底的「領取更多優惠」卡。
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    if (dimmed) {
      return SvgPicture.asset(
        'assets/icons/coupon_gray.svg',
        width: size,
        height: size,
      );
    }
    if (inverted) {
      return SvgPicture.asset(
        'assets/icons/coupon_white.svg',
        width: size,
        height: size,
      );
    }
    return SvgPicture.asset(
      'assets/icons/coupon.svg',
      width: size,
      height: size,
      colorMapper: _CouponBrandColorMapper(context.appTheme.brandPalette),
    );
  }
}

/// Substitutes the SmartLive-purple defaults baked into `coupon.svg` with
/// brand-palette tones so the icon follows the merchant's theme.
///   • Ticket body  (#7008E7 / #3D0F91)  → tone500 / tone700  (main brand)
///   • Bow ribbon   (#FB7185 / #E11D48)  → tone300 / tone400  (lighter brand)
///   • Highlights   (#F8F3FF)            → tone50              (near-white)
/// Any color not in the map passes through unchanged.
class _CouponBrandColorMapper extends ColorMapper {
  const _CouponBrandColorMapper(this.palette);
  final BrandPalette palette;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    switch (color.toARGB32()) {
      case 0xFF7008E7:
        return palette.tone500;
      case 0xFF3D0F91:
        return palette.tone700;
      case 0xFFFB7185:
        return palette.tone300;
      case 0xFFE11D48:
        return palette.tone400;
      case 0xFFF8F3FF:
        return palette.tone50;
      default:
        return color;
    }
  }
}

// ── Dashed vertical divider ─────────────────────────────────────────────────

class _DashedDividerPainter extends CustomPainter {
  const _DashedDividerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, (y + dashHeight).clamp(0, size.height)),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
