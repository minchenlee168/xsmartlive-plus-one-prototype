import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../screens/shop/combo_data.dart';
import '../screens/shop/combo_picker.dart';
import '../theme/app_theme_extension.dart';

/// prototype：標準商品卡需要庫存數，這裡以商品 id 衍生穩定的庫存
/// （少數為 0 呈現「已售完」情境）。
int previewStockFor(Product p) {
  final n = p.id.hashCode.abs() % 60;
  return n < 3 ? 0 : n;
}

/// prototype：依商品分類回傳可選規格；回傳空清單代表「無規格」，可直接加入購物車。
List<String> productSpecOptions(Product p) {
  switch (p.category) {
    case 'g_apparel':
      return const ['S', 'M', 'L', 'XL'];
    case 'g_beauty':
    case 'h_makeup':
      return const ['#01 裸粉', '#02 蜜桃', '#03 玫瑰'];
    case 'h_skincare':
    case 'h_body':
      return const ['30ml', '50ml', '100ml'];
    default:
      return const [];
  }
}

/// 標準商品卡：圖 + 名稱 + 售價 + 庫存 + 數量選擇 + 加入購物車。
///
/// 用於主題館與主題館頁；加入購物車按鈕為白色 ＋ + 購物車 icon。
/// 若商品有規格（[productSpecOptions] 非空），按加入購物車會先跳出選規格彈窗。
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
    // 任選組合商品：不顯示庫存與數量選擇（改由挑選彈窗決定），按鈕開挑選彈窗。
    final combo = comboForId(p.id);

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
        // 卡片依內容高度收合，避免在等比 grid 中被撐高留白。
        mainAxisSize: MainAxisSize.min,
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
                // 點名稱導向商品內頁。
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => context.push('/product/${p.id}'),
                  // 固定保留兩行高度，讓一行 / 兩行名稱的卡片等高，
                  // 橫向列不會因短名稱在底部留下多餘空白。
                  child: SizedBox(
                    height: 13 * 1.3 * 2,
                    child: Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                          color: appTheme.fg),
                    ),
                  ),
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
                if (combo == null) ...[
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
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: FilledButton(
                    onPressed: soldOut
                        ? null
                        : () {
                            // 任選組合 → 開挑選組合彈窗；有規格 → 選規格彈窗；
                            // 否則直接加入。
                            if (combo != null) {
                              showComboSheet(context, combo);
                              return;
                            }
                            final specs = productSpecOptions(p);
                            if (specs.isEmpty) {
                              _addToCart(null);
                            } else {
                              _showSpecSheet(specs);
                            }
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

  void _addToCart(String? spec) {
    final name = widget.product.name;
    final label = spec == null ? '$name ×$_qty' : '$name（$spec）×$_qty';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('已加入購物車：$label')));
  }

  /// 有規格的商品：跳出彈窗選規格，選完才能加入購物車。
  Future<void> _showSpecSheet(List<String> specs) async {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final p = widget.product;

    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: appTheme.bgElev,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        String? selected;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 拖曳握把
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: appTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 商品資訊
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: appTheme.bgSubtle,
                          borderRadius:
                              BorderRadius.circular(appTheme.radiusSm),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.image_outlined,
                            size: 22, color: appTheme.fgMuted),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: appTheme.fg,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NT\$${p.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '選擇規格',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in specs)
                        _SpecChip(
                          label: s,
                          selected: selected == s,
                          onTap: () => setSheetState(() => selected = s),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: selected == null
                          ? null
                          : () => Navigator.of(sheetContext).pop(selected),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        disabledBackgroundColor:
                            accent.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(appTheme.buttonRadius),
                        ),
                      ),
                      child: const Text(
                        '加入購物車',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (chosen != null && mounted) _addToCart(chosen);
  }
}

/// 規格選項 chip（單選）。
class _SpecChip extends StatelessWidget {
  const _SpecChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Material(
      color: selected ? accent.withValues(alpha: 0.12) : appTheme.bgSubtle,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(
              color: selected ? accent : appTheme.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? accent : appTheme.fg,
            ),
          ),
        ),
      ),
    );
  }
}
