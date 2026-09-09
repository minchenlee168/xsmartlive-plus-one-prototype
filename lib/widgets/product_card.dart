import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/repository_providers.dart';
import '../screens/shop/combo_data.dart';
import '../screens/shop/combo_picker.dart';
import '../theme/app_theme_extension.dart';
import 'cart_fly_animation.dart';

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

/// 商品卡的兩種變體。
/// - [standard]：圖 + 名稱 + 售價 + 庫存 + 數量選擇 + 加入購物車（主題館 / 首頁 / 分類）。
/// - [compact]：折扣 badge + 愛心 + 名稱 + 價格 + cart-fly 加入購物車（精簡卡）。
enum ProductCardVariant { standard, compact }

/// 合併後的商品卡，依 [variant] 分流呈現標準卡或精簡卡。
///
/// standard 變體：圖 + 名稱 + 售價 + 庫存 + 數量選擇 + 加入購物車按鈕（白色 ＋ + 購物車 icon）。
/// 若商品有規格（[productSpecOptions] 非空），按加入購物車會先跳出選規格彈窗。
///
/// compact 變體：折扣 badge（左上）+ 愛心（右上）+ 名稱（2 行）+ 價格 + 「＋」按鈕，
/// 按「＋」播放 cart-fly 動畫並走 server cartApi 加入購物車，可用 [onAddToCart] 覆寫。
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.variant = ProductCardVariant.standard,
    this.stock = 0,
    this.imageAspectRatio,
    this.onAddToCart,
  });

  final Product product;

  /// 卡片變體，預設為標準卡。
  final ProductCardVariant variant;

  /// standard 變體使用的庫存數。
  final int stock;

  /// standard 變體選填：圖片長寬比（例如 1.0 = 方形，對照設計稿的網格）。
  /// null 時圖片用固定 1:1 方形（首頁 / 主題館橫向列）。
  final double? imageAspectRatio;

  /// compact 變體選填覆寫。預設行為透過 server cartApi 加入購物車；
  /// 傳入 callback 可覆寫（例如 winMallBid）。
  final VoidCallback? onAddToCart;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  // 標準卡狀態
  int _qty = 1;

  // 精簡卡狀態
  final _addBtnKey = GlobalKey();
  late final AnimationController _pulseCtrl;
  bool _favLocal = false;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case ProductCardVariant.standard:
        return _buildStandard(context);
      case ProductCardVariant.compact:
        return _buildCompact(context);
    }
  }

  // ---------------------------------------------------------------------------
  // 標準卡
  // ---------------------------------------------------------------------------

  Widget _buildStandard(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final p = widget.product;
    final soldOut = widget.stock <= 0;
    // 任選組合商品：不顯示庫存與數量選擇（改由挑選彈窗決定），按鈕開挑選彈窗。
    final combo = comboForId(p.id);
    // 網格模式（imageAspectRatio 有值，如分類頁）採用較寬鬆、協調的比例；
    // 主題館橫向列（null）維持原本緊湊版型。
    final grid = widget.imageAspectRatio != null;
    final stepSize = grid ? 28.0 : 26.0;
    // 網格模式字級收斂到階梯（14/12）；橫向緊湊列維持原值（out of scope）。
    // 名稱 16 / w600（卡片標題級，手機清楚易讀）；原價/庫存 11。
    const nameSize = 16.0;
    const metaSize = 11.0; // 原價 / 庫存
    final qtySize = grid ? 14.0 : 13.0;

    Widget stepBtn(IconData icon,
        {required bool enabled, required VoidCallback onTap}) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        child: Container(
          width: stepSize,
          height: stepSize,
          decoration: BoxDecoration(
            color: appTheme.bgSubtle,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(color: appTheme.divider),
          ),
          alignment: Alignment.center,
          child: Icon(icon,
              size: grid ? 16 : 15,
              color: enabled ? appTheme.fg : appTheme.muted),
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
          // 圖片（prototype 佔位）；imageAspectRatio 指定時用等比方形。
          if (widget.imageAspectRatio != null)
            AspectRatio(
              aspectRatio: widget.imageAspectRatio!,
              child: Container(
                width: double.infinity,
                color: appTheme.bgSubtle,
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined,
                    size: 26, color: appTheme.fgMuted),
              ),
            )
          else
            // 非網格（首頁 / 主題館）：圖片用 1:1 方形，與精簡卡（compact）
            // 一致，讓全站商品卡圖片比例統一。不同寬度的卡片圖片皆等比例方形。
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                color: appTheme.bgSubtle,
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined,
                    size: 26, color: appTheme.fgMuted),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(grid ? appTheme.spacingMd : 8),
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
                    height: nameSize * 1.3 * 2,
                    child: Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: nameSize,
                          height: 1.3,
                          // 卡片標題級：w600，手機清楚。
                          fontWeight: FontWeight.w600,
                          color: appTheme.fg),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 售價（品牌襯線 16/w800）；刪除線原價放在售價「下方」一行。
                Text(
                  'NT\$${p.price.toStringAsFixed(0)}',
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                // 永遠保留原價這一行的高度（沒原價時留等高空位），讓所有卡等高、
                // grid 不會有的高有的矮。
                const SizedBox(height: 2),
                SizedBox(
                  height: metaSize * 1.35,
                  child: p.originalPrice != null
                      ? Text(
                          'NT\$${p.originalPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: metaSize,
                            color: appTheme.fgMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        )
                      : null,
                ),
                if (combo == null) ...[
                  SizedBox(height: grid ? appTheme.spacingSm : 4),
                  Text(
                    soldOut ? '已售完' : '庫存 ${widget.stock}',
                    style: TextStyle(
                      fontSize: metaSize,
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
                          style: TextStyle(fontSize: qtySize, color: appTheme.fg),
                        ),
                      ),
                      stepBtn(Icons.add,
                          enabled: !soldOut && _qty < widget.stock,
                          onTap: () => setState(() => _qty++)),
                    ],
                  ),
                ],
                SizedBox(height: grid ? appTheme.spacingMd : 8),
                SizedBox(
                  width: double.infinity,
                  height: grid ? 36 : 32,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 16, color: Colors.white),
                        SizedBox(width: appTheme.spacingXs),
                        const Icon(Icons.shopping_cart_outlined,
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
    // 真的加進購物車（依數量），不只跳提示——標準卡各處（首頁 / 分類 / 商城 /
    // 我的最愛）加入購物車皆生效。
    final notifier = ref.read(cartProvider.notifier);
    for (var i = 0; i < _qty; i++) {
      notifier.addItem(widget.product);
    }
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
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '選擇規格',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          fontSize: 16,
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

  // ---------------------------------------------------------------------------
  // 精簡卡（compact）
  // ---------------------------------------------------------------------------

  /// Tap-to-add. Plays the cart-fly animation + button pulse immediately
  /// so the buyer gets feedback, then performs the real server-side add
  /// asynchronously: fetches the product card detail to resolve a
  /// `marketId` + `productCardVariantId`, then calls
  /// `cartApiProvider.addItem` (which hits `winMallBid` + invalidates the
  /// cart so the badge updates).
  ///
  /// Caller can override the API behaviour entirely via [onAddToCart].
  Future<void> _onAddTap() async {
    if (_adding) return;

    // 任選組合商品 → 開挑選組合彈窗（不走一般加入購物車流程）。
    final combo = comboForId(widget.product.id);
    if (combo != null) {
      showComboSheet(context, combo);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    // 1. Visual feedback first (independent of API success).
    final btnCtx = _addBtnKey.currentContext;
    if (btnCtx != null) {
      final box = btnCtx.findRenderObject();
      if (box is RenderBox && box.attached) {
        final origin = box.localToGlobal(Offset.zero) +
            Offset(box.size.width / 2, box.size.height / 2);
        CartFlyAnimation.fly(
          context: context,
          ref: ref,
          originGlobal: origin,
        );
      }
    }
    _pulseCtrl.forward(from: 0);

    // 2. Caller-provided handler wins if present.
    if (widget.onAddToCart != null) {
      widget.onAddToCart!();
      return;
    }

    // 3. Default: server cart via winMallBid → cartApi refresh.
    setState(() => _adding = true);
    try {
      final detail = await ref
          .read(productRepositoryProvider)
          .fetchProductCardDetail(widget.product.id);
      final marketId = detail?.marketId ?? 0;
      final firstVariantId =
          (detail != null && detail.variants.isNotEmpty)
              ? detail.variants.first.id
              : 0;
      if (marketId <= 0 || firstVariantId <= 0) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('商品規格載入失敗，請稍後再試'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      await ref.read(cartApiProvider.notifier).addItem(
            variantId: firstVariantId,
            marketId: marketId,
            cardType: detail!.type,
            quantity: 1,
          );
      // Keep the local in-memory cart in sync too (used by some
      // UI counters that haven't migrated to cartApi yet).
      ref.read(cartProvider.notifier).addItem(widget.product);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('加入購物車失敗:$e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Widget _buildCompact(BuildContext context) {
    final appTheme = context.appTheme;
    final product = widget.product;
    final hasOriginal = product.originalPrice != null &&
        product.originalPrice! > product.price;
    final discount = hasOriginal
        ? (100 - (product.price / product.originalPrice! * 100)).round()
        : 0;
    final accent = appTheme.brandPalette.tone500;

    return Material(
      color: appTheme.bgElev,
      borderRadius: BorderRadius.circular(appTheme.cardRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        onTap: () => GoRouter.of(context).push('/product/${product.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(appTheme.cardRadius),
            border: Border.all(color: appTheme.divider),
            boxShadow: appTheme.elevation1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image w/ discount badge + heart toggle
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(appTheme.cardRadius),
                          topRight: Radius.circular(appTheme.cardRadius),
                        ),
                        child: product.image.isNotEmpty
                            ? Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: appTheme.bgSubtle,
                                  alignment: Alignment.center,
                                  child: Icon(Icons.image_outlined,
                                      color: appTheme.fgMuted),
                                ),
                              )
                            : Container(
                                color: appTheme.bgSubtle,
                                alignment: Alignment.center,
                                child: Icon(Icons.image_outlined,
                                    color: appTheme.fgMuted),
                              ),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius:
                                BorderRadius.circular(appTheme.radiusSm),
                          ),
                          child: Text(
                            '−$discount%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _favLocal = !_favLocal),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _favLocal
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: _favLocal ? accent : appTheme.fgMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 固定保留兩行高度，讓一行 / 兩行名稱的卡片等高，
                    // 橫向列不會因短名稱在底部留下多餘空白。
                    SizedBox(
                      height: 16 * 1.3 * 2,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: appTheme.fg,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    // 售價（品牌襯線 16/w800）；刪除線原價放在售價「下方」一行。
                    Text(
                      'NT\$${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.getFont(
                        appTheme.fontDisplay,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                    // 永遠保留原價這一行的高度（沒原價時留等高空位），讓所有卡等高。
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 11 * 1.35,
                      child: hasOriginal
                          ? Text(
                              'NT\$${product.originalPrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: appTheme.fgMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    // 「＋」按鈕靠右（已移除「已售 N」文字）。
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (ctx, child) {
                            final t = _pulseCtrl.value;
                            final scale = t < 0.45
                                ? 1.0 - (t / 0.45) * 0.08
                                : 0.92 + ((t - 0.45) / 0.55) * 0.08;
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          child: SizedBox(
                            key: _addBtnKey,
                            width: 26,
                            height: 26,
                            child: Material(
                              color: accent,
                              borderRadius: BorderRadius.circular(
                                  appTheme.radiusSm),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    appTheme.radiusSm),
                                onTap: _onAddTap,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? accent : appTheme.fg,
            ),
          ),
        ),
      ),
    );
  }
}
