import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/live_stream.dart';
import '../../models/social_post_market.dart';
import '../../providers/live_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';

/// Live List — corresponds to prototype `src/screens/live.jsx` `LiveList()`.
///
/// Layout:
///   - Sticky header (title + viewer subtitle)
///   - 3 pill tabs (直播中 / 即將開播 / 回放)
///   - Featured 16:10 card (current live, if any) with LIVE badge + viewers
///   - 2-col 3:4 grid (historical / upcoming)
///
/// Wires to existing `livePageProvider`. Two prototype tabs (即將開播 / 回放)
/// don't have dedicated APIs yet — they fall back to filtering
/// `historicalLives` until backend exposes proper endpoints:
///   `// TODO(API): GET /lives/upcoming`
///   `// TODO(API): GET /lives/replays`
class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key});

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  _Tab _selected = _Tab.live;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final pageAsync = ref.watch(livePageProvider);
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Container(
      color: appTheme.bg,
      child: pageAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            Center(child: Text(l10n.liveLoadError(e.toString()))),
        data: (state) {
          final featured = state.currentLive;
          final upcoming = const <LiveStream>[]; // TODO(API): /lives/upcoming
          final replays = state.historicalLives;
          final liveCount = featured != null ? 1 : 0;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: topPadding + 16),
              _Header(
                title: l10n.navLive,
                subtitle:
                    '$liveCount 場直播進行中 · 即將開播 ${upcoming.length} 場',
              ),
              const SizedBox(height: 16),
              _PillTabs(
                selected: _selected,
                onChange: (t) => setState(() => _selected = t),
              ),
              const SizedBox(height: 16),
              if (_selected == _Tab.live) ...[
                if (featured != null) _FeaturedCard(stream: featured),
                if (state.historicalLives.isNotEmpty)
                  _Grid(streams: state.historicalLives),
                // ── B11: 社團 / 粉絲團貼文賣場 ───────────────────────────
                const _SocialPostSection(
                  title: '社團貼文賣場',
                  variant: _SocialVariant.group,
                ),
                const _SocialPostSection(
                  title: '粉絲團貼文賣場',
                  variant: _SocialVariant.fanPage,
                ),
              ] else if (_selected == _Tab.upcoming) ...[
                if (upcoming.isEmpty) _EmptyTab(label: '近期沒有預告場次'),
              ] else if (_selected == _Tab.replay) ...[
                if (replays.isEmpty)
                  _EmptyTab(label: '尚無回放')
                else
                  _Grid(streams: replays),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

enum _Tab { live, upcoming, replay }

// ───────────────────────────────────────────────────────────────────────────
// Header
// ───────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.getFont(
              appTheme.fontDisplay,
              textStyle: TextStyle(
                fontSize: 26,
                fontWeight: appTheme.fontWeightDisplay,
                color: appTheme.fg,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 3 pill tabs
// ───────────────────────────────────────────────────────────────────────────
class _PillTabs extends StatelessWidget {
  const _PillTabs({required this.selected, required this.onChange});
  final _Tab selected;
  final void Function(_Tab) onChange;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final tabs = <(_Tab, String)>[
      (_Tab.live, '🔴 直播中'),
      (_Tab.upcoming, '即將開播'),
      (_Tab.replay, '回放'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.map((t) {
          final isSelected = t.$1 == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onChange(t.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? appTheme.brandPalette.tone500
                      : appTheme.chip,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : appTheme.chipFg,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Featured 16:10 card
// ───────────────────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.stream});
  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GestureDetector(
        onTap: () => context.push('/live/room/${stream.id}'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (stream.thumbnail.isNotEmpty)
                  Image.network(stream.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                            'assets/prototype/live_host.jpg',
                            fit: BoxFit.cover,
                          ))
                else
                  Image.asset(
                    'assets/prototype/live_host.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: BoxDecoration(
                          gradient: appTheme.primaryGradient),
                    ),
                  ),
                // Bottom gradient
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Color(0xD9000000),
                          Color(0x00000000),
                        ],
                        stops: [0.0, 0.6],
                      ),
                    ),
                  ),
                ),
                // Top badges
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      _LiveBadge(color: appTheme.danger),
                      const SizedBox(width: 8),
                      _ViewerCountChip(viewers: stream.viewers),
                    ],
                  ),
                ),
                // Bottom text
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stream.streamer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stream.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
// 2-col grid of small live cards
// ───────────────────────────────────────────────────────────────────────────
class _Grid extends StatelessWidget {
  const _Grid({required this.streams});
  final List<LiveStream> streams;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.productGridColumns(context),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
        itemCount: streams.length,
        itemBuilder: (context, i) => _GridCard(stream: streams[i]),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.stream});
  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return GestureDetector(
      onTap: () => context.push('/live/room/${stream.id}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (stream.thumbnail.isNotEmpty)
              Image.network(stream.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: appTheme.bgSubtle))
            else
              Container(
                decoration:
                    BoxDecoration(gradient: appTheme.primaryGradient),
              ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xD9000000), Color(0x00000000)],
                    stops: [0.0, 0.5],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Row(
                children: [
                  _LiveBadge(color: appTheme.danger, compact: true),
                  const SizedBox(width: 6),
                  if (stream.viewers > 0)
                    _ViewerCountChip(
                        viewers: stream.viewers, compact: true),
                ],
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stream.streamer.isNotEmpty
                        ? stream.streamer
                        : stream.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (stream.streamer.isNotEmpty)
                    Text(
                      stream.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Shared badges
// ───────────────────────────────────────────────────────────────────────────
class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.color, this.compact = false});
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 7,
            height: compact ? 5 : 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 3 : 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerCountChip extends StatelessWidget {
  const _ViewerCountChip(
      {required this.viewers, this.compact = false});
  final int viewers;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final formatted = viewers > 999
        ? '${(viewers / 1000).toStringAsFixed(1)}k'
        : '$viewers';
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.eye,
              color: Colors.white, size: compact ? 10 : 12),
          const SizedBox(width: 3),
          Text(
            formatted,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Empty tab placeholder
// ───────────────────────────────────────────────────────────────────────────
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.live, color: appTheme.fgMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(color: appTheme.fgMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 社團 / 粉絲團貼文賣場 (B11) ──────────────────────────────────────────────
//
// Hidden when the matching API returns no items so non-social merchants
// don't see empty bands. Both endpoints share the same shape so one widget
// drives both via `variant`.

enum _SocialVariant { group, fanPage }

class _SocialPostSection extends ConsumerWidget {
  const _SocialPostSection({required this.title, required this.variant});

  final String title;
  final _SocialVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final async = ref.watch(variant == _SocialVariant.group
        ? groupPostMarketsProvider
        : fanPagePostMarketsProvider);
    final items = async.valueOrNull ?? const <SocialPostMarket>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Icon(
                  variant == _SocialVariant.group
                      ? Icons.groups_outlined
                      : Icons.thumb_up_alt_outlined,
                  size: 18,
                  color: appTheme.brandPalette.tone500,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: appTheme.fg,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '(${items.length})',
                  style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 116,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 20),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) =>
                  _SocialPostCard(item: items[i], variant: variant),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialPostCard extends StatelessWidget {
  const _SocialPostCard({required this.item, required this.variant});

  final SocialPostMarket item;
  final _SocialVariant variant;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.marketTypeLabel.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.marketTypeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ),
              const Spacer(),
              if (item.isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
              if (item.isActive) const SizedBox(width: 4),
              if (item.isActive)
                Text(
                  '進行中',
                  style: TextStyle(
                    fontSize: 10,
                    color: appTheme.fgMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            (item.name ?? '').isNotEmpty ? item.name! : '貼文賣場 #${item.id}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: appTheme.fg,
              height: 1.35,
            ),
          ),
          const Spacer(),
          if (item.providerPostId != null)
            Text(
              variant == _SocialVariant.group ? '社團貼文' : '粉絲團貼文',
              style: TextStyle(fontSize: 10, color: appTheme.fgMuted),
            ),
        ],
      ),
    );
  }
}
