import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/banner.dart';
import '../../utils/platform_preview.dart';
import '../../models/product_group.dart';
import '../../models/store_collection.dart';
import '../../models/stream_board_item.dart';
import '../../providers/content_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';
import '../../widgets/shop_product_card.dart';
import '../../widgets/standard_product_card.dart';
import 'theme_hall_data.dart';

/// Shop screen — corresponds to prototype `src/screens/catalog.jsx` plus
/// the carousel + live announcement sections that the merchant requires
/// us to keep.
///
/// Order:
///   1. Header (商城 title + search + cart icons)
///   2. Horizontal category chips (全部 / 群組...)
///   3. Sort row (熱銷 / 最新 / 價格↑ / 價格↓)
///   4. Banner carousel (kept from previous version)
///   5. 直播公告 (kept from previous version)
///   6. 2-column product grid using [ShopProductCard]
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(productGroupsProvider);

    return Scaffold(
      backgroundColor: context.appTheme.bg,
      body: Responsive.centeredBox(
        context,
        child: groupsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text(
                  AppLocalizations.of(context)!.shopLoadCategoryError(e.toString()))),
          data: (groups) => _ShopBody(groups: groups),
        ),
      ),
    );
  }
}


class _ShopBody extends ConsumerStatefulWidget {
  const _ShopBody({required this.groups});

  final List<ProductGroup> groups;

  @override
  ConsumerState<_ShopBody> createState() => _ShopBodyState();
}

class _ShopBodyState extends ConsumerState<_ShopBody> {
  String? _selectedGroupId;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return CustomScrollView(
      slivers: [
        // 1. Header
        SliverToBoxAdapter(
          child: _ShopHeader(
            onSearchTap: () => context.push('/search'),
            onCartTap: () => context.go('/cart'),
          ),
        ),
        // 2. Category chips
        SliverToBoxAdapter(
          child: _CategoryChips(
            groups: widget.groups,
            selectedId: _selectedGroupId,
            onSelect: (id) =>
                setState(() => _selectedGroupId = id.isEmpty ? null : id),
          ),
        ),
        // 4. Banner carousel (kept)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            appTheme.spacingLg,
            appTheme.spacingSm,
            appTheme.spacingLg,
            0,
          ),
          sliver: const SliverToBoxAdapter(child: _BannerSection()),
        ),
        // 5. 直播公告 (kept)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            appTheme.spacingLg,
            appTheme.spacingLg,
            appTheme.spacingLg,
            0,
          ),
          sliver: const SliverToBoxAdapter(child: _LiveAnnouncementSection()),
        ),
        // 5a. 主題館 (B8) — 移到直播公告下方：每個主題館一標題 + 一 banner +
        //     該主題館的商品卡。主題館下方不再放其他商品卡。
        SliverToBoxAdapter(
          child: _StoreCollectionSection(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 24 + bottomInset),
        ),
      ],
    );
  }
}

// ── Header (title + search + cart) ────────────────────────────────────────
class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.onSearchTap, required this.onCartTap});

  final VoidCallback onSearchTap;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).viewPadding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        topPadding + 16,
        20,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.navShop,
              style: GoogleFonts.getFont(
                appTheme.fontDisplay,
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: appTheme.fontWeightDisplay,
                  color: appTheme.fg,
                ),
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.search,
            onTap: onSearchTap,
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.shopping_cart_outlined,
            onTap: onCartTap,
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
    final appTheme = context.appTheme;
    return Material(
      color: appTheme.bgSubtle,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: appTheme.fg),
        ),
      ),
    );
  }
}

// ── Horizontal category chip rail ────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.groups,
    required this.selectedId,
    required this.onSelect,
  });

  final List<ProductGroup> groups;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final accent = appTheme.brandPalette.tone500;

    final all = <(String, String)>[
      ('', l10n.shopCategoryAll),
      ...groups.map((g) => (g.id, g.name)),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: all.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (id, label) = all[i];
          final selected = (selectedId ?? '') == id;
          return Material(
            color: selected ? accent : appTheme.chip,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              // 「全部」原地顯示；其餘分類跳到分類頁（含子分類篩選 + 商品）。
              onTap: () => id.isEmpty
                  ? onSelect(id)
                  : context.push('/shop/category/$id'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? cs.onPrimary : appTheme.chipFg,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Banner carousel ───────────────────────────────────────────────────────

class _BannerSection extends ConsumerStatefulWidget {
  const _BannerSection();

  @override
  ConsumerState<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<_BannerSection> {
  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int count) {
    if (count <= 1) return;
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % count;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final bannersAsync = ref.watch(bannerListProvider);

    const height = 147.0;
    final radius = BorderRadius.circular(appTheme.buttonRadius);

    return bannersAsync.when(
      loading: () => SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: appTheme.bgElev,
            borderRadius: radius,
            border: Border.all(color: appTheme.divider),
          ),
          child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAutoScroll(banners.length);
        });

        return ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _BannerSlide(banner: banners[i]),
                ),
                if (banners.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(banners.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentPage == i ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.banner});
  final StoreBanner banner;

  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.imageUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(context),
              )
            : _placeholder(context),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  banner.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (banner.mark != null && banner.mark!.isNotEmpty)
                  Text(
                    banner.mark!,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: context.appTheme.primaryGradient),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white54, size: 40),
      ),
    );
  }
}

// ── 直播公告 ─────────────────────────────────────────────────────────────
// POST /v1/mall/store/{storeId}/streamBoard/list — up to 5 announcements.
// Hidden when the API returns empty or errors so merchants without active
// announcements don't see a dead band.

class _LiveAnnouncementSection extends ConsumerWidget {
  const _LiveAnnouncementSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final boardsAsync = ref.watch(streamBoardListProvider);

    Widget header() => Padding(
          padding: EdgeInsets.symmetric(vertical: appTheme.spacingMd),
          child: Row(
            children: [
              Expanded(
                child: Container(height: 1, color: appTheme.divider),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: appTheme.spacingLg,
                ),
                child: Text(
                  '公告',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: appTheme.fg,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: appTheme.divider),
              ),
            ],
          ),
        );

    return boardsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: appTheme.spacingXxl),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header(),
            for (var i = 0; i < items.length; i++) ...[
              _LiveAnnouncementCard(item: items[i]),
              if (i < items.length - 1)
                SizedBox(height: appTheme.spacingMd),
            ],
          ],
        );
      },
    );
  }
}

class _LiveAnnouncementCard extends StatelessWidget {
  const _LiveAnnouncementCard({required this.item});

  final StreamBoardItem item;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final body = item.plainContent;
    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        border: Border.all(color: appTheme.divider),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: appTheme.spacingXl,
        vertical: appTheme.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appTheme.fg,
            ),
          ),
          if (body.isNotEmpty) ...[
            SizedBox(height: appTheme.spacingLg),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: appTheme.fg,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 主題館 (B8) — horizontal-scroll cards. Hidden when API returns empty so
//    merchants without curated collections don't see an empty band.
class _StoreCollectionSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    // Web 預覽：每個主題館一標題 + 一 banner + 該主題館商品卡。
    if (isWebPreview) return const _ThemeHallSections();
    final collectionsAsync = ref.watch(storeCollectionsProvider);
    final collections =
        collectionsAsync.valueOrNull ?? const <StoreCollection>[];
    if (collections.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        appTheme.spacingLg,
        appTheme.spacingLg,
        0,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: appTheme.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: appTheme.brandPalette.tone500,
                    borderRadius:
                        BorderRadius.circular(appTheme.spacingXxs),
                  ),
                ),
                SizedBox(width: appTheme.spacingSm),
                Text(
                  '主題館',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: appTheme.fg,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: appTheme.spacingMd),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(right: appTheme.spacingLg),
              itemCount: collections.length,
              separatorBuilder: (_, _) => SizedBox(width: appTheme.spacingSm),
              itemBuilder: (context, i) =>
                  _StoreCollectionCard(collection: collections[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 主題館（web 預覽）：每館一標題 + 一 banner + 該館商品卡 ──────────────
class _ThemeHallSections extends StatelessWidget {
  const _ThemeHallSections();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (hi, hall) in themeHalls.indexed) ...[
          // 標題（最右邊有「查看更多」導向該主題館頁）
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hall.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => context.push('/shop/theme-hall/$hi'),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '查看更多',
                          style: TextStyle(
                            fontSize: 12,
                            color: appTheme.fgMuted,
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 16, color: appTheme.fgMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Banner（比例對照設計稿 ≈ 2000:620）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 2000 / 620,
              child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(appTheme.cardRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent.withValues(alpha: 0.65)],
                ),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hall.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hall.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ),
          ),
          const SizedBox(height: 12),
          // 該主題館的商品卡（橫向捲動）：標準卡有數量選擇 + 庫存；精簡卡較簡潔。
          SizedBox(
            height: hall.standard ? 266 : 256,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: hall.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: hall.standard ? 176 : 150,
                child: hall.standard
                    ? StandardProductCard(
                        product: hall.items[i].product,
                        stock: hall.items[i].stock,
                      )
                    : ShopProductCard(product: hall.items[i].product),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StoreCollectionCard extends StatelessWidget {
  const _StoreCollectionCard({required this.collection});

  final StoreCollection collection;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return SizedBox(
      width: 200,
      child: Material(
        color: appTheme.bgElev,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: InkWell(
          onTap: () {
            final name =
                collection.name.isNotEmpty ? collection.name : '主題館';
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  SnackBar(content: Text('主題館「$name」內容開發中')));
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(appTheme.cardRadius),
              border: Border.all(color: appTheme.divider),
            ),
            child: Stack(
          children: [
            if (collection.imageUrl != null)
              Positioned.fill(
                child: Image.network(
                  collection.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(color: appTheme.bgSubtle),
                ),
              )
            else
              Container(color: appTheme.bgSubtle),
            // Bottom gradient + label so text stays readable on photos.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            if (collection.isPinned)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '置頂',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name.isNotEmpty ? collection.name : '主題館',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (collection.typeLabel.isNotEmpty)
                    Text(
                      collection.typeLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
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
