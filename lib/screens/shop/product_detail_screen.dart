import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/claimable_coupon.dart';
import '../../models/product.dart';
import '../../models/product_bundle_item.dart';
import '../../models/product_card_detail.dart';
import '../../models/product_spec.dart';
import '../../models/product_variant.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../cart/cart_screen.dart';
import 'combo_data.dart';
import 'combo_picker.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productCardId});

  final String productCardId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;

  /// specGroupId → selected specValueId
  final Map<int, int> _selectedSpecValues = {};

  int _quantity = 1;

  /// Returns the sale price of the variant that best matches [specValueId]
  /// within [specGroupId], taking other current selections into account.
  double? _priceForSpecValue(
    List<ProductVariant> variants,
    int specGroupId,
    int specValueId,
  ) {
    final otherIds = {
      for (final e in _selectedSpecValues.entries)
        if (e.key != specGroupId) e.value,
    };
    for (final v in variants) {
      final ids = v.specs.map((s) => s['id'] as int? ?? 0).toSet();
      if (ids.contains(specValueId) && otherIds.every(ids.contains)) {
        return v.salePrice;
      }
    }
    return null;
  }

  /// Returns true if at least one variant exists that contains [specValueId]
  /// and is compatible with all other currently selected spec values.
  bool _isSpecValueAvailable(
    List<ProductVariant> variants,
    int specGroupId,
    int specValueId,
  ) {
    final otherIds = {
      for (final e in _selectedSpecValues.entries)
        if (e.key != specGroupId) e.value,
    };
    return variants.any((v) {
      final ids = v.specs.map((s) => s['id'] as int? ?? 0).toSet();
      return ids.contains(specValueId) && otherIds.every(ids.contains);
    });
  }

  /// Returns the variant that matches all currently selected spec values,
  /// or the first variant when nothing is selected yet.
  ProductVariant? _findMatchingVariant(List<ProductVariant> variants) {
    if (variants.isEmpty) return null;
    if (_selectedSpecValues.isEmpty) return variants.first;
    final selectedIds = _selectedSpecValues.values.toSet();
    for (final v in variants) {
      final variantSpecIds =
          v.specs.map((s) => s['id'] as int? ?? 0).toSet();
      if (selectedIds.every(variantSpecIds.contains)) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(productCardDetailProvider(widget.productCardId));

    final appTheme = context.appTheme;
    return Scaffold(
      backgroundColor: appTheme.bg,
      extendBodyBehindAppBar: true,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('載入失敗：$e',
                style: TextStyle(color: appTheme.fgMuted))),
        data: (detail) {
          if (detail == null) {
            return Center(
                child: Text('找不到商品',
                    style: TextStyle(color: appTheme.fgMuted)));
          }
          final variant = _findMatchingVariant(detail.variants);
          return _buildBody(context, detail, variant);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProductCardDetail detail,
    ProductVariant? variant,
  ) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    // 任選組合商品：中間區改顯示組合挑選，並隱藏一般底部加入購物車列。
    final combo = comboForId(widget.productCardId);
    final price = variant?.salePrice ?? detail.minSalePrice;
    final originalPrice = variant?.originalPrice ?? detail.minOriginalPrice;
    final inStock = variant != null
        ? (variant.inStock || detail.allowOversell)
        : detail.inStock;
    final discount = (originalPrice != null && originalPrice > price)
        ? (100 - (price / originalPrice * 100)).round()
        : 0;
    final soldCount = 50 + (detail.id.hashCode.abs() % 250);
    final stockCount = variant?.stock ?? 0;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero image (edge-to-edge 1:1 + page pill) ──
                    _ImageGallery(
                      images: detail.images,
                      currentIndex: _currentImageIndex,
                      onPageChanged: (i) =>
                          setState(() => _currentImageIndex = i),
                    ),
                    // ── Price block — overlaps hero by -12px, rounded top
                    Transform.translate(
                      offset: const Offset(0, -12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: appTheme.bgElev,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(appTheme.radiusLg),
                            topRight: Radius.circular(appTheme.radiusLg),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price row: NT$ prefix + display-font price +
                            // crossed-out original + discount pill.
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'NT\$',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  price.toStringAsFixed(0),
                                  style: GoogleFonts.getFont(
                                    appTheme.fontDisplay,
                                    textStyle: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                if (originalPrice != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${originalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: appTheme.fgMuted,
                                      decoration:
                                          TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                                if (discount > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accent,
                                      borderRadius: BorderRadius.circular(
                                          appTheme.radiusSm),
                                    ),
                                    child: Text(
                                      '−$discount%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                // 任選組合以中間挑選區為準，不顯示單一庫存徽章。
                                if (combo == null)
                                  _StockBadge(inStock: inStock),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Name
                            Text(
                              detail.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: appTheme.fg,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Sold + remaining + rating row
                            Row(
                              children: [
                                Text(
                                  '已售 $soldCount',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: appTheme.fgMuted,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (stockCount > 0)
                                  Text(
                                    '剩 $stockCount 件',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: appTheme.fgMuted,
                                    ),
                                  ),
                                const SizedBox(width: 16),
                                Text(
                                  '★ 4.8 (124 評價)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.success,
                                  ),
                                ),
                              ],
                            ),
                            // Category + tag pills (same style) inline at
                            // the bottom of the price card.
                            if (detail.category.isNotEmpty ||
                                detail.tags.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (detail.category.isNotEmpty)
                                    _TagPill(
                                        label: detail.category,
                                        color: accent),
                                  for (final tag in detail.tags)
                                    _TagPill(label: tag, color: accent),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // ── Options card: coupon + specs + quantity ──
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CouponRow(
                            onTap: () => _showCouponSheet(context),
                          ),
                          // 任選組合商品：中間顯示組合挑選（含加入購物車）。
                          if (combo != null) ...[
                            Divider(height: 28, color: appTheme.divider),
                            ComboPicker(
                                config: combo, mode: ComboMode.page),
                          ] else ...[
                            if (detail.hasSpec &&
                                detail.specs.isNotEmpty) ...[
                              Divider(height: 28, color: appTheme.divider),
                              _SpecSelector(
                                specs: detail.specs,
                                selected:
                                    Map.unmodifiable(_selectedSpecValues),
                                onSelect: (specId, valueId) => setState(() =>
                                    _selectedSpecValues[specId] = valueId),
                                priceFor: (groupId, valueId) =>
                                    _priceForSpecValue(
                                        detail.variants, groupId, valueId),
                                isEnabled: (groupId, valueId) =>
                                    _isSpecValueAvailable(
                                        detail.variants, groupId, valueId),
                              ),
                            ],
                            Divider(height: 28, color: appTheme.divider),
                            _QuantityRow(
                              // 售完（stock 0）時上限需 ≥ 下限，否則 clamp(1,0)
                              // 會丟 ArgumentError（Invalid argument: 1）。
                              quantity: _quantity
                                  .clamp(
                                      1,
                                      (variant?.stock ?? 1) < 1
                                          ? 1
                                          : (variant?.stock ?? 1))
                                  .toInt(),
                              stock: variant?.stock ?? 0,
                              enabled: inStock && variant != null,
                              onChanged: (q) =>
                                  setState(() => _quantity = q),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ── 商品詳情 card: title + attribute grid + intro ──
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '商品詳情',
                            style: GoogleFonts.getFont(
                              appTheme.fontDisplay,
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: appTheme.fontWeightDisplay,
                                color: appTheme.fg,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _AttributeGrid(detail: detail),
                          if (detail.intro.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: appTheme.bgSubtle,
                                borderRadius: BorderRadius.circular(
                                    appTheme.cardRadius),
                              ),
                              child: Text(
                                detail.intro,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: appTheme.fg,
                                    height: 1.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ── 評價 card ──
                    // TODO(API): GET /products/{id}/reviews
                    const _SectionCard(
                      child: _ReviewsSection(totalReviews: 124),
                    ),
                    // ── Bundle products card (if any) ──
                    if (detail.bundleItems.isNotEmpty)
                      _SectionCard(
                        child:
                            _BundleProductsSection(items: detail.bundleItems),
                      ),
                    // ── Upsell 加價購 (B9) ──
                    _SectionCard(
                      child: _UpsellSection(
                        filter: UpsellFilter(
                          productId: detail.productId,
                          cardType: detail.type,
                          categoryId: detail.categoryId,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
              ],
            ),
          ),
              // Floating glass header — back / cart / share buttons
              // overlaid on top of the hero image.
              Positioned(
                top: MediaQuery.of(context).viewPadding.top + 8,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassHeaderButton(
                      icon: Icons.arrow_back_ios_new,
                      // 有上一頁就返回；若無（例如直接開啟商品網址、無返回堆疊）
                      // 則導回商城，避免按返回沒有反應。用 go_router 的 canPop
                      // 才能正確反映路由堆疊。
                      onTap: () {
                        final router = GoRouter.of(context);
                        if (router.canPop()) {
                          router.pop();
                        } else {
                          context.go('/shop');
                        }
                      },
                    ),
                    Row(
                      children: [
                        _GlassHeaderButton(
                          icon: Icons.shopping_cart_outlined,
                          onTap: () => Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (ctx) => Scaffold(
                                backgroundColor: ctx.appTheme.bg,
                                body: const CartScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _GlassHeaderButton(
                          icon: Icons.ios_share,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom add-to-cart bar（任選組合改由中間挑選區的加入購物車，故隱藏）
        if (combo == null)
          _BottomBar(
            inStock: inStock,
            marketId: detail.marketId,
            cardType: detail.type,
            variantId: variant?.id,
            quantity: _quantity
                .clamp(1,
                    (variant?.stock ?? 1) < 1 ? 1 : (variant?.stock ?? 1))
                .toInt(),
            allSpecsSelected: !detail.hasSpec ||
                _selectedSpecValues.length == detail.specs.length,
            hasSpec: detail.hasSpec,
            product: Product(
              id: detail.id.toString(),
              name: detail.name,
              price: price,
              originalPrice: originalPrice,
              image: detail.images.isNotEmpty ? detail.images.first : '',
              category: detail.category,
              inStock: inStock,
            ),
          ),
      ],
    );
  }

  void _showCouponSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // 用主題色，夜間直播等深色主題才不會是白底導致文字對比不足。
      backgroundColor: context.appTheme.bgElev,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const _CouponSheet(),
    );
  }
}

// ── Image gallery ─────────────────────────────────────────────────────────────

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: appTheme.bgSubtle,
          child: Icon(Icons.image_outlined,
              size: 60, color: appTheme.fgMuted),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, _, _) => Container(
                  color: appTheme.bgSubtle,
                  child: Icon(Icons.image_outlined,
                      size: 60, color: appTheme.fgMuted),
                ),
              ),
            ),
          ),
          // Bottom-right "X / Y" page pill (matches prototype).
          if (images.length > 1)
            Positioned(
              bottom: 28,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${currentIndex + 1} / ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Floating glass header button ─────────────────────────────────────────
class _GlassHeaderButton extends StatelessWidget {
  const _GlassHeaderButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

// ── Stock badge ───────────────────────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final color = inStock ? appTheme.success : appTheme.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: Text(
        inStock ? '有庫存' : '缺貨',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Spec selector ─────────────────────────────────────────────────────────────

class _SpecSelector extends StatelessWidget {
  const _SpecSelector({
    required this.specs,
    required this.selected,
    required this.onSelect,
    required this.priceFor,
    required this.isEnabled,
  });

  final List<ProductSpec> specs;
  final Map<int, int> selected;
  final void Function(int specId, int valueId) onSelect;
  final double? Function(int specGroupId, int specValueId) priceFor;
  final bool Function(int specGroupId, int specValueId) isEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specs
          .map((spec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spec.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: spec.values
                          .map((value) {
                            final enabled = isEnabled(spec.id, value.id);
                            return _SpecChip(
                              label: value.name,
                              isSelected: selected[spec.id] == value.id,
                              enabled: enabled,
                              onTap: enabled ? () => onSelect(spec.id, value.id) : null,
                              price: priceFor(spec.id, value.id),
                            );
                          })
                          .toList(),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({
    required this.label,
    required this.isSelected,
    required this.enabled,
    this.onTap,
    this.price,
  });

  final String label;
  final bool isSelected;
  final bool enabled;
  final VoidCallback? onTap;
  final double? price;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    final Color borderColor;
    final Color bgColor;
    final Color textColor;

    if (!enabled) {
      borderColor = appTheme.divider;
      bgColor = appTheme.bgSubtle;
      textColor = appTheme.muted;
    } else if (isSelected) {
      borderColor = accent;
      bgColor = accent.withValues(alpha: 0.08);
      textColor = accent;
    } else {
      borderColor = appTheme.divider;
      bgColor = appTheme.bgElev;
      textColor = appTheme.fg;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          color: bgColor,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            decoration: enabled ? null : TextDecoration.lineThrough,
            decorationColor: appTheme.muted,
          ),
        ),
      ),
    );
  }
}

// ── Bottom add-to-cart bar ────────────────────────────────────────────────────

// ── Quantity row ──────────────────────────────────────────────────────────────

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({
    required this.quantity,
    required this.stock,
    required this.enabled,
    required this.onChanged,
  });

  final int quantity;
  final int stock;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    final labelStyle = textTheme.bodyLarge?.copyWith(
      color: appTheme.fg,
      fontWeight: FontWeight.w500,
    );
    final canDecrement = enabled && quantity > 1;
    final canIncrement = enabled && quantity < stock;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(l10n.productQuantity, style: labelStyle),
        ),
        SizedBox(width: appTheme.spacingXxl),
        _QuantityStepper(
          quantity: quantity,
          canDecrement: canDecrement,
          canIncrement: canIncrement,
          onDecrement: () => onChanged(quantity - 1),
          onIncrement: () => onChanged(quantity + 1),
        ),
        SizedBox(width: appTheme.spacingLg),
        Flexible(
          child: Text(
            l10n.productStockLeft(stock),
            style: labelStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  static const double _buttonWidth = 35;
  static const double _stepperHeight = 36;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    // 用較淡的分隔線色，避免數量選擇框的邊框/分隔線對比過高。
    final borderColor = appTheme.divider;
    final radius = BorderRadius.circular(appTheme.buttonRadius);

    return SizedBox(
      height: _stepperHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // 用較淡的底色，避免數量框變成高對比的黑框。
          color: appTheme.bgSubtle,
          border: Border.all(color: borderColor),
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepperButton(
                icon: Icons.remove,
                width: _buttonWidth,
                enabled: canDecrement,
                onTap: onDecrement,
              ),
              Container(width: 1, color: borderColor),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: appTheme.spacingMd,
                    ),
                    child: Text(
                      '$quantity',
                      style: textTheme.bodyMedium?.copyWith(
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 1, color: borderColor),
              _StepperButton(
                icon: Icons.add,
                width: _buttonWidth,
                enabled: canIncrement,
                onTap: onIncrement,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.width,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final double width;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final iconColor = enabled ? appTheme.fg : appTheme.muted;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Center(
          child: Icon(icon, size: 14, color: iconColor),
        ),
      ),
    );
  }
}

class _BottomBar extends ConsumerStatefulWidget {
  const _BottomBar({
    required this.inStock,
    required this.product,
    required this.marketId,
    required this.cardType,
    required this.allSpecsSelected,
    required this.hasSpec,
    this.variantId,
    this.quantity = 1,
  });

  final bool inStock;
  final Product product;
  final int marketId;
  /// `1 = 直播卡 (winLiveBid)`, `2 = 商城卡 (winMallBid)`. Drives which
  /// market endpoint the cart-add request hits.
  final int cardType;
  final int? variantId;
  final int quantity;
  final bool allSpecsSelected;
  final bool hasSpec;

  @override
  ConsumerState<_BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<_BottomBar> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final canAdd = widget.inStock && widget.allSpecsSelected && widget.variantId != null;
    final label = !widget.inStock
        ? '暫無庫存'
        : (widget.hasSpec && !widget.allSpecsSelected)
            ? '請選擇規格'
            : '加入購物車';

    final appTheme = context.appTheme;

    Future<void> doAddToCart() async {
      if (!canAdd || _loading) return;
      setState(() => _loading = true);
      try {
        await ref.read(cartApiProvider.notifier).addItem(
              variantId: widget.variantId!,
              marketId: widget.marketId,
              cardType: widget.cardType,
              quantity: widget.quantity,
            );
        // Event #4 (加入購物車) — server-cart path; log with full product.
        ref.read(analyticsServiceProvider).logAddToCartProduct(
              widget.product,
              quantity: widget.quantity,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已加入購物車'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('加入失敗：$e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        border: Border(top: BorderSide(color: appTheme.divider)),
      ),
      child: Row(
        children: [
          // Favorite icon column (visual only — favorites wiring elsewhere)
          _IconColumn(
            icon: Icons.favorite_border,
            label: '收藏',
            color: appTheme.fgMuted,
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _IconColumn(
            icon: Icons.shopping_cart_outlined,
            label: '購物車',
            color: appTheme.fgMuted,
            onTap: () => Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (ctx) => Scaffold(
                                backgroundColor: ctx.appTheme.bg,
                                body: const CartScreen(),
                              ),
                            ),
                          ),
          ),
          const SizedBox(width: 8),
          // Add to cart (accent color)
          Expanded(
            child: SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: canAdd && !_loading ? doAddToCart : null,
                style: FilledButton.styleFrom(
                  backgroundColor: appTheme.accent,
                  disabledBackgroundColor:
                      appTheme.muted.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(appTheme.cardRadius),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        )),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Buy now (primary color)
          Expanded(
            child: SizedBox(
              height: 46,
              child: FilledButton(
                onPressed: canAdd && !_loading ? doAddToCart : null,
                style: FilledButton.styleFrom(
                  backgroundColor: appTheme.brandPalette.tone500,
                  disabledBackgroundColor:
                      appTheme.muted.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(appTheme.cardRadius),
                  ),
                ),
                child: const Text(
                  '立即購買',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconColumn extends StatelessWidget {
  const _IconColumn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Coupon row ────────────────────────────────────────────────────────────────

class _CouponRow extends StatelessWidget {
  const _CouponRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Row(
      children: [
        Text(
          '賣場優惠券',
          style: TextStyle(fontSize: 14, color: appTheme.fgMuted),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                '查看可使用的優惠券',
                style: TextStyle(
                  fontSize: 13,
                  color: accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.open_in_new, size: 14, color: accent),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Coupon bottom sheet ───────────────────────────────────────────────────────

class _CouponSheet extends ConsumerWidget {
  const _CouponSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final couponsAsync = ref.watch(claimableCouponsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              appTheme.spacingXl,
              appTheme.spacingXl,
              appTheme.spacingSm,
              appTheme.spacingLg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.couponUsableTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: appTheme.fg,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                  color: colorScheme.onSurfaceVariant,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  constraints: const BoxConstraints(
                    minWidth: 35,
                    minHeight: 35,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: couponsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Text(
                  l10n.couponLoadFailed,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              data: (coupons) {
                if (coupons.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.couponEmptyUsable,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: controller,
                  padding: EdgeInsets.fromLTRB(
                    appTheme.spacingLg,
                    0,
                    appTheme.spacingLg,
                    appTheme.spacingLg + bottomPadding,
                  ),
                  itemCount: coupons.length,
                  itemBuilder: (_, i) => _CouponCard(coupon: coupons[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final ClaimableCoupon coupon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final palette = appTheme.brandPalette;

    final isActive = coupon.enable == 1;
    final leftBg =
        isActive ? palette.tone100 : colorScheme.surfaceContainerHighest;
    final discountFg =
        isActive ? palette.tone500 : colorScheme.onSurfaceVariant;
    final titleFg = isActive ? appTheme.fg : appTheme.fgMuted;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(appTheme.spacingXs),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 136,
                padding:
                    EdgeInsets.symmetric(horizontal: appTheme.spacingSm),
                decoration: BoxDecoration(
                  color: leftBg,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(6),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CouponDiscountIcon(size: 26, dimmed: !isActive),
                    SizedBox(width: appTheme.spacingXs),
                    Flexible(
                      child: Text(
                        coupon.discountLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: discountFg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 1,
                child: CustomPaint(
                  // 虛線比左側折扣色塊（tone100）再深一階，做出區隔。
                  painter: _DashedVerticalDividerPainter(
                    color: isActive
                        ? palette.tone200
                        : colorScheme.outlineVariant,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    appTheme.spacingLg,
                    appTheme.spacingSm,
                    0,
                    appTheme.spacingSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        coupon.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleFg,
                        ),
                      ),
                      if (coupon.description != null &&
                          coupon.description!.isNotEmpty) ...[
                        SizedBox(height: appTheme.spacingSm),
                        Text(
                          coupon.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: appTheme.fgMuted,
                          ),
                        ),
                      ],
                      if (coupon.scope != null &&
                          coupon.scope!.isNotEmpty) ...[
                        SizedBox(height: appTheme.spacingSm),
                        _CouponScopeTag(label: coupon.scope!),
                      ],
                      if (coupon.expiresAt != null) ...[
                        SizedBox(height: appTheme.spacingSm),
                        Text(
                          l10n.couponValidUntil(
                              _formatCouponExpiry(coupon.expiresAt!)),
                          style: textTheme.bodySmall?.copyWith(
                            color: appTheme.fgMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CouponScopeTag extends StatelessWidget {
  const _CouponScopeTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: appTheme.spacingSm,
        vertical: appTheme.spacingXxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(appTheme.chipRadius + 4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CouponDiscountIcon extends StatelessWidget {
  const _CouponDiscountIcon({required this.size, this.dimmed = false});
  final double size;
  final bool dimmed;

  static const _grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      'assets/icons/coupon.svg',
      width: size,
      height: size,
    );
    if (!dimmed) return svg;
    return Opacity(
      opacity: 0.6,
      child: ColorFiltered(colorFilter: _grayscale, child: svg),
    );
  }
}

class _DashedVerticalDividerPainter extends CustomPainter {
  const _DashedVerticalDividerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, (y + dashHeight).clamp(0, size.height)),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedVerticalDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}

String _formatCouponExpiry(String raw) {
  try {
    final dt = DateTime.parse(raw);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return raw;
  }
}

// ── Bundle products section ("組合商品內容") ──────────────────────────────────

class _BundleProductsSection extends StatelessWidget {
  const _BundleProductsSection({required this.items});

  final List<ProductBundleItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BundleSectionHeader(title: l10n.productBundleTitle),
        SizedBox(height: appTheme.spacingMd),
        LayoutBuilder(
          builder: (context, constraints) {
            const crossAxisCount = 2;
            final gap = appTheme.spacingSm;
            final cardWidth =
                (constraints.maxWidth - gap * (crossAxisCount - 1)) /
                    crossAxisCount;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: items
                  .map((item) => SizedBox(
                        width: cardWidth,
                        child: _BundleProductCard(item: item),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _BundleSectionHeader extends StatelessWidget {
  const _BundleSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: appTheme.brandPalette.tone500,
            borderRadius: BorderRadius.circular(appTheme.spacingXxs),
          ),
        ),
        SizedBox(width: appTheme.spacingSm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _BundleProductCard extends StatelessWidget {
  const _BundleProductCard({required this.item});

  final ProductBundleItem item;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(appTheme.spacingSm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 143 / 138,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(appTheme.buttonRadius),
              child: item.imageUrl.isEmpty
                  ? Container(
                      color: appTheme.divider.withValues(alpha: 0.4),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_outlined,
                        color: appTheme.muted,
                        size: 32,
                      ),
                    )
                  : Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: appTheme.divider.withValues(alpha: 0.4),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_outlined,
                          color: appTheme.muted,
                          size: 32,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: appTheme.spacingSm),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          SizedBox(height: appTheme.spacingSm),
          _BundleInfoRow(
            label: AppLocalizations.of(context)!.productSpec,
            value: item.specLabel.isEmpty ? '-' : item.specLabel,
          ),
          SizedBox(height: appTheme.spacingXs),
          _BundleInfoRow(
            label: AppLocalizations.of(context)!.productQuantity,
            value: item.quantity.toString(),
          ),
        ],
      ),
    );
  }
}

class _BundleInfoRow extends StatelessWidget {
  const _BundleInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: appTheme.muted),
          ),
        ),
        SizedBox(width: appTheme.spacingLg),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ── _SectionCard — bgElev panel separated from siblings by 8px of bg ────
//
// Mirrors the prototype's `<div style={{ background: T.bgElev,
// padding: 18, marginTop: 8 }}>` pattern: each major section sits on its
// own light card, with the page background showing through the gap.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      color: appTheme.bgElev,
      child: child,
    );
  }
}

// ── _TagPill — shared style for category + tag chips ────────────────────
//
// Matches the prototype's tone50-fill / accent-text inline pill. Used
// to render `detail.category` and `detail.tags` (e.g. 熱銷, 新品) right
// below the price block.
class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: appTheme.brandPalette.tone50,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// ── 商品詳情 attribute grid (類別 / 材質 / 產地 / 出貨) ────────────────
//
// Two-column "label : value" grid like the prototype's
// `display: grid; gridTemplateColumns: 'auto 1fr'`.
//
// Real category comes from `detail.category`; material/origin/shipping
// are placeholder copy until the backend exposes those fields.
// TODO(API): expose `material`, `origin`, `shippingDays` on
// /products/{id} so the grid stops showing canned text.
class _AttributeGrid extends StatelessWidget {
  const _AttributeGrid({required this.detail});

  final ProductCardDetail detail;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final rows = <(String, String)>[
      ('類別', detail.category.isNotEmpty ? detail.category : '—'),
      ('材質', '純棉 100%'),
      ('產地', '台灣'),
      ('出貨', '3 個工作日內'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 56,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color: appTheme.fgMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: appTheme.fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── 評價 reviews section ──────────────────────────────────────────────
//
// Mock data — two prototype-spec reviews. Wire to a Riverpod-backed
// AsyncNotifier once `/products/{id}/reviews` is available.
// TODO(API): GET /products/{id}/reviews
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.totalReviews});

  final int totalReviews;

  static const _mock = <({String name, int stars, String text})>[
    (name: 'Linda', stars: 5, text: '質料很好，孩子穿很舒服，會回購！'),
    (name: '小美', stars: 5, text: '尺寸符合，顏色很正，速度也快。'),
  ];

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '評價 ($totalReviews)',
              style: GoogleFonts.getFont(
                appTheme.fontDisplay,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: appTheme.fontWeightDisplay,
                  color: appTheme.fg,
                ),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '看全部 ›',
                  style: TextStyle(
                    fontSize: 12,
                    color: appTheme.fgMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _mock.length; i++) ...[
          _ReviewTile(
            name: _mock[i].name,
            stars: _mock[i].stars,
            text: _mock[i].text,
          ),
          if (i < _mock.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Container(height: 1, color: appTheme.divider),
            ),
        ],
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.name,
    required this.stars,
    required this.text,
  });

  final String name;
  final int stars;
  final String text;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTheme.chip,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1) : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: appTheme.chipFg,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appTheme.fg,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '★' * stars,
                style: const TextStyle(
                  color: Color(0xFFFFB800),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: appTheme.fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upsell 加價購 (B9) — horizontal-scroll add-on shelf. Hidden when the
// API returns no items so non-upsell-eligible products don't show an
// empty card.
class _UpsellSection extends ConsumerWidget {
  const _UpsellSection({required this.filter});

  final UpsellFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final upsellAsync = ref.watch(upsellProvider(filter));
    final items = upsellAsync.valueOrNull ?? const <UpsellItem>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BundleSectionHeader(title: '加價購'),
        SizedBox(height: appTheme.spacingMd),
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(width: appTheme.spacingSm),
            itemBuilder: (context, i) => SizedBox(
              width: 140,
              child: _UpsellCard(item: items[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpsellCard extends StatelessWidget {
  const _UpsellCard({required this.item});

  final UpsellItem item;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Container(
      padding: EdgeInsets.all(appTheme.spacingSm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(appTheme.buttonRadius),
              child: item.image.isEmpty
                  ? Container(
                      color: appTheme.divider.withValues(alpha: 0.4),
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined,
                          color: appTheme.muted, size: 28),
                    )
                  : Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Container(
                        color: appTheme.divider.withValues(alpha: 0.4),
                        alignment: Alignment.center,
                        child: Icon(Icons.image_outlined,
                            color: appTheme.muted, size: 28),
                      ),
                    ),
            ),
          ),
          SizedBox(height: appTheme.spacingXs),
          Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: appTheme.fg,
              height: 1.3,
            ),
          ),
          if (item.categoryName.isNotEmpty) ...[
            SizedBox(height: appTheme.spacingXxs),
            Text(
              item.categoryName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: accent),
            ),
          ],
        ],
      ),
    );
  }
}
