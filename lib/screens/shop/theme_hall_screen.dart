import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme_extension.dart';
import '../../widgets/shop_product_card.dart';
import '../../widgets/standard_product_card.dart';
import 'theme_hall_data.dart';

/// 主題館頁：由商城主題館標題右側「查看更多」進入。
/// 呈現主題館標題、banner，以及該主題館的所有商品卡。
class ThemeHallScreen extends StatelessWidget {
  const ThemeHallScreen({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    if (index < 0 || index >= themeHalls.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('主題館')),
        body: Center(
          child: Text('找不到此主題館',
              style: TextStyle(color: appTheme.fgMuted)),
        ),
      );
    }

    final hall = themeHalls[index];

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: Text(hall.title),
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
          // 標題（accent bar + 標題）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Banner（比例對照設計稿 ≈ 2000:620）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
          ),
          // 該主題館的所有商品卡（格狀）。
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: hall.standard ? 0.66 : 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = hall.items[i];
                  return hall.standard
                      ? StandardProductCard(
                          product: item.product, stock: item.stock)
                      : ShopProductCard(product: item.product);
                },
                childCount: hall.items.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
