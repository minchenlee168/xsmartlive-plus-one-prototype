import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/repository_providers.dart';
import '../screens/shop/combo_data.dart';
import '../theme/app_theme_extension.dart';
import 'cart_fly_animation.dart';

/// Prototype-aligned product card. Shared between Home (`為你推薦` /
/// 限時搶購) and the Shop catalog grid.
///
/// - Discount badge top-left
/// - Heart toggle top-right (local-only fav state for now)
/// - Name (2 lines) + price + crossed-out original
/// - 已售 N + "+" button bottom row
/// - Tapping "+" launches the theme-keyed cart-fly FX, calls
///   [onAddToCart] (defaults to `cartProvider.addItem(product)`).
class ShopProductCard extends ConsumerStatefulWidget {
  const ShopProductCard({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  final Product product;

  /// Optional override. Default behavior adds the product to the local
  /// in-memory cart via [cartProvider]. Pass a callback if you need
  /// server-synced cart calls (e.g. winMallBid).
  final VoidCallback? onAddToCart;

  @override
  ConsumerState<ShopProductCard> createState() => _ShopProductCardState();
}

class _ShopProductCardState extends ConsumerState<ShopProductCard>
    with SingleTickerProviderStateMixin {
  final _addBtnKey = GlobalKey();
  late final AnimationController _pulseCtrl;
  bool _favLocal = false;

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

  // Sales fallback — when API hasn't filled in `sales` yet, derive a
  // stable mock from the product id so the UI doesn't read "已售 0" in
  // dev. TODO(API): drop the fallback once `sales` is populated server-side.
  int get _soldCount {
    if (widget.product.sales > 0) return widget.product.sales;
    return 50 + (widget.product.id.hashCode.abs() % 250);
  }

  bool _adding = false;

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

    // 任選組合商品 → 開商品內頁（內含挑選組合區），不走一般加入購物車流程。
    if (comboForId(widget.product.id) != null) {
      GoRouter.of(context).push('/product/${widget.product.id}');
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

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: appTheme.fg,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(0)}',
                          style: GoogleFonts.getFont(
                            appTheme.fontDisplay,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                        ),
                        if (hasOriginal) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.originalPrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: appTheme.fgMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '已售 $_soldCount',
                          style: TextStyle(
                            fontSize: 10,
                            color: appTheme.fgMuted,
                          ),
                        ),
                        const Spacer(),
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
