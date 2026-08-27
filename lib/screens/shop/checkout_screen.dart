import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/address.dart' show CartDeliveryType;
import '../../models/cart_api.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';
import '../profile/address_form_sheet.dart';

/// Format `42370` → `42,370`. Used everywhere prices are rendered so the
/// thousands separators match the prototype's `toLocaleString()` output.
String _fmt(num v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

/// Checkout screen — corresponds to prototype `src/screens/checkout.jsx`.
///
/// Sections (top→bottom):
///   1. 優惠券 (coupon search + code input)
///   2. 訂購商品 (item list + subtotal footer)
///   3. 配送方式 (radio)
///   4. 付款方式 (radio)
///   5. Price summary breakdown
///   6. Bottom 總付款金額 + 去付款 sticky bar
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

// Invoice type — mock values matching prototype `<select>` options.
// TODO(API): map to real /invoice endpoint when backend exposes it.
enum _InvoiceType { member, phone, donate, vat }

extension on _InvoiceType {
  String get label => switch (this) {
        _InvoiceType.member => '會員載具（電子信箱）',
        _InvoiceType.phone => '手機條碼',
        _InvoiceType.donate => '發票捐贈',
        _InvoiceType.vat => '公司戶（三聯式）',
      };
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _couponCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(text: 'abc@gmail.com');
  final _bonusCtrl = TextEditingController();
  final _shopMoneyCtrl = TextEditingController();
  _InvoiceType _invoiceType = _InvoiceType.member;

  @override
  void dispose() {
    _couponCtrl.dispose();
    _emailCtrl.dispose();
    _bonusCtrl.dispose();
    _shopMoneyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartApiProvider);
    final checkout = ref.watch(checkoutProvider);
    final previewAsync = ref.watch(checkoutPreviewProvider);
    final appTheme = context.appTheme;
    final l10n = AppLocalizations.of(context)!;

    ref.listen<CheckoutState>(checkoutProvider, (_, next) {
      if (next.orderCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.checkoutOrderSuccess),
            backgroundColor: appTheme.success,
          ),
        );
        context.go('/shop');
        context.push('/orders');
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.checkoutOrderFailed(next.errorMessage!)),
            backgroundColor: appTheme.danger,
          ),
        );
        ref.read(checkoutProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        backgroundColor: appTheme.bgElev,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: appTheme.fg),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '結帳',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: appTheme.fg,
          ),
        ),
        centerTitle: true,
      ),
      body: Responsive.centeredBox(
        context,
        maxWidth: Responsive.formMaxWidth,
        child: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(cartApiProvider),
        ),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return Center(
              child: Text(
                l10n.checkoutCartEmpty,
                style: TextStyle(color: appTheme.fgMuted),
              ),
            );
          }
          // Optional checkout-time limit banner driven by
          // `storeCheckoutSettingProvider`. When the merchant has
          // configured `checkout_limit`, surface it as a one-line notice
          // at the top of the screen so the buyer knows there's a window.
          final settingAsync = ref.watch(storeCheckoutSettingProvider);
          final checkoutLimit =
              settingAsync.valueOrNull?.checkoutLimit;

          return Column(
            children: [
              if (checkoutLimit != null && checkoutLimit > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  color: appTheme.brandPalette.tone50,
                  child: Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 14, color: appTheme.brandPalette.tone500),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '請於 $checkoutLimit 分鐘內完成結帳',
                          style: TextStyle(
                            fontSize: 12,
                            color: appTheme.brandPalette.tone700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  children: [
                    _CouponSection(controller: _couponCtrl),
                    const SizedBox(height: 14),
                    _ItemsCard(items: cart.items),
                    const SizedBox(height: 14),
                    _SectionTitle(text: '配送方式'),
                    const SizedBox(height: 8),
                    _ShippingCard(
                      selectedDeliveryType: checkout.deliveryType,
                      selectedBrand: checkout.pickupBrand,
                      onChangeDeliveryType: (code) => ref
                          .read(checkoutProvider.notifier)
                          .changeDeliveryType(code),
                      onChangeBrand: (brand) => ref
                          .read(checkoutProvider.notifier)
                          .changePickupBrand(brand),
                    ),
                    const SizedBox(height: 14),
                    const _SectionTitle(text: '發票資訊'),
                    const SizedBox(height: 8),
                    _InvoiceCard(
                      type: _invoiceType,
                      emailCtrl: _emailCtrl,
                      onTypeChanged: (t) =>
                          setState(() => _invoiceType = t),
                    ),
                    const SizedBox(height: 14),
                    const _SectionTitle(text: '金額折抵'),
                    const SizedBox(height: 8),
                    _DeductionCard(
                      bonusCtrl: _bonusCtrl,
                      shopMoneyCtrl: _shopMoneyCtrl,
                    ),
                    const SizedBox(height: 14),
                    const _SectionTitle(text: '付款方式'),
                    const SizedBox(height: 8),
                    _PaymentCard(
                      selectedId: checkout.paymentMethodId,
                      onChanged: (id) => ref
                          .read(checkoutProvider.notifier)
                          .changePayment(id),
                    ),
                    const SizedBox(height: 14),
                    _PriceSummaryCard(
                        cart: cart, previewAsync: previewAsync),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _ConfirmBar(
                cart: cart,
                previewAsync: previewAsync,
                isSubmitting: checkout.isSubmitting,
                onConfirm: () =>
                    ref.read(checkoutProvider.notifier).confirmOrder(cart),
              ),
            ],
          );
        },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Reusable section title (above each section card).
// ─────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: appTheme.fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Reusable card shell — bgElev, rounded, divider border.
// ─────────────────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 優惠券 section — search button + code input row.
// `// TODO(API): wire to /coupons (search) + /coupons/redeem (apply code)`
// ─────────────────────────────────────────────────────────────────────────
class _CouponSection extends StatelessWidget {
  const _CouponSection({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(text: '優惠券'),
        const SizedBox(height: 8),
        _Card(
          child: Column(
            children: [
              // Search-coupons button
              Material(
                color: appTheme.bgSubtle,
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  onTap: () {
                    // TODO(API): open coupon picker (member coupons + claimable).
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                      border: Border.all(color: appTheme.divider),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 14, color: appTheme.fgMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '搜尋可使用優惠券',
                            style: TextStyle(
                                fontSize: 12, color: appTheme.fg),
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 16, color: appTheme.fgMuted),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Code input + 使用 button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: appTheme.bgSubtle,
                        borderRadius:
                            BorderRadius.circular(appTheme.radiusSm),
                        border: Border.all(color: appTheme.divider),
                      ),
                      child: TextField(
                        controller: controller,
                        style: TextStyle(
                            fontSize: 12, color: appTheme.fg),
                        decoration: InputDecoration(
                          hintText: '輸入優惠券或優惠代碼',
                          hintStyle: TextStyle(
                              fontSize: 12, color: appTheme.fgMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: accent,
                    borderRadius:
                        BorderRadius.circular(appTheme.radiusSm),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                      onTap: () {
                        // TODO(API): submit coupon code; show toast on result.
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 18, vertical: 11),
                        child: Text(
                          '使用',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Order items card — list with thumbnail / name / 數量 N / NTD $X,
// and a small subtotal footer ("訂單金額小計（X 個商品）$Y").
// ─────────────────────────────────────────────────────────────────────────
class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<CartApiItem> items;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final itemCount = items.fold<int>(0, (s, e) => s + e.quantity);
    final subtotal =
        items.fold<double>(0, (s, e) => s + e.unitPrice * e.quantity);

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ItemRow(item: items[i]),
            if (i < items.length - 1)
              Divider(height: 1, color: appTheme.divider),
          ],
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: appTheme.divider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '訂單金額小計（$itemCount 個商品）',
                  style: TextStyle(
                      fontSize: 12, color: appTheme.fgMuted),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${_fmt(subtotal)}',
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: accent,
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

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final CartApiItem item;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final l10n = AppLocalizations.of(context)!;
    final name = item.product.name ?? l10n.cartProductFallback;
    final lineTotal = item.unitPrice * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              item.image ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.image_outlined,
                color: appTheme.muted,
                size: 22,
              ),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + (直播卡) suffix + 數量 N
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: appTheme.fg,
                        ),
                      ),
                      TextSpan(
                        text: ' （直播卡）',
                        style: TextStyle(
                          fontSize: 10,
                          color: appTheme.fgMuted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '數量 ${item.quantity}',
                  style: TextStyle(
                      fontSize: 10, color: appTheme.fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Line total (right-aligned)
          Text(
            'NTD \$${_fmt(lineTotal)}',
            style: GoogleFonts.getFont(
              appTheme.fontDisplay,
              textStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 發票資訊 — invoice type dropdown + email input. Mirrors prototype's
// `<select>` (line 117-126) + email field.
// `// TODO(API): wire to invoice settings endpoint`
// ─────────────────────────────────────────────────────────────────────────
class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.type,
    required this.emailCtrl,
    required this.onTypeChanged,
  });

  final _InvoiceType type;
  final TextEditingController emailCtrl;
  final ValueChanged<_InvoiceType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('發票類型',
              style:
                  TextStyle(fontSize: 11, color: appTheme.fgMuted)),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius:
                  BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_InvoiceType>(
                value: type,
                isExpanded: true,
                isDense: true,
                style: TextStyle(fontSize: 12, color: appTheme.fg),
                dropdownColor: appTheme.bgElev,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: appTheme.fgMuted),
                items: _InvoiceType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onTypeChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('電子信箱',
              style:
                  TextStyle(fontSize: 11, color: appTheme.fgMuted)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            child: TextField(
              controller: emailCtrl,
              style: TextStyle(fontSize: 12, color: appTheme.fg),
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 金額折抵 — bonus + shop money inputs. Mirrors prototype lines 135-158.
// `// TODO(API): wire to /member/bonus + /member/shop-money balance`
// ─────────────────────────────────────────────────────────────────────────
class _DeductionCard extends StatelessWidget {
  const _DeductionCard({
    required this.bonusCtrl,
    required this.shopMoneyCtrl,
  });

  final TextEditingController bonusCtrl;
  final TextEditingController shopMoneyCtrl;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _Card(
      child: Column(
        children: [
          _DeductionRow(
            label: '紅利金',
            controller: bonusCtrl,
            balanceNote: '元 · 有紅利金 0 元可使用',
            appTheme: appTheme,
          ),
          const SizedBox(height: 12),
          _DeductionRow(
            label: '購物金',
            controller: shopMoneyCtrl,
            balanceNote: '元 · 有購物金 0 元可使用',
            appTheme: appTheme,
          ),
        ],
      ),
    );
  }
}

class _DeductionRow extends StatelessWidget {
  const _DeductionRow({
    required this.label,
    required this.controller,
    required this.balanceNote,
    required this.appTheme,
  });

  final String label;
  final TextEditingController controller;
  final String balanceNote;
  final AppThemeExtension appTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: appTheme.fg),
          ),
        ),
        const SizedBox(width: 10),
        Text('使用',
            style: TextStyle(fontSize: 11, color: appTheme.fgMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 12, color: appTheme.fg),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'NT\$',
                hintStyle:
                    TextStyle(fontSize: 12, color: appTheme.fgMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(balanceNote,
            style:
                TextStyle(fontSize: 10, color: appTheme.fgMuted)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shipping card — driven by GET /cart/checkout/shippingOptions (B10, 2026-05).
//
// Top section: pick a delivery type (home / pickup) — backend tells us
// which are `available` for this store.
// Bottom section (pickup only): pick a brand (7-11 / 全家 …) from the
// merchant-activated list.
//
// When the API returns nothing (or is loading), a static fallback row pair
// is rendered so dev devices and unauthenticated states stay clickable.
// ─────────────────────────────────────────────────────────────────────────
class _ShippingCard extends ConsumerWidget {
  const _ShippingCard({
    required this.selectedDeliveryType,
    required this.selectedBrand,
    required this.onChangeDeliveryType,
    required this.onChangeBrand,
  });

  final String selectedDeliveryType;
  final String? selectedBrand;
  final ValueChanged<String> onChangeDeliveryType;
  final ValueChanged<String?> onChangeBrand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(checkoutShippingOptionsProvider);

    // Once the API answers, default the brand to the first activated one
    // when the customer chose pickup but hasn't picked a brand yet.
    ref.listen<AsyncValue<List<CartDeliveryType>>>(
      checkoutShippingOptionsProvider,
      (prev, next) {
        next.whenData((types) {
          if (selectedDeliveryType != 'pickup' || selectedBrand != null) return;
          final pickup = types.firstWhere(
            (t) => t.code == 'pickup',
            orElse: () => const CartDeliveryType(
                code: '', label: '', available: false, brands: []),
          );
          if (pickup.brands.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onChangeBrand(pickup.brands.first);
            });
          }
        });
      },
    );

    final apiTypes = optionsAsync.valueOrNull ?? const <CartDeliveryType>[];
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;

    // Use API list when available; otherwise show a sensible static pair so
    // the picker is never empty.
    final List<CartDeliveryType> types = apiTypes.isNotEmpty
        ? apiTypes
        : <CartDeliveryType>[
            CartDeliveryType(
              code: 'home',
              label: l10n.checkoutShippingNormal,
              available: true,
              brands: const [],
            ),
            const CartDeliveryType(
              code: 'pickup',
              label: '超商取貨',
              available: true,
              brands: ['7-11', '全家'],
            ),
          ];

    final pickupType = types.firstWhere(
      (t) => t.code == 'pickup',
      orElse: () => const CartDeliveryType(
          code: '', label: '', available: false, brands: []),
    );

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final t in types) ...[
            Opacity(
              opacity: t.available ? 1 : 0.4,
              child: _RadioTile(
                value: t.code,
                groupValue: selectedDeliveryType,
                title: t.label,
                subtitle: t.code == 'home'
                    ? l10n.checkoutShippingNormalDesc
                    : (t.brands.isNotEmpty
                        ? t.brands.join(' / ')
                        : null),
                icon: _deliveryIconFor(t.code),
                onChanged: t.available ? onChangeDeliveryType : (_) {},
              ),
            ),
            // Brand chips appear directly under the pickup row when selected.
            if (t.code == 'pickup' &&
                selectedDeliveryType == 'pickup' &&
                pickupType.brands.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(54, 0, 14, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final brand in pickupType.brands)
                      _BrandChip(
                        label: brand,
                        selected: brand == selectedBrand,
                        onTap: () => onChangeBrand(brand),
                      ),
                  ],
                ),
              ),
          ],
          // 新增收件地址 — 跳出與地址簿相同的新增表單 bottom sheet。
          // 依目前選的配送類型開對應表單（宅配 / 超商取貨）。
          Divider(height: 1, color: appTheme.divider),
          InkWell(
            onTap: () => showAddressFormSheet(
              context,
              type: selectedDeliveryType == 'pickup'
                  ? AddressFormType.pickup
                  : AddressFormType.home,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.add_location_alt_outlined,
                      size: 20, color: appTheme.brandPalette.tone500),
                  const SizedBox(width: 8),
                  Text(
                    selectedDeliveryType == 'pickup' ? '新增超商取貨門市' : '新增宅配地址',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: appTheme.brandPalette.tone500,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right,
                      size: 18, color: appTheme.fgMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _deliveryIconFor(String code) => switch (code) {
      'home' => Icons.home_outlined,
      'pickup' => Icons.storefront_outlined,
      _ => Icons.local_shipping_outlined,
    };

class _BrandChip extends StatelessWidget {
  const _BrandChip({
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
      color: selected
          ? accent.withValues(alpha: 0.12)
          : appTheme.bgSubtle,
      borderRadius: BorderRadius.circular(appTheme.chipRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(appTheme.chipRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? accent : appTheme.fg,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Payment method card (radio list).
// ─────────────────────────────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.selectedId, required this.onChanged});

  final int selectedId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Single-line list per prototype `checkout.jsx` lines 164-168.
    // No subtitle — just label + icon.
    final methods = <({int id, String label, IconData icon})>[
      (id: 1, label: '信用卡', icon: Icons.credit_card_outlined),
      (id: 2, label: 'LINE Pay', icon: Icons.chat_bubble_outline),
      (id: 3, label: 'Apple Pay', icon: Icons.apple),
      (id: 4, label: '貨到付款', icon: Icons.account_balance_wallet_outlined),
    ];

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: methods
            .map((m) => _RadioTile(
                  value: m.id,
                  groupValue: selectedId,
                  title: m.label,
                  icon: m.icon,
                  onChanged: onChanged,
                ))
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Shared radio tile.
// ─────────────────────────────────────────────────────────────────────────
class _RadioTile<T> extends StatelessWidget {
  const _RadioTile({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.icon,
    required this.onChanged,
    this.subtitle,
  });

  final T value;
  final T groupValue;
  final String title;
  final String? subtitle;
  final IconData icon;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final selected = value == groupValue;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(appTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected ? accent : appTheme.fgMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? appTheme.fg : appTheme.fgMuted,
                    ),
                  ),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 11, color: appTheme.fgMuted)),
                  ],
                ],
              ),
            ),
            // Custom-painted radio dot to avoid the deprecated
            // `Radio.groupValue/onChanged` API.
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accent : Colors.transparent,
                border: Border.all(
                  color: selected ? accent : appTheme.divider,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Price summary card — breakdown rows (subtotal, shipping, discounts, total)
// ─────────────────────────────────────────────────────────────────────────
class _PriceSummaryCard extends StatelessWidget {
  const _PriceSummaryCard(
      {required this.cart, required this.previewAsync});

  final CartApi cart;
  final AsyncValue<Map<String, dynamic>?> previewAsync;

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: previewAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => _PriceRows(
          subtotal: cart.subtotal,
          discount: cart.discount,
          total: cart.total,
          shippingFee: null,
          shippingFeeReason: null,
        ),
        data: (preview) => _PriceRows(
          subtotal: _toDouble(preview?['subtotal']) ?? cart.subtotal,
          discount: _toDouble(preview?['discount']) ?? cart.discount,
          total: _toDouble(preview?['total']) ?? cart.total,
          shippingFee: _toDouble(preview?['shipping_fee']),
          shippingFeeReason: preview?['shipping_fee_reason'] as String?,
        ),
      ),
    );
  }
}

class _PriceRows extends StatelessWidget {
  const _PriceRows({
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.shippingFee,
    required this.shippingFeeReason,
  });

  final double subtotal;
  final double discount;
  final double total;
  final double? shippingFee;

  /// 2026-05 spec: backend explains why `shipping_fee` could not be
  /// computed yet. `null` = fee finalised. Known values:
  ///   • `NEEDS_ADDRESS_SELECTION`        — 尚未選擇地址
  ///   • `ADDRESS_NOT_FOUND_OR_UNAUTHORIZED` — 地址不存在或無權限
  ///   • `NO_AVAILABLE_RATE`              — 無對應費率
  final String? shippingFeeReason;

  /// Human-readable form of [shippingFeeReason]. Returns `null` when the
  /// fee has been finalised.
  String? get _shippingReasonLabel => switch (shippingFeeReason) {
        'NEEDS_ADDRESS_SELECTION' => '尚未選擇地址',
        'ADDRESS_NOT_FOUND_OR_UNAUTHORIZED' => '地址不存在或無權限',
        'NO_AVAILABLE_RATE' => '無可用運費方案',
        null => null,
        _ => shippingFeeReason,
      };

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    // Prototype-level breakdown rows. Multi-item & free-shipping discounts
    // are mock 0 placeholders until backend exposes the actual values.
    // TODO(API): expose multi-item-discount + free-shipping-threshold
    // values on the checkout preview response so these rows can display
    // real numbers instead of 0/—.
    const bulkDiscount = 0.0;
    final freeShippingDiscount =
        (shippingFee != null && shippingFee == 0) ? 80.0 : 0.0;
    final reason = _shippingReasonLabel;
    return Column(
      children: [
        _Row(
          label: '商品總金額',
          value: '\$${_fmt(subtotal)}',
        ),
        const SizedBox(height: 6),
        _Row(
          label: '運費總金額',
          value: shippingFee == null
              ? (reason ?? '—')
              : (shippingFee == 0
                  ? '免運'
                  : '\$${_fmt(shippingFee!)}'),
          valueColor: shippingFee == null && reason != null
              ? appTheme.fgMuted
              : (shippingFee != null && shippingFee == 0
                  ? appTheme.success
                  : null),
        ),
        const SizedBox(height: 6),
        _Row(
          label: '多件優惠折抵',
          value: '-\$${_fmt(bulkDiscount)}',
          labelColor: appTheme.danger,
          valueColor: appTheme.danger,
        ),
        const SizedBox(height: 6),
        _Row(
          label: '🛒 符合「滿千免運」 運費折抵',
          value: '-\$${_fmt(freeShippingDiscount)}',
          labelColor: appTheme.danger,
          valueColor: appTheme.danger,
        ),
        if (discount > 0) ...[
          const SizedBox(height: 6),
          _Row(
            label: '優惠券折抵',
            value: '-\$${_fmt(discount)}',
            labelColor: appTheme.danger,
            valueColor: appTheme.danger,
          ),
        ],
        const SizedBox(height: 10),
        Container(height: 1, color: appTheme.divider),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '總付款金額',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: appTheme.fg,
              ),
            ),
            Text(
              '\$${_fmt(total)}',
              style: GoogleFonts.getFont(
                appTheme.fontDisplay,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: labelColor ?? appTheme.fgMuted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: valueColor ?? appTheme.fg,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Bottom 總付款金額 + 去付款 sticky bar.
// ─────────────────────────────────────────────────────────────────────────
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.cart,
    required this.previewAsync,
    required this.isSubmitting,
    required this.onConfirm,
  });

  final CartApi cart;
  final AsyncValue<Map<String, dynamic>?> previewAsync;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  double get _total => previewAsync.maybeWhen(
        data: (p) {
          final v = p?['total'];
          if (v is num) return v.toDouble();
          if (v is String) return double.tryParse(v) ?? cart.total;
          return cart.total;
        },
        orElse: () => cart.total,
      );

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        border: Border(top: BorderSide(color: appTheme.divider)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '總付款金額',
                style: TextStyle(
                    fontSize: 10, color: appTheme.fgMuted),
              ),
              Text(
                '\$${_fmt(_total)}',
                style: GoogleFonts.getFont(
                  appTheme.fontDisplay,
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: Material(
                color: isSubmitting ? appTheme.muted : accent,
                borderRadius:
                    BorderRadius.circular(appTheme.cardRadius),
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(appTheme.cardRadius),
                  onTap: isSubmitting ? null : onConfirm,
                  child: Center(
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            '去付款',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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

// ─────────────────────────────────────────────────────────────────────────
// Error state.
// ─────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: appTheme.danger, size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: appTheme.fgMuted, fontSize: 13)),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onRetry,
                child: Text(l10n.checkoutRetry)),
          ],
        ),
      ),
    );
  }
}
