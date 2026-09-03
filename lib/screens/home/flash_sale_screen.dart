import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/standard_product_card.dart';

/// 限時搶購頁：由首頁「限時搶購」標題右側「查看更多」進入。
/// 呈現標題 banner 與全部限時搶購商品（標準商品卡）。
class FlashSaleScreen extends ConsumerWidget {
  const FlashSaleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final products =
        ref.watch(productListProvider(const ProductFilter())).valueOrNull
                ?.products ??
            const [];

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: const Text('限時搶購'),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: appTheme.fg),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Banner（比例對照主題館 ≈ 2000:620）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚡ 限時搶購',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '限時特賣 · 售完不補',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '−40%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 全部限時搶購商品（標準商品卡，固定卡寬、依內容收合高度）。
          if (products.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Text('目前沒有限時搶購商品',
                      style: TextStyle(color: appTheme.fgMuted)),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  const hPad = 16.0;
                  final avail = constraints.maxWidth - hPad * 2;
                  final cols = (avail / 190).floor().clamp(2, 6);
                  final cardW = (avail - spacing * (cols - 1)) / cols;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
                    child: Wrap(
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
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
