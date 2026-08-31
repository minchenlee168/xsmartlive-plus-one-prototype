import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/preview_cart.dart';
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
  final _emailCtrl = TextEditingController(text: 'abc@gmail.com');
  _InvoiceType _invoiceType = _InvoiceType.member;

  /// 每張購物車各自選到的配送方式 code，key = 購物車分組 id
  /// （[previewCartProvider] 的 group id）；缺 key = 尚未選擇。
  /// prototype 以純前端狀態模擬「多台購物車分別選配送」的情境。
  final Map<String, String?> _cartDelivery = {};

  /// 每張購物車在彈窗展開後所選的地址 / 門市顯示文字（缺 key = 未選）。
  final Map<String, String?> _cartLocation = {};

  /// 每張購物車套用的優惠券（缺 key = 未使用）。
  final Map<String, _CheckoutCoupon> _cartCoupon = {};

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  /// 全部購物車小計加總（各台商品金額 − 該台優惠券折抵）。
  int _grandTotal(List<PreviewCartGroup> groups) => groups.fold(
        0,
        (s, g) => s + _groupSubtotal(g) - (_cartCoupon[g.id]?.discount ?? 0),
      );

  Future<void> _openCouponPicker(String groupId) async {
    final result = await showModalBottomSheet<_CouponResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CouponPickerSheet(selectedId: _cartCoupon[groupId]?.id),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.coupon == null) {
        _cartCoupon.remove(groupId);
      } else {
        _cartCoupon[groupId] = result.coupon!;
      }
    });
  }

  Future<void> _openApplyAllSheet(List<String> groupIds) async {
    final choice = await _showDeliveryMethodSheet(
      applyAll: true,
      currentCode: null,
      currentLocation: null,
    );
    if (choice == null || !mounted) return;
    setState(() {
      for (final id in groupIds) {
        _cartDelivery[id] = choice.code;
        _cartLocation[id] = choice.locationLabel;
      }
    });
  }

  Future<void> _openCartSheet(String groupId) async {
    final choice = await _showDeliveryMethodSheet(
      applyAll: false,
      currentCode: _cartDelivery[groupId],
      currentLocation: _cartLocation[groupId],
    );
    if (choice == null || !mounted) return;
    setState(() {
      _cartDelivery[groupId] = choice.code;
      _cartLocation[groupId] = choice.locationLabel;
    });
  }

  Future<_DeliveryChoice?> _showDeliveryMethodSheet({
    required bool applyAll,
    required String? currentCode,
    required String? currentLocation,
  }) {
    return showModalBottomSheet<_DeliveryChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DeliveryMethodSheet(
        applyAll: applyAll,
        selectedCode: currentCode,
        selectedLocation: currentLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartApiProvider);
    final checkout = ref.watch(checkoutProvider);
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
          // 有返回堆疊就 pop 回上一頁（通常是購物車）；若是深連結 / 重新整理
          // 直接落在 /checkout（無上一頁），context.pop() 會無事可退而卡住，
          // 因此 fallback 導回購物車。
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/cart'),
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
                child: Builder(builder: (context) {
                  final groups = ref.watch(previewCartProvider);
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    children: [
                      // 配送資訊 —— 移到最上方，標題比照「優惠券」放在區塊外面。
                      const _SectionTitle(text: '配送資訊'),
                      const SizedBox(height: 8),
                      _DeliveryInfoCard(
                        selected: _cartDelivery,
                        selectedLocation: _cartLocation,
                        onApplyAll: _openApplyAllSheet,
                        onSelectCart: _openCartSheet,
                      ),
                      const SizedBox(height: 14),
                      // 每張購物車一張「訂單明細」卡：商品列 + 收件人 / 運費 /
                      // 運費折抵 / 優惠券 / 紅利點數 / 小計。
                      for (final g in groups) ...[
                        _CartOrderCard(
                          group: g,
                          method: _cartDelivery[g.id],
                          location: _cartLocation[g.id],
                          coupon: _cartCoupon[g.id],
                          onChangeDelivery: () => _openCartSheet(g.id),
                          onSelectCoupon: () => _openCouponPicker(g.id),
                        ),
                        const SizedBox(height: 14),
                      ],
                      const _SectionTitle(text: '發票資訊'),
                      const SizedBox(height: 8),
                      _InvoiceCard(
                        type: _invoiceType,
                        emailCtrl: _emailCtrl,
                        onTypeChanged: (t) =>
                            setState(() => _invoiceType = t),
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
                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ),
              _ConfirmBar(
                total:
                    _grandTotal(ref.watch(previewCartProvider)).toDouble(),
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
// 配送資訊 — 多台購物車情境：每張購物車各自選擇配送方式。
//
// 版面（對照設計稿）：
//   • 卡片內建標題「配送資訊 ⓘ」
//   • 「配送方式  {摘要}」列，右側「套用全部 ›」→ 開啟套用全部彈窗
//   • 每張購物車一列：購物車名稱 + 已選 / 尚未選擇配送方式（可點選單獨設定）
//
// 多台購物車與名稱為 prototype 前端模擬（真實資料模型目前為單一購物車）。
// ─────────────────────────────────────────────────────────────────────────
class _DeliveryInfoCard extends ConsumerWidget {
  const _DeliveryInfoCard({
    required this.selected,
    required this.selectedLocation,
    required this.onApplyAll,
    required this.onSelectCart,
  });

  /// 各購物車已選配送方式，key = 購物車分組 id（缺 key = 尚未選擇）。
  final Map<String, String?> selected;

  /// 各購物車已選的地址 / 門市顯示文字，key = 購物車分組 id。
  final Map<String, String?> selectedLocation;

  /// 開啟「套用全部」彈窗，回呼帶入目前所有分組 id。
  final void Function(List<String> groupIds) onApplyAll;

  /// 開啟單張購物車的配送方式選擇彈窗。
  final void Function(String groupId) onSelectCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    // 沿用購物車頁的多台分組（每台一個 sellerName），讓結帳頁的
    // 配送資訊與購物車顯示同一批「購物車名稱」。
    final groups = ref.watch(previewCartProvider);
    final ids = groups.map((g) => g.id).toList(growable: false);

    // 上排摘要：全部分組選到相同方式才顯示該名稱，否則「各訂單各自選擇」。
    final codes = ids.map((id) => selected[id]).toSet();
    final summary = (codes.length == 1 && codes.first != null)
        ? (_deliveryMethodLabel(codes.first) ?? '各訂單各自選擇')
        : '各訂單各自選擇';

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 配送方式 摘要 + 套用全部（標題已移到卡片外，比照「優惠券」）
          InkWell(
            onTap: () => onApplyAll(ids),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Text(
                    '配送方式',
                    style: TextStyle(fontSize: 13, color: appTheme.fg),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      summary,
                      style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
                    ),
                  ),
                  Text(
                    '套用全部',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: accent),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: appTheme.divider),
          // 每張購物車一列（已選配送方式時，第二行顯示地址 / 門市）
          for (var i = 0; i < groups.length; i++) ...[
            InkWell(
              onTap: () => onSelectCart(groups[i].id),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groups[i].sellerName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: appTheme.fg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (selectedLocation[groups[i].id] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.place_outlined,
                                    size: 12, color: appTheme.fgMuted),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    selectedLocation[groups[i].id]!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: appTheme.fgMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _deliveryMethodLabel(selected[groups[i].id]) ??
                          '尚未選擇配送方式',
                      style: TextStyle(
                        fontSize: 12,
                        color: selected[groups[i].id] == null
                            ? appTheme.fgMuted
                            : appTheme.fg,
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: appTheme.fgMuted),
                  ],
                ),
              ),
            ),
            if (i < groups.length - 1)
              Divider(height: 1, color: appTheme.divider, indent: 14),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 單張購物車「訂單明細」卡：商品列（含組合內容）+ 該台的收件人 / 運費 /
// 運費折抵 / 優惠券 / 紅利點數 / 訂單金額小計。
// 資料取自 previewCartProvider 的分組；運費 / 收件人 / 折抵為 prototype 值。
// ─────────────────────────────────────────────────────────────────────────
class _CartOrderCard extends StatefulWidget {
  const _CartOrderCard({
    required this.group,
    required this.method,
    required this.location,
    required this.coupon,
    required this.onChangeDelivery,
    required this.onSelectCoupon,
  });

  final PreviewCartGroup group;
  final String? method;
  final String? location;
  final _CheckoutCoupon? coupon;
  final VoidCallback onChangeDelivery;
  final VoidCallback onSelectCoupon;

  @override
  State<_CartOrderCard> createState() => _CartOrderCardState();
}

class _CartOrderCardState extends State<_CartOrderCard> {
  final _bonusCtrl = TextEditingController(text: '0');

  @override
  void dispose() {
    _bonusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final g = widget.group;
    final subtotal = _groupSubtotal(g);
    final hasMethod = widget.method != null;
    final fee = _feeFor(widget.method);
    // 免運門檻：有選配送方式即視為達標，運費折抵抵銷運費，小計＝商品金額。
    final feeDiscount = hasMethod ? fee : 0;
    final couponDiscount = widget.coupon?.discount ?? 0;
    final total = subtotal + fee - feeDiscount - couponDiscount;

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題：「{購物車名稱} 訂單明細  [溫層]」
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${g.sellerName} 訂單明細',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (g.tempTag != null) ...[
                  const SizedBox(width: 8),
                  _TempBadge(label: g.tempTag!),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: appTheme.divider),
          // 商品列
          for (var i = 0; i < g.items.length; i++) ...[
            _CartItemRow(item: g.items[i]),
            if (i < g.items.length - 1)
              Divider(height: 1, color: appTheme.divider, indent: 14),
          ],
          Divider(height: 1, color: appTheme.divider),
          // 金額 / 配送 / 折抵 / 優惠券 / 紅利 摘要
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                _kv(
                  context,
                  label: '商品金額',
                  right: _rightValue(context, 'NT\$${_fmt(subtotal)}'),
                ),
                _kv(
                  context,
                  label: '運送方式/運費',
                  middle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasMethod
                            ? _shippingLine(g.tempTag, widget.method,
                                widget.location)
                            : '尚未選擇配送方式',
                        style: TextStyle(
                          fontSize: 12,
                          color: hasMethod ? appTheme.fg : appTheme.fgMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _OutlineButton(
                        label: '變更',
                        onTap: widget.onChangeDelivery,
                      ),
                    ],
                  ),
                  right: _rightValue(
                      context, hasMethod ? 'NT\$${_fmt(fee)}' : '—'),
                ),
                _kv(
                  context,
                  label: '收件人',
                  middle: Text(
                    hasMethod ? '王小明  +886 912****56' : '—',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasMethod ? appTheme.fg : appTheme.fgMuted,
                    ),
                  ),
                ),
                _kv(
                  context,
                  label: '運費折抵',
                  middle: hasMethod
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(appTheme.radiusSm),
                            ),
                            child: Text(
                              '達免運門檻',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  right: _rightValue(
                    context,
                    hasMethod ? '- NT\$${_fmt(feeDiscount)}' : '—',
                    color: hasMethod ? appTheme.danger : null,
                  ),
                ),
                _kv(
                  context,
                  label: '優惠券',
                  middle: Align(
                    alignment: Alignment.centerLeft,
                    child: widget.coupon == null
                        ? _OutlineButton(
                            label: '選擇優惠券',
                            onTap: widget.onSelectCoupon,
                          )
                        : InkWell(
                            onTap: widget.onSelectCoupon,
                            borderRadius:
                                BorderRadius.circular(appTheme.radiusSm),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_offer,
                                    size: 13, color: accent),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.coupon!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: accent,
                                    ),
                                  ),
                                ),
                                Icon(Icons.expand_more,
                                    size: 14, color: appTheme.fgMuted),
                              ],
                            ),
                          ),
                  ),
                  right: _rightValue(
                    context,
                    widget.coupon == null
                        ? '—'
                        : '- NT\$${_fmt(couponDiscount)}',
                    color: widget.coupon == null ? null : appTheme.danger,
                  ),
                ),
                _kv(
                  context,
                  label: '紅利點數',
                  middle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: Container(
                          decoration: BoxDecoration(
                            color: appTheme.bgSubtle,
                            borderRadius:
                                BorderRadius.circular(appTheme.radiusSm),
                            border: Border.all(color: appTheme.divider),
                          ),
                          child: TextField(
                            controller: _bonusCtrl,
                            style: TextStyle(fontSize: 12, color: appTheme.fg),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '尚有 500 點',
                        style:
                            TextStyle(fontSize: 11, color: appTheme.fgMuted),
                      ),
                    ],
                  ),
                  right: _rightValue(context, '—'),
                ),
                const SizedBox(height: 6),
                Divider(height: 1, color: appTheme.divider),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '訂單金額小計',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: appTheme.fg,
                      ),
                    ),
                    Text(
                      'NT\$${_fmt(total)}',
                      style: GoogleFonts.getFont(
                        appTheme.fontDisplay,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: accent,
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
    );
  }

  /// 摘要列：左固定寬標籤 + 中間內容 + 右對齊數值。
  Widget _kv(
    BuildContext context, {
    required String label,
    Widget? middle,
    Widget? right,
  }) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
            ),
          ),
          Expanded(child: middle ?? const SizedBox()),
          if (right != null)
            Padding(padding: const EdgeInsets.only(left: 8), child: right),
        ],
      ),
    );
  }

  Widget _rightValue(BuildContext context, String text, {Color? color}) {
    final appTheme = context.appTheme;
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: color ?? appTheme.fg),
    );
  }
}

/// 溫層徽章（常溫 / 冷藏 / 冷凍）。
class _TempBadge extends StatelessWidget {
  const _TempBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: appTheme.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: appTheme.info,
        ),
      ),
    );
  }
}

/// 小型外框按鈕（變更 / 選擇優惠券）。
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          border: Border.all(color: appTheme.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: appTheme.fg,
          ),
        ),
      ),
    );
  }
}

/// 購物車商品列（含組合商品內容、數量、金額）。
class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});
  final PreviewCartItem item;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(Icons.image_outlined,
                        color: appTheme.muted, size: 22),
                  )
                : Icon(Icons.image_outlined, color: appTheme.muted, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: appTheme.fg,
                      ),
                    ),
                    if (item.cardTypeLabel != null)
                      TextSpan(
                        text: ' ${item.cardTypeLabel}',
                        style: TextStyle(
                            fontSize: 10, color: appTheme.fgMuted),
                      ),
                  ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.spec.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.spec,
                    style: TextStyle(fontSize: 11, color: appTheme.fgMuted),
                  ),
                ],
                if (item.isBundle &&
                    item.bundleItems != null &&
                    item.bundleItems!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    '組合商品內容：${_bundleText(item.bundleItems!)}',
                    style: TextStyle(
                        fontSize: 11, height: 1.4, color: appTheme.fgMuted),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '數量 ${item.qty}',
                  style: TextStyle(fontSize: 11, color: appTheme.fgMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'NT\$${_fmt(item.lineTotal)}',
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

/// 每張購物車商品金額小計（各品項 lineTotal 加總）。
int _groupSubtotal(PreviewCartGroup g) =>
    g.items.fold(0, (s, it) => s + it.lineTotal);

/// 依配送方式對應的 prototype 起始運費。
int _feeFor(String? method) => switch (method) {
      'home' => 150,
      'post' => 100,
      'cvs' => 120,
      'self' => 0,
      _ => 0,
    };

/// 「運送方式/運費」中段顯示文字，例如「冷凍超商取貨 · 鑫工門市」。
String _shippingLine(String? tempTag, String? method, String? location) {
  final base = '${tempTag ?? ''}${_deliveryMethodLabel(method) ?? ''}';
  return location == null ? base : '$base · $location';
}

/// 組合商品內容文字：「A - 規格 ×1、B ×2」。
String _bundleText(List<BundleSubItem> items) => items
    .map((b) => b.spec != null ? '${b.name} - ${b.spec} ×${b.qty}'
        : '${b.name} ×${b.qty}')
    .join('、');

/// 彈窗回傳值：選到的配送方式 code + 展開後選到的地址 / 門市顯示文字。
class _DeliveryChoice {
  const _DeliveryChoice({required this.code, required this.locationLabel});
  final String code;
  final String? locationLabel;
}

// ─────────────────────────────────────────────────────────────────────────
// 選擇運送方式 bottom sheet。點選方式後，該方式下方就地「展開」對應的
// 收件地址（宅配 / 郵局宅配）或取貨門市（超商取貨）選擇區。
// applyAll=true 時標題帶「（套用全部）」並顯示「部分運送方式不共同支援」提示。
// 回傳 [_DeliveryChoice]（取消則回傳 null）。
// ─────────────────────────────────────────────────────────────────────────
class _DeliveryMethodSheet extends StatefulWidget {
  const _DeliveryMethodSheet({
    required this.applyAll,
    required this.selectedCode,
    required this.selectedLocation,
  });

  final bool applyAll;
  final String? selectedCode;
  final String? selectedLocation;

  @override
  State<_DeliveryMethodSheet> createState() => _DeliveryMethodSheetState();
}

class _DeliveryMethodSheetState extends State<_DeliveryMethodSheet> {
  String? _selected;
  int _homeIndex = 0; // 收件地址（宅配 / 郵局宅配）
  int _storeIndex = 0; // 取貨門市（超商取貨）

  static bool _needsHome(String? code) => code == 'home' || code == 'post';
  static bool _needsStore(String? code) => code == 'cvs';

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedCode;
    // 收件地址預設落在第一筆「可配送」地址。
    _homeIndex = _sampleHomeAddresses.indexWhere((a) => a.supported);
    if (_homeIndex < 0) _homeIndex = 0;
  }

  /// 依目前選到的方式，組出要回寫到購物車列的地址 / 門市文字。
  String? _locationLabel() {
    final code = _selected;
    if (_needsHome(code)) return _sampleHomeAddresses[_homeIndex].address;
    if (_needsStore(code)) {
      final s = _sampleStores[_storeIndex];
      return '${s.brand} ${s.name}';
    }
    if (code == 'self') return '到店自取';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(appTheme.sheetRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題列 + 關閉
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.applyAll ? '選擇運送方式（套用全部）' : '選擇運送方式',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 22, color: appTheme.fgMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 套用全部限定提示
            if (widget.applyAll)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: appTheme.bgSubtle,
                  borderRadius: BorderRadius.circular(appTheme.radiusSm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 15, color: appTheme.fgMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '部分運送方式因您勾選的購物車不共同支援，套用全部時已自動隱藏。',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: appTheme.fgMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            // 方式列表（選中者下方就地展開地址 / 門市選擇）
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0;
                        i < _deliveryMethodOptions.length;
                        i++) ...[
                      _DeliveryMethodRow(
                        option: _deliveryMethodOptions[i],
                        selected:
                            _deliveryMethodOptions[i].code == _selected,
                        onTap: () => setState(() =>
                            _selected = _deliveryMethodOptions[i].code),
                      ),
                      if (_deliveryMethodOptions[i].code == _selected)
                        _expansionFor(_deliveryMethodOptions[i].code),
                      if (i < _deliveryMethodOptions.length - 1)
                        Divider(height: 1, color: appTheme.divider, indent: 20),
                    ],
                  ],
                ),
              ),
            ),
            // 完成
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: Material(
                  color: _selected == null ? appTheme.muted : accent,
                  borderRadius: BorderRadius.circular(appTheme.cardRadius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(appTheme.cardRadius),
                    onTap: _selected == null
                        ? null
                        : () => Navigator.of(context).pop(
                              _DeliveryChoice(
                                code: _selected!,
                                locationLabel: _locationLabel(),
                              ),
                            ),
                    child: const Center(
                      child: Text(
                        '完成',
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
      ),
    );
  }

  Widget _expansionFor(String code) {
    if (_needsHome(code)) {
      return _HomeAddressExpansion(
        selectedIndex: _homeIndex,
        onSelect: (i) => setState(() => _homeIndex = i),
      );
    }
    if (_needsStore(code)) {
      return _StorePickupExpansion(
        selectedIndex: _storeIndex,
        onSelect: (i) => setState(() => _storeIndex = i),
      );
    }
    // 自取：無需地址。
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Text(
        '到店自取，無需填寫地址；請留意賣家通知的自取時間與地點。',
        style: TextStyle(fontSize: 12, height: 1.4, color: appTheme.fgMuted),
      ),
    );
  }
}

// ── 宅配 / 郵局宅配：收件地址列表（就地展開）───────────────────────────────
class _HomeAddressExpansion extends StatelessWidget {
  const _HomeAddressExpansion({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          for (var i = 0; i < _sampleHomeAddresses.length; i++) ...[
            _HomeAddressCard(
              addr: _sampleHomeAddresses[i],
              selected: i == selectedIndex,
              onTap: _sampleHomeAddresses[i].supported
                  ? () => onSelect(i)
                  : null,
            ),
            const SizedBox(height: 8),
          ],
          _AddNewRow(
            label: '新增宅配地址',
            onTap: () =>
                showAddressFormSheet(context, type: AddressFormType.home),
          ),
        ],
      ),
    );
  }
}

class _HomeAddressCard extends StatelessWidget {
  const _HomeAddressCard({
    required this.addr,
    required this.selected,
    required this.onTap,
  });

  final _AddrOption addr;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(
              color: selected ? accent : appTheme.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${addr.name}  ${addr.phone}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: appTheme.fg,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (addr.isDefault) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(appTheme.radiusSm),
                            ),
                            child: Text(
                              '預設',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.place_outlined,
                            size: 13, color: appTheme.fgMuted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            addr.address,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: appTheme.fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (addr.note != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        addr.note!,
                        style: TextStyle(fontSize: 11, color: appTheme.danger),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Icon(
                    addr.isDefault ? Icons.star : Icons.star_border,
                    size: 18,
                    color: addr.isDefault ? accent : appTheme.fgMuted,
                  ),
                  const SizedBox(height: 10),
                  Icon(Icons.delete_outline,
                      size: 18, color: appTheme.fgMuted),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 超商取貨：取貨門市選擇（就地展開）─────────────────────────────────────
class _StorePickupExpansion extends StatelessWidget {
  const _StorePickupExpansion({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final store = _sampleStores[selectedIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '選擇取貨門市（門市取自會員設定，運費依溫層）：',
            style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _sampleStores.length; i++)
                      _StoreChip(
                        store: _sampleStores[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelect(i),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.place_outlined,
                        size: 13, color: appTheme.fgMuted),
                    const SizedBox(width: 4),
                    Text(
                      '門市：${store.name}',
                      style: TextStyle(fontSize: 12, color: appTheme.fg),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13, color: appTheme.fgMuted),
                    const SizedBox(width: 4),
                    Text(
                      '收件人：王小明 +886 912****56',
                      style: TextStyle(fontSize: 12, color: appTheme.fg),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _AddNewRow(
            label: '新增超商門市',
            onTap: () =>
                showAddressFormSheet(context, type: AddressFormType.pickup),
          ),
        ],
      ),
    );
  }
}

class _StoreChip extends StatelessWidget {
  const _StoreChip({
    required this.store,
    required this.selected,
    required this.onTap,
  });

  final _StoreOption store;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.chipRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(appTheme.chipRadius),
          border: Border.all(
            color: selected ? accent : appTheme.divider,
            width: selected ? 1.5 : 1,
          ),
          color: selected ? accent.withValues(alpha: 0.06) : appTheme.bgElev,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: appTheme.bgSubtle,
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
              ),
              child: Text(
                store.brand,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: appTheme.fgMuted,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              store.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? accent : appTheme.fg,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              store.price,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? accent : appTheme.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 共用：虛線框「＋ 新增…」列 ─────────────────────────────────────────────
class _AddNewRow extends StatelessWidget {
  const _AddNewRow({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: appTheme.divider,
          radius: appTheme.radiusSm,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 虛線圓角矩形外框（用於「＋ 新增…」列）。
class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _DeliveryMethodRow extends StatelessWidget {
  const _DeliveryMethodRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _DeliveryMethodOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? accent.withValues(alpha: 0.06) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? accent : appTheme.fg,
                ),
              ),
            ),
            Text(
              option.priceLabel,
              style: TextStyle(
                fontSize: 14,
                color: selected ? accent : appTheme.fgMuted,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 18, color: accent),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 配送資訊 prototype 資料 —— 可選運送方式（含起始價）。
// 購物車名稱沿用 `previewCartProvider` 的多台分組，不在此另立。
// ─────────────────────────────────────────────────────────────────────────
class _DeliveryMethodOption {
  const _DeliveryMethodOption({
    required this.code,
    required this.label,
    required this.priceLabel,
  });
  final String code;
  final String label;
  final String priceLabel;
}

const List<_DeliveryMethodOption> _deliveryMethodOptions = [
  _DeliveryMethodOption(code: 'home', label: '宅配', priceLabel: '\$150 起'),
  _DeliveryMethodOption(code: 'self', label: '自取', priceLabel: '\$0'),
  _DeliveryMethodOption(code: 'cvs', label: '超商取貨', priceLabel: '\$110 起'),
  _DeliveryMethodOption(code: 'post', label: '郵局宅配', priceLabel: '\$100 起'),
];

String? _deliveryMethodLabel(String? code) {
  if (code == null) return null;
  for (final m in _deliveryMethodOptions) {
    if (m.code == code) return m.label;
  }
  return null;
}

// ── 收件地址 / 取貨門市 prototype 範例資料（彈窗展開後可選）─────────────────
// 真機登入後應改讀 address_provider 的會員地址 / 門市；web 預覽無授權，
// 以下範例讓展開選單有內容可預覽。
class _AddrOption {
  const _AddrOption({
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
    this.supported = true,
    this.note,
  });
  final String name;
  final String phone;
  final String address;
  final bool isDefault;
  final bool supported;
  final String? note;
}

class _StoreOption {
  const _StoreOption({
    required this.brand,
    required this.name,
    required this.price,
  });
  final String brand;
  final String name;
  final String price;
}

const List<_AddrOption> _sampleHomeAddresses = [
  _AddrOption(
    name: '王小明',
    phone: '+886 912****56',
    address: '台北市信義區忠孝東路五段 100 號 10 樓',
    isDefault: true,
  ),
  _AddrOption(
    name: '王小明',
    phone: '+886 912****56',
    address: '高雄市前鎮區中山路一段 50 號 8 樓',
    supported: false,
    note: '目前不提供配送至此地區',
  ),
];

const List<_StoreOption> _sampleStores = [
  _StoreOption(brand: '7-11', name: '鑫工門市', price: 'NT\$120'),
  _StoreOption(brand: '7-11', name: '連興門市', price: 'NT\$120'),
  _StoreOption(brand: '全家', name: '平鎮上海店', price: 'NT\$110'),
];

// ── 結帳頁「選擇優惠券」prototype 資料 + 彈窗 ─────────────────────────────
class _CheckoutCoupon {
  const _CheckoutCoupon({
    required this.id,
    required this.name,
    required this.discount,
    required this.note,
  });
  final int id;
  final String name;

  /// 折抵金額（NT$）。
  final int discount;
  final String note;
}

const List<_CheckoutCoupon> _checkoutCoupons = [
  _CheckoutCoupon(
      id: 1, name: '滿 \$1000 折 \$100', discount: 100, note: '單一購物車滿 \$1000 可用'),
  _CheckoutCoupon(id: 2, name: '生鮮直播折 \$50', discount: 50, note: '生鮮 / 冷凍類專用'),
  _CheckoutCoupon(id: 3, name: '全站現折 \$80', discount: 80, note: '不限金額'),
  _CheckoutCoupon(id: 4, name: '指定商品折 \$150', discount: 150, note: '指定商品限定'),
];

/// 彈窗回傳值：`coupon == null` 代表「不使用優惠券」，dismiss 則回傳 null。
class _CouponResult {
  const _CouponResult(this.coupon);
  final _CheckoutCoupon? coupon;
}

class _CouponPickerSheet extends StatefulWidget {
  const _CouponPickerSheet({required this.selectedId});
  final int? selectedId;

  @override
  State<_CouponPickerSheet> createState() => _CouponPickerSheetState();
}

class _CouponPickerSheetState extends State<_CouponPickerSheet> {
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(appTheme.sheetRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '選擇優惠券',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 22, color: appTheme.fgMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CouponPickRow(
                      title: '不使用優惠券',
                      note: null,
                      trailing: '',
                      selected: _selectedId == null,
                      onTap: () => setState(() => _selectedId = null),
                    ),
                    Divider(height: 1, color: appTheme.divider, indent: 20),
                    for (var i = 0; i < _checkoutCoupons.length; i++) ...[
                      _CouponPickRow(
                        title: _checkoutCoupons[i].name,
                        note: _checkoutCoupons[i].note,
                        trailing: '- NT\$${_fmt(_checkoutCoupons[i].discount)}',
                        selected: _selectedId == _checkoutCoupons[i].id,
                        onTap: () => setState(
                            () => _selectedId = _checkoutCoupons[i].id),
                      ),
                      if (i < _checkoutCoupons.length - 1)
                        Divider(height: 1, color: appTheme.divider, indent: 20),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: Material(
                  color: accent,
                  borderRadius: BorderRadius.circular(appTheme.cardRadius),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(appTheme.cardRadius),
                    onTap: () {
                      final coupon = _selectedId == null
                          ? null
                          : _checkoutCoupons
                              .firstWhere((c) => c.id == _selectedId);
                      Navigator.of(context).pop(_CouponResult(coupon));
                    },
                    child: const Center(
                      child: Text(
                        '完成',
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
      ),
    );
  }
}

class _CouponPickRow extends StatelessWidget {
  const _CouponPickRow({
    required this.title,
    required this.note,
    required this.trailing,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? note;
  final String trailing;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? accent.withValues(alpha: 0.06) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? accent : appTheme.fg,
                    ),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      note!,
                      style: TextStyle(fontSize: 11, color: appTheme.fgMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing.isNotEmpty)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: appTheme.danger,
                ),
              ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 18, color: accent),
            ],
          ],
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
// Bottom 總付款金額 + 去付款 sticky bar.
// ─────────────────────────────────────────────────────────────────────────
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.total,
    required this.isSubmitting,
    required this.onConfirm,
  });

  /// 全部購物車小計加總（各台 [_groupSubtotal] 之和）。
  final double total;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  double get _total => total;

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
