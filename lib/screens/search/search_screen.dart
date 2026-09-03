import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/content_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/back_leading_button.dart';

/// Search screen — corresponds to prototype `src/screens/search.jsx`.
///
/// Two states:
///   - **No query**: hot searches grid (ranked) + categories grid + history
///   - **With query**: results section (TODO Phase 4 full grid)
///
/// History persists in-memory only for now; Phase 5 may persist to
/// SharedPreferences if recall across sessions is desired.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _histories = <String>[];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _histories.removeWhere((h) => h == query);
      _histories.insert(0, query);
    });
    ref.read(selectedCategoryProvider.notifier).state = null;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        leading: const BackLeadingButton(fallbackLocation: '/home'),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: appTheme.bgSubtle,
            borderRadius: BorderRadius.circular(appTheme.cardRadius),
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: appTheme.fgMuted),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  style: TextStyle(fontSize: 14, color: appTheme.fg),
                  decoration: InputDecoration(
                    hintText: l10n.searchScreenHint,
                    hintStyle: TextStyle(
                        fontSize: 14, color: appTheme.fgMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: _search,
                ),
              ),
              GestureDetector(
                onTap: () => _search(_ctrl.text),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appTheme.brandPalette.tone500,
                    borderRadius:
                        BorderRadius.circular(appTheme.radiusSm),
                  ),
                  child: Text(
                    l10n.homeSearchGo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.trending_up,
              title: l10n.searchHotTitle,
              iconColor: appTheme.danger,
            ),
            const SizedBox(height: 12),
            _HotKeywordsGrid(onSearch: _search),
            const SizedBox(height: 24),
            _SectionTitle(
              icon: AppIcons.shop,
              title: l10n.homeSectionCategories,
              iconColor: appTheme.brandPalette.tone500,
            ),
            const SizedBox(height: 12),
            const _CategoryGrid(),
            if (_histories.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle(
                    icon: Icons.history,
                    title: l10n.searchHistoryTitle,
                    iconColor: appTheme.fgMuted,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _histories.clear()),
                    style: TextButton.styleFrom(
                      foregroundColor: appTheme.fgMuted,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(l10n.searchHistoryClear),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _histories
                    .map((h) => GestureDetector(
                          onTap: () => _search(h),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: appTheme.chip,
                              borderRadius: BorderRadius.circular(
                                  appTheme.chipRadius),
                            ),
                            child: Text(
                              h,
                              style: TextStyle(
                                fontSize: 12,
                                color: appTheme.chipFg,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: appTheme.fg,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Hot keywords grid (API-driven via keywordListProvider)
// ───────────────────────────────────────────────────────────────────────────
// ───────────────────────────────────────────────────────────────────────────
// Category grid (4-col with icon tiles) — mirrors prototype no-query state
// ───────────────────────────────────────────────────────────────────────────
class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid();

  static const _fallback = [
    (label: '臉部保養', asset: 'assets/prototype/categories/01_skincare.png'),
    (label: '彩妝', asset: 'assets/prototype/categories/02_makeup.png'),
    (label: '香氛', asset: 'assets/prototype/categories/03_fragrance.png'),
    (label: '身體護理', asset: 'assets/prototype/categories/04_body.png'),
    (label: '男士', asset: 'assets/prototype/categories/05_men.png'),
    (label: '時尚', asset: 'assets/prototype/categories/02_makeup.png'),
    (label: '配件', asset: 'assets/prototype/categories/03_fragrance.png'),
    (label: '更多', asset: 'assets/prototype/categories/04_body.png'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _fallback.length,
      itemBuilder: (context, i) {
        final c = _fallback[i];
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(appTheme.cardRadius),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Image.asset(
                  c.asset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: appTheme.bgSubtle,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_outlined,
                        color: appTheme.fgMuted),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              c.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: appTheme.fg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HotKeywordsGrid extends ConsumerWidget {
  const _HotKeywordsGrid({required this.onSearch});
  final void Function(String) onSearch;

  static const _fallback = <String>[
    '春季新品', '美妝教學', '居家用品', '運動服飾',
    '時尚配件', '護膚保養', '鞋類特賣', '包包推薦',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final keywordsAsync = ref.watch(keywordListProvider);

    final keywords = keywordsAsync.when(
      loading: () => null,
      error: (_, _) => _fallback,
      data: (list) =>
          list.isEmpty ? _fallback : list.map((k) => k.displayText).toList(),
    );

    if (keywords == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.6,
      ),
      itemCount: keywords.length,
      itemBuilder: (context, i) {
        final rank = i + 1;
        return Material(
          color: appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(appTheme.cardRadius),
            onTap: () => onSearch(keywords[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(appTheme.cardRadius),
                border: Border.all(color: appTheme.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      gradient: rank <= 3
                          ? appTheme.primaryGradient
                          : null,
                      color: rank <= 3 ? null : appTheme.chip,
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3
                              ? Colors.white
                              : appTheme.chipFg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      keywords[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: appTheme.fg,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
