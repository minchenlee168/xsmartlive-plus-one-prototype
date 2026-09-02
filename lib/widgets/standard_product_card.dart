import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme_extension.dart';

/// 標準商品卡：圖 + 名稱 + 售價 + 庫存 + 數量選擇 + 加入購物車。
///
/// 用於主題館與主題館頁；加入購物車按鈕為白色 ＋ + 購物車 icon。
class StandardProductCard extends StatefulWidget {
  const StandardProductCard({
    super.key,
    required this.product,
    required this.stock,
  });

  final Product product;
  final int stock;

  @override
  State<StandardProductCard> createState() => _StandardProductCardState();
}

class _StandardProductCardState extends State<StandardProductCard> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final p = widget.product;
    final soldOut = widget.stock <= 0;

    Widget stepBtn(IconData icon,
        {required bool enabled, required VoidCallback onTap}) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: appTheme.bgSubtle,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(color: appTheme.divider),
          ),
          alignment: Alignment.center,
          child: Icon(icon,
              size: 15, color: enabled ? appTheme.fg : appTheme.muted),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 圖片（prototype 佔位）
          Container(
            height: 104,
            width: double.infinity,
            color: appTheme.bgSubtle,
            alignment: Alignment.center,
            child: Icon(Icons.image_outlined,
                size: 26, color: appTheme.fgMuted),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: appTheme.fg),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'NT\$${p.price.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: accent),
                    ),
                    if (p.originalPrice != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        'NT\$${p.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: appTheme.fgMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  soldOut ? '已售完' : '庫存 ${widget.stock}',
                  style: TextStyle(
                    fontSize: 11,
                    color: soldOut ? appTheme.danger : appTheme.fgMuted,
                  ),
                ),
                const SizedBox(height: 8),
                // 數量選擇
                Row(
                  children: [
                    stepBtn(Icons.remove,
                        enabled: !soldOut && _qty > 1,
                        onTap: () => setState(() => _qty--)),
                    Expanded(
                      child: Text(
                        '$_qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: appTheme.fg),
                      ),
                    ),
                    stepBtn(Icons.add,
                        enabled: !soldOut && _qty < widget.stock,
                        onTap: () => setState(() => _qty++)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: FilledButton(
                    onPressed: soldOut
                        ? null
                        : () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                  content:
                                      Text('已加入購物車：${p.name} ×$_qty')));
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(appTheme.buttonRadius),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Icon(Icons.shopping_cart_outlined,
                            size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
