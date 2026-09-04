import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/live_stream.dart';
import '../../models/product.dart';
import '../../providers/live_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';
import '../../widgets/standard_product_card.dart';

/// Home screen — corresponds to the React prototype `src/screens/home.jsx`.
///
/// Phase 2 scope (current): Hero header, search bar pill, categories grid,
/// replays carousel skeleton, weekly schedule placeholder card. Most data
/// sources are wired to existing providers; missing-API sections render
/// graceful empty states with TODO markers for the backend team.
///
/// Phase 4 scope (future): real replays endpoint, real schedule endpoint,
/// flash-sale countdown, recommended products grid.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final categoriesAsync = ref.watch(categoriesProvider);
    final livePageAsync = ref.watch(livePageProvider);

    return Container(
      color: appTheme.bg,
      child: Responsive.centeredBox(
        context,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _HeroHeader(
              tagline: l10n.homeHeroTagline,
              brand: l10n.homeHeroBrand,
              searchPlaceholder: l10n.homeSearchPlaceholder,
              searchGoLabel: l10n.homeSearchGo,
              onSearchTap: () => context.push('/search'),
              onBellTap: () => context.push('/notifications'),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: l10n.homeSectionReplays,
              actionLabel: l10n.homeViewAll,
              onAction: () => context.go('/live'),
            ),
            const SizedBox(height: 12),
            _ReplaysCarousel(livePageAsync: livePageAsync),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.homeSectionCategories),
            const SizedBox(height: 12),
            _CategoriesGrid(categoriesAsync: categoriesAsync),
            const SizedBox(height: 24),
            _SectionHeader(
              title: l10n.homeSectionLiveAnnouncement,
              actionLabel: l10n.homeViewAll,
              onAction: () => context.go('/live'),
            ),
            const SizedBox(height: 12),
            _WeeklyScheduleCard(title: l10n.homeSectionWeeklySchedule),
            const SizedBox(height: 24),
            _SectionHeader(
              title: '⚡ 限時搶購',
              // 與主題館一致：顯示「查看更多」並導向限時搶購頁。
              actionLabel: '查看更多',
              onAction: () => context.push('/flash-sale'),
            ),
            const SizedBox(height: 12),
            const _FlashSaleSection(),
            const SizedBox(height: 24),
            const _SectionHeader(title: '💎 為你推薦'),
            const SizedBox(height: 12),
            const _RecommendedSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Flash sale — gradient banner (countdown + −40%) followed by 4 product
// cards in a 2×2 grid. Mirrors home.jsx flash sale block.
// ───────────────────────────────────────────────────────────────────────────
class _FlashSaleSection extends ConsumerWidget {
  const _FlashSaleSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final productsAsync =
        ref.watch(productListProvider(const ProductFilter()));
    final products =
        productsAsync.valueOrNull?.products.take(4).toList(growable: false) ??
            const [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appTheme.brandPalette.tone500.withValues(alpha: 0.10),
                  appTheme.accent.withValues(alpha: 0.10),
                ],
              ),
              border: Border.all(color: appTheme.divider),
              borderRadius: BorderRadius.circular(appTheme.cardRadius),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '距結束',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: appTheme.fgMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _CountdownDisplay(seconds: 3854),
                  ],
                ),
                const Spacer(),
                Text(
                  '−40%',
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: appTheme.brandPalette.tone500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (products.isNotEmpty) ...[
            const SizedBox(height: 14),
            // 限時搶購商品卡比照主題館：標準商品卡（庫存 + 數量 + ＋購物車）。
            _StandardCardWrap(products: products),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 標準商品卡的自適應排版（固定卡寬、依內容收合高度），比照主題館頁。
// ───────────────────────────────────────────────────────────────────────────
class _StandardCardWrap extends StatelessWidget {
  const _StandardCardWrap({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final avail = constraints.maxWidth;
        final cols = (avail / 190).floor().clamp(2, 6);
        final cardW = (avail - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final p in products)
              SizedBox(
                width: cardW,
                child: StandardProductCard(
                  product: p,
                  stock: previewStockFor(p),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Recommended — 4 product cards in 2×2 grid (uses items 4..8 of list).
// ───────────────────────────────────────────────────────────────────────────
class _RecommendedSection extends ConsumerWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync =
        ref.watch(productListProvider(const ProductFilter()));
    final all = productsAsync.valueOrNull?.products ?? const [];
    final products = all.length > 4
        ? all.skip(4).take(4).toList(growable: false)
        : all.take(4).toList(growable: false);
    if (products.isEmpty) return const SizedBox.shrink();
    // 為你推薦比照限時搶購：標準商品卡。
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _StandardCardWrap(products: products),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// HH:MM:SS countdown — black mono blocks ticking once per second.
// ───────────────────────────────────────────────────────────────────────────
class _CountdownDisplay extends StatefulWidget {
  const _CountdownDisplay({required this.seconds});
  final int seconds;

  @override
  State<_CountdownDisplay> createState() => _CountdownDisplayState();
}

class _CountdownDisplayState extends State<_CountdownDisplay> {
  late int _s;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _s = widget.seconds;
    _ticker = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _ticker.listen((_) {
      if (!mounted) return;
      setState(() {
        if (_s > 0) _s -= 1;
      });
    });
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _s ~/ 3600;
    final m = (_s % 3600) ~/ 60;
    final sec = _s % 60;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CountdownBlock(text: _pad(h)),
        const _CountdownColon(),
        _CountdownBlock(text: _pad(m)),
        const _CountdownColon(),
        _CountdownBlock(text: _pad(sec)),
      ],
    );
  }
}

class _CountdownBlock extends StatelessWidget {
  const _CountdownBlock({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: appTheme.fg,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          color: appTheme.bg,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _CountdownColon extends StatelessWidget {
  const _CountdownColon();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: appTheme.fg,
        ),
      ),
    );
  }
}


// ───────────────────────────────────────────────────────────────────────────
// Hero header
// ───────────────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.tagline,
    required this.brand,
    required this.searchPlaceholder,
    required this.searchGoLabel,
    required this.onSearchTap,
    required this.onBellTap,
  });

  final String tagline;
  final String brand;
  final String searchPlaceholder;
  final String searchGoLabel;
  final VoidCallback onSearchTap;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 16,
        left: 20,
        right: 20,
        bottom: 22,
      ),
      decoration: BoxDecoration(
        gradient: appTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(appTheme.radiusLg),
          bottomRight: Radius.circular(appTheme.radiusLg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagline,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      brand,
                      style: GoogleFonts.getFont(
                        appTheme.fontDisplay,
                        textStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: appTheme.fontWeightDisplay,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _CircleIconButton(
                icon: Icons.search,
                onTap: onSearchTap,
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                icon: Icons.notifications_none_outlined,
                onTap: onBellTap,
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Search bar pill
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              height: 46,
              padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(appTheme.cardRadius),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: appTheme.fgMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      searchPlaceholder,
                      style: TextStyle(
                        fontSize: 14,
                        color: appTheme.fgMuted,
                      ),
                    ),
                  ),
                  Container(
                    height: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    decoration: BoxDecoration(
                      color: appTheme.brandPalette.tone500,
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      searchGoLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Section header (title + optional "view all" action)
// ───────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.getFont(
                appTheme.fontDisplay,
                textStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: appTheme.fontWeightDisplay,
                  color: appTheme.fg,
                ),
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '$actionLabel ›',
                  style: TextStyle(
                    fontSize: 12,
                    color: appTheme.fgMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Replays / short videos horizontal carousel
// ───────────────────────────────────────────────────────────────────────────
class _ReplaysCarousel extends StatelessWidget {
  const _ReplaysCarousel({required this.livePageAsync});

  // TODO(API): GET /lives/replays?limit=10  — currently we render the
  // active live streams as carousel items because replays are not yet
  // exposed by the backend.
  final AsyncValue<LivePageState> livePageAsync;

  @override
  Widget build(BuildContext context) {
    final pageState = livePageAsync.valueOrNull;
    final live = <LiveStream>[
      if (pageState?.currentLive != null) pageState!.currentLive!,
      ...?pageState?.historicalLives,
    ];
    final placeholders = live.isNotEmpty
        ? live.take(6).toList()
        : List<LiveStream?>.filled(3, null);

    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: placeholders.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = placeholders[i];
          return _ReplayCard(
            title: item?.title ?? '',
            thumbnail: item?.thumbnail ?? '',
            duration: item != null ? '直播中' : '00:00',
          );
        },
      ),
    );
  }
}

class _ReplayCard extends StatelessWidget {
  const _ReplayCard({
    required this.title,
    required this.thumbnail,
    required this.duration,
  });

  final String title;
  final String thumbnail;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: appTheme.bgSubtle,
                borderRadius: BorderRadius.circular(appTheme.cardRadius),
                image: thumbnail.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(thumbnail),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: appTheme.elevation1,
              ),
              child: Stack(
                children: [
                  if (thumbnail.isEmpty)
                    Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: appTheme.fgMuted,
                        size: 36,
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow,
                              color: Colors.white, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title.isNotEmpty ? title : '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: appTheme.fg,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Categories — 5-up grid mirrored from prototype
// ───────────────────────────────────────────────────────────────────────────
class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid({required this.categoriesAsync});

  final AsyncValue<dynamic> categoriesAsync;

  // Maps prototype category index → label + bundled asset PNG. Keeps the
  // UI looking right even when `categoriesProvider` returns nothing /
  // before the merchant has uploaded their own category artwork.
  static const _fallback = [
    (
      label: '臉部保養',
      asset: 'assets/prototype/categories/01_skincare.png',
      id: 'h_skincare'
    ),
    (
      label: '彩妝',
      asset: 'assets/prototype/categories/02_makeup.png',
      id: 'h_makeup'
    ),
    (
      label: '香氛',
      asset: 'assets/prototype/categories/03_fragrance.png',
      id: 'h_fragrance'
    ),
    (
      label: '身體護理',
      asset: 'assets/prototype/categories/04_body.png',
      id: 'h_body'
    ),
    (label: '男士', asset: 'assets/prototype/categories/05_men.png', id: 'h_men'),
  ];

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final categories = categoriesAsync.valueOrNull as List? ?? const [];
    // Always use prototype assets for category artwork — even when the
    // backend supplies category names, it doesn't yet supply images.
    // `// TODO(API): GET /categories should include image_url so we can
    // drop the bundled assets and render merchant-uploaded category art.`
    final items = categories.isNotEmpty
        ? List.generate(
            categories.take(5).length,
            (i) => (
              label: (categories[i].name as String?) ?? _fallback[i].label,
              asset: _fallback[i % _fallback.length].asset,
              id: (categories[i].id as String?) ?? _fallback[i].id,
            ),
          )
        : _fallback;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (i) {
          final c = items[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(appTheme.cardRadius),
                onTap: () => context.push('/shop/category/${c.id}'),
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(appTheme.cardRadius),
                        child: Container(
                          color: appTheme.bgSubtle,
                          child: Image.asset(
                            c.asset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.image_outlined,
                              color: appTheme.fgMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: appTheme.fg,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Weekly schedule placeholder card
// ───────────────────────────────────────────────────────────────────────────
class _WeeklyScheduleCard extends StatelessWidget {
  const _WeeklyScheduleCard({required this.title});
  final String title;

  // TODO(API): GET /lives/schedule?week=current  — currently shows a
  // hardcoded mock until the backend exposes upcoming live sessions.
  static const _mockSchedule = [
    (day: '週三', time: '20:00', title: '春夏保養新品開箱會', tag: '新品週'),
    (day: '週五', time: '21:00', title: '時尚妝容挑戰', tag: '直播限定'),
  ];

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          border: Border.all(color: appTheme.divider),
          boxShadow: appTheme.elevation1,
        ),
        child: Column(
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: BoxDecoration(
                gradient: appTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(appTheme.cardRadius),
                  topRight: Radius.circular(appTheme.cardRadius),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '春夏保養新品週 ✨',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            ..._mockSchedule.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: i < _mockSchedule.length - 1
                        ? BorderSide(color: appTheme.divider)
                        : BorderSide.none,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Column(
                        children: [
                          Text(
                            s.day,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: appTheme.fgMuted,
                            ),
                          ),
                          Text(
                            s.time,
                            style: GoogleFonts.getFont(
                              appTheme.fontDisplay,
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: appTheme.brandPalette.tone500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: appTheme.fg,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: appTheme.chip,
                              borderRadius:
                                  BorderRadius.circular(appTheme.radiusSm),
                            ),
                            child: Text(
                              '✨ ${s.tag}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: appTheme.chipFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.notifications_none_outlined,
                        color: appTheme.fgMuted, size: 18),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
