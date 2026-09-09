import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';

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
                                fontSize: 14, color: appTheme.fgMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              _Header(count: favorites.length, showCount: true),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(appTheme.spacingMd),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.productGridColumns(context),
                    crossAxisSpacing: appTheme.spacingMd,
                    mainAxisSpacing: appTheme.spacingMd,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, i) {
                    final fav = favorites[i];
                    final p = fav.product;
                    final scheme = Theme.of(context).colorScheme;

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: scheme.surfaceContainerHighest,
                                  child: Icon(Icons.image_outlined,
                                      size: 40,
                                      color: scheme.onSurfaceVariant),
                                ),
                                if (!p.inStock)
                                  Container(
                                    color: Colors.black54,
                                    child: const Center(
                                      child: Text('已售完',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                if (p.originalPrice != null)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: appTheme.danger,
                                        borderRadius:
                                            BorderRadius.circular(
                                                appTheme.radiusSm),
                                      ),
                                      child: const Text('特價',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: appTheme.bgElev,
                                      shape: BoxShape.circle,
                                      boxShadow: appTheme.elevation1,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.favorite,
                                          color: appTheme.danger, size: 16),
                                      onPressed: () {},
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(appTheme.spacingSm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12, color: appTheme.fg)),
                                Text(fav.streamer,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: appTheme.fgMuted)),
                                SizedBox(height: appTheme.spacingXs),
                                Row(
                                  children: [
                                    Text(
                                      'NT\$${p.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: scheme.primary),
                                    ),
                                    if (p.originalPrice != null) ...[
                                      SizedBox(width: appTheme.spacingXs),
                                      Text(
                                        'NT\$${p.originalPrice!.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: appTheme.fgMuted,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: appTheme.spacingSm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 28,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient:
                                                appTheme.primaryGradient,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    appTheme.buttonRadius),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: p.inStock
                                                ? () => ref
                                                    .read(cartProvider
                                                        .notifier)
                                                    .addItem(p)
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor:
                                                  Colors.transparent,
                                              padding: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        appTheme
                                                            .buttonRadius),
                                              ),
                                            ),
                                            child: Text(
                                                p.inStock ? '加入購物車' : '已售完',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: appTheme.spacingSm),
                                    SizedBox(
                                      height: 28,
                                      width: 28,
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          side: BorderSide(
                                              color: appTheme.divider),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    appTheme.buttonRadius),
                                          ),
                                        ),
                                        child: Icon(Icons.delete_outline,
                                            size: 14,
                                            color: appTheme.fgMuted),
                                      ),
                                    ),
                                  ],
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
                style:
                    TextStyle(fontSize: 14, color: appTheme.fgMuted)),
          ],
        ],
      ),
    );
  }
}
