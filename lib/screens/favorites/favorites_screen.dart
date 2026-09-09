import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.bg,
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('載入失敗：$e',
                style: TextStyle(color: appTheme.fgMuted))),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Column(
              children: [
                _Header(count: 0, showCount: false),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 64, color: appTheme.muted),
                        SizedBox(height: appTheme.spacingLg),
                        Text('還沒有最愛的商品',
                            style: TextStyle(color: appTheme.fgMuted)),
                        SizedBox(height: appTheme.spacingXs),
                        Text('快去直播間挖掘喜歡的商品吧！',
                            style: TextStyle(
                                fontSize: 12, color: appTheme.fgMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          // 收藏卡改用共用「標準商品卡」ProductCard，與全站商品卡樣式一致；
          // 右上疊一顆愛心作為「移除收藏」入口（原型：目前為佔位）。
          return Column(
            children: [
              _Header(count: favorites.length, showCount: true),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final spacing = appTheme.spacingMd;
                    final hPad = appTheme.spacingMd;
                    final avail = constraints.maxWidth - hPad * 2;
                    final cols = (avail / 190).floor().clamp(2, 6);
                    final cardW = (avail - spacing * (cols - 1)) / cols;
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(appTheme.spacingMd),
                      child: Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final fav in favorites)
                            SizedBox(
                              width: cardW,
                              child: Stack(
                                children: [
                                  ProductCard(
                                    variant: ProductCardVariant.standard,
                                    product: fav.product,
                                    stock: previewStockFor(fav.product),
                                  ),
                                  Positioned(
                                    top: appTheme.spacingSm,
                                    right: appTheme.spacingSm,
                                    child: _RemoveFavButton(onTap: () {}),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 收藏卡右上角的「移除收藏」愛心鈕（原型：佔位）。
class _RemoveFavButton extends StatelessWidget {
  const _RemoveFavButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Material(
      color: appTheme.bgElev,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(Icons.favorite, color: appTheme.danger, size: 16),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count, required this.showCount});
  final int count;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      width: double.infinity,
      color: appTheme.bgElev,
      padding: EdgeInsets.fromLTRB(
        appTheme.spacingLg,
        MediaQuery.of(context).viewPadding.top + 56,
        appTheme.spacingLg,
        showCount ? appTheme.spacingSm : appTheme.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('我的最愛',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: appTheme.fg,
              )),
          if (showCount) ...[
            SizedBox(height: appTheme.spacingXs),
            Text('$count 件商品',
                style: TextStyle(fontSize: 12, color: appTheme.fgMuted)),
          ],
        ],
      ),
    );
  }
}
