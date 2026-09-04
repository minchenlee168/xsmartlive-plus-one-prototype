import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/cart_api.dart';
import '../../providers/preview_cart.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';

/// Cart tab — corresponds to prototype `src/screens/cart.jsx`.
///
/// Items are visually grouped by host (live streamer). Each host group has
/// a header (host name + badge + optional coupon note) and a per-group
/// subtotal. Selection is local-only for now; checkout currently sends the
/// whole cart because the backend doesn't have per-item-select API yet:
///   `// TODO(API): per-item selection / partial checkout endpoint`
///
/// Multi-host grouping uses a deterministic mock derivation from `item.id`
/// because the cart API doesn't yet expose a host/streamer field:
///   `// TODO(API): cart items need a host/streamer field for grouping`
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

// Mock host roster — mirrors `cart.jsx` `hostMeta` keys. Replace with API
// host field when available.
class _HostMeta {
  const _HostMeta({
    required this.name,
    required this.badge,
    this.giftZone = false,
  });
  final String name;
  final String badge;
  final bool giftZone;
}

const _kHosts = <_HostMeta>[
  _HostMeta(name: 'Coco 闆娘', badge: '一般訂單'),
  _HostMeta(
    name: 'Kelly',
    badge: '運費合併計算中',
    giftZone: true,
  ),
  _HostMeta(name: 'Mia', badge: '一般訂單'),
  _HostMeta(name: 'Jane', badge: '一般訂單'),
];

_HostMeta _hostFor(int itemId) => _kHosts[itemId % _kHosts.length];

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<int> _selected = {};
  bool _initializedSelection = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    // 組出畫面無關的 view-model，樣式層（下方 widget）兩條路徑共用：
    // - web 預覽：純前端 previewCartProvider（分台 checkoutMode + 買多優惠，
    //   操作對齊參考專案 xsmartlive-frontend-prototype/src/pinia/cart.ts）
    // - 手機 / 正式：server 版 cartApiProvider（維持原本邏輯不變）
    final List<_GroupVM> vmGroups;
    final num selectedTotal;
    final int selectedCount;
    final bool allSelected;
    final int totalItemCount;
    bool isBusy = false;
    Object? errObj;
    final VoidCallback onToggleSelectAll;

    if (kIsWeb) {
      final cartGroups = ref.watch(previewCartProvider);
      final notifier = ref.read(previewCartProvider.notifier);
      vmGroups = [
        for (final g in cartGroups)
          _GroupVM(
            name: g.sellerName,
            // 可選購 / 棄標結帳不顯示 tag；整台一起結 → 禁止棄標；暫停結帳保留。
            badge: g.mode == PreviewCheckoutMode.pickable ||
                    g.mode == PreviewCheckoutMode.abandon
                ? null
                : g.mode == PreviewCheckoutMode.def
                    ? '禁止棄標'
                    : '暫停結帳',
            badgeNormal: false,
            tempTag: g.tempTag,
            note: g.note,
            subtotalNote: g.subtotalNote,
            giftZone: g.giftZone,
            subtotal: g.items
                .where((i) => i.checked)
                .fold<num>(0, (s, i) => s + i.lineTotal),
            // 整台一起結 / 可選購台才有「全選此店家」；暫停收單台沒有。
            showGroupCheckbox: g.mode != PreviewCheckoutMode.paused,
            groupAllChecked:
                g.items.isNotEmpty && g.items.every((i) => i.checked),
            onToggleGroupAll: () => notifier.toggleGroupAll(g.id),
            items: [
              for (final it in g.items)
                _ItemVM(
                  name: it.name,
                  cardTypeLabel: it.cardTypeLabel,
                  isAddon: it.isAddon,
                  specLabel: it.spec,
                  qty: it.qty,
                  unitPrice: it.effectiveUnitPrice,
                  imageUrl: it.imageUrl,
                  checked: it.checked,
                  note: it.note,
                  bundleItems: it.bundleItems,
                  bundleExpanded: it.bundleExpanded,
                  onToggleBundle: () => notifier.toggleBundle(g.id, it.id),
                  // 逐項勾選只在可選購台顯示；整台一起結 / 棄標結帳由 header 全選控制。
                  showCheckbox: g.mode == PreviewCheckoutMode.pickable,
                  // 整台一起結不可單獨刪項（整台一起）。
                  canDelete: g.mode != PreviewCheckoutMode.def,
                  specPending: it.specPending,
                  specOptions: it.specOptions,
                  specAllocation: it.specAllocation ?? const {},
                  onConfirmAlloc: (alloc) =>
                      notifier.setAllocation(g.id, it.id, alloc),
                  bulkOffer: (it.bulkMinQty != null &&
                          it.bulkUnitPrice != null)
                      ? (
                          minQty: it.bulkMinQty!,
                          unitDiscount: it.price - it.bulkUnitPrice!,
                        )
                      : null,
                  onToggle: () => notifier.toggle(g.id, it.id),
                  onIncrement: () => notifier.increment(g.id, it.id),
                  onDecrement: () => notifier.decrement(g.id, it.id),
                  onDelete: () => notifier.remove(g.id, it.id),
                ),
            ],
          ),
      ];
      final allItems = [for (final g in cartGroups) ...g.items];
      final checkedItems = allItems.where((i) => i.checked).toList();
      selectedCount = checkedItems.length;
      selectedTotal = checkedItems.fold<num>(0, (s, i) => s + i.lineTotal);
      totalItemCount = allItems.length;
      final pickable = [
        for (final g in cartGroups)
          if (g.mode == PreviewCheckoutMode.pickable) ...g.items,
      ];
      allSelected = pickable.isNotEmpty && pickable.every((i) => i.checked);
      onToggleSelectAll = () => notifier.setAllPickable(!allSelected);
    } else {
      final cartAsync = ref.watch(cartApiProvider);
      isBusy = cartAsync.isLoading;
      errObj = cartAsync.hasError ? cartAsync.error : null;
      final items = cartAsync.valueOrNull?.items ?? const <CartApiItem>[];
      final canDelete = cartAsync.valueOrNull?.canAbandon ?? true;
      if (!_initializedSelection && items.isNotEmpty) {
        _initializedSelection = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _selected
              ..clear()
              ..addAll(items.map<int>((i) => i.id));
          });
        });
      }
      // Group by mock host (until API exposes streamer field).
      final byHost = <String, List<CartApiItem>>{};
      final hostMeta = <String, _HostMeta>{};
      for (final item in items) {
        final meta = _hostFor(item.id);
        byHost.putIfAbsent(meta.name, () => <CartApiItem>[]).add(item);
        hostMeta[meta.name] = meta;
      }
      vmGroups = [
        for (final hostName in byHost.keys)
          _GroupVM(
            name: hostMeta[hostName]!.name,
            badge: hostMeta[hostName]!.badge,
            badgeNormal: hostMeta[hostName]!.badge == '一般訂單',
            tempTag: null,
            note: null,
            subtotalNote: null,
            giftZone: hostMeta[hostName]!.giftZone,
            subtotal: byHost[hostName]!
                .where((i) => _selected.contains(i.id))
                .fold<num>(0, (s, i) => s + i.unitPrice * i.quantity),
            showGroupCheckbox: true,
            groupAllChecked: byHost[hostName]!
                .every((i) => _selected.contains(i.id)),
            onToggleGroupAll: () {
              final hostItems = byHost[hostName]!;
              final all =
                  hostItems.every((i) => _selected.contains(i.id));
              setState(() {
                if (all) {
                  _selected.removeAll(hostItems.map((i) => i.id));
                } else {
                  _selected.addAll(hostItems.map((i) => i.id));
                }
              });
            },
            items: [
              for (final item in byHost[hostName]!)
                _ItemVM(
                  name: item.product.name ?? '商品 #${item.productId}',
                  cardTypeLabel: '（直播卡）',
                  specLabel: '規格 預設 / 標準',
                  qty: item.quantity,
                  unitPrice: item.unitPrice,
                  imageUrl: item.image,
                  checked: _selected.contains(item.id),
                  showCheckbox: true,
                  canDelete: canDelete,
                  onToggle: () => setState(() {
                    if (_selected.contains(item.id)) {
                      _selected.remove(item.id);
                    } else {
                      _selected.add(item.id);
                    }
                  }),
                  onIncrement: () =>
                      _serverUpdateQty(item, item.quantity + 1),
                  onDecrement: () {
                    if (item.quantity <= 1) return;
                    _serverUpdateQty(item, item.quantity - 1);
                  },
                  onDelete: () => _serverRemove(item),
                ),
            ],
          ),
      ];
      selectedTotal = items
          .where((i) => _selected.contains(i.id))
          .fold<num>(0, (s, i) => s + (i.unitPrice * i.quantity));
      selectedCount = items.where((i) => _selected.contains(i.id)).length;
      totalItemCount = items.length;
      allSelected = items.isNotEmpty && selectedCount == items.length;
      onToggleSelectAll = () => setState(() {
            if (allSelected) {
              _selected.clear();
            } else {
              _selected
                ..clear()
                ..addAll(items.map<int>((i) => i.id));
            }
          });
    }

    return Container(
      color: appTheme.bg,
      child: Column(
        children: [
          // Header — back arrow + centered "購物車" + count
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 12,
              left: 12,
              right: 20,
              bottom: 14,
            ),
            color: appTheme.bg,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  icon: Icon(Icons.chevron_left, color: appTheme.fg, size: 24),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                const Text(
                  '返回',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '購物車',
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: appTheme.fontWeightDisplay,
                      color: appTheme.fg,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '($totalItemCount)',
                  style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: isBusy
                ? const Center(child: CircularProgressIndicator())
                : errObj != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            '$errObj',
                            style: TextStyle(color: appTheme.fgMuted),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : vmGroups.every((g) => g.items.isEmpty)
                        ? _EmptyCart(label: l10n.cartEmpty)
                        : ListView(
                            padding:
                                const EdgeInsets.fromLTRB(12, 4, 12, 16),
                            children: [
                              for (final g in vmGroups)
                                _HostGroupCard(group: g),
                              const SizedBox(height: 8),
                              // 購物車頁最下方的「加購區」。
                              const _AddonSection(),
                              const SizedBox(height: 12),
                              // Livebuy 直播回放加購區。
                              const _LivebuyReplaySection(),
                            ],
                          ),
          ),
          // Sticky checkout bar
          if (!vmGroups.every((g) => g.items.isEmpty))
            Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: appTheme.bgElev,
                border: Border(top: BorderSide(color: appTheme.divider)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onToggleSelectAll,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        _SquareCheck(
                          selected: allSelected,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text('全選',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '已選 $selectedCount 件 · ${l10n.checkoutPriceTotal}',
                        style: TextStyle(
                          fontSize: 10,
                          color: appTheme.fgMuted,
                        ),
                      ),
                      Text(
                        '\$${_format(selectedTotal)}',
                        style: GoogleFonts.getFont(
                          appTheme.fontDisplay,
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: appTheme.brandPalette.tone500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: selectedCount == 0
                        ? null
                        : () => context.push('/checkout'),
                    style: FilledButton.styleFrom(
                      backgroundColor: appTheme.brandPalette.tone500,
                      disabledBackgroundColor:
                          appTheme.muted.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(appTheme.buttonRadius),
                      ),
                    ),
                    child: Text(
                      '去結帳 ($selectedCount)',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Server（手機 / 正式）購物車操作：加減數量 / 刪除 ──────────────────
  Future<void> _serverUpdateQty(CartApiItem item, int quantity) async {
    try {
      await ref
          .read(cartApiProvider.notifier)
          .updateItem(item.id, quantity: quantity);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失敗：$e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _serverRemove(CartApiItem item) async {
    setState(() => _selected.remove(item.id));
    try {
      await ref.read(cartApiProvider.notifier).removeItem(item.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('刪除失敗：$e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// View-model：讓群組 / 項目 widget 與資料來源（server / preview）解耦，
// 兩條路徑餵同一組視覺 widget，樣式完全不變。
// ─────────────────────────────────────────────────────────────────────────
class _GroupVM {
  const _GroupVM({
    required this.name,
    required this.badge,
    required this.badgeNormal,
    this.tempTag,
    this.note,
    this.subtotalNote,
    required this.giftZone,
    required this.subtotal,
    required this.showGroupCheckbox,
    required this.groupAllChecked,
    required this.onToggleGroupAll,
    required this.items,
  });
  final String name;

  /// 模式標籤（禁止棄標 / 暫停收單…）；null 表示不顯示（可選購台）。
  final String? badge;
  final bool badgeNormal;

  /// 溫層標籤（常溫 / 冷藏 / 冷凍）；null 表示不顯示。
  final String? tempTag;
  final String? note;
  final String? subtotalNote;
  final bool giftZone;
  final num subtotal;

  /// 整台「全選此店家」checkbox：整台一起結 / 可選購台才顯示。
  final bool showGroupCheckbox;
  final bool groupAllChecked;
  final VoidCallback onToggleGroupAll;
  final List<_ItemVM> items;
}

class _ItemVM {
  const _ItemVM({
    required this.name,
    this.cardTypeLabel,
    this.isAddon = false,
    required this.specLabel,
    required this.qty,
    required this.unitPrice,
    this.imageUrl,
    required this.checked,
    required this.showCheckbox,
    required this.canDelete,
    this.note,
    this.bundleItems,
    this.bundleExpanded = true,
    this.onToggleBundle,
    this.specPending = false,
    this.specOptions,
    this.specAllocation = const {},
    this.onConfirmAlloc,
    this.bulkOffer,
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });
  final String name;
  final String? cardTypeLabel;

  /// 是否為加購商品：為 true 時名稱前顯示「加購」標籤。
  final bool isAddon;
  final String specLabel;
  final int qty;
  final num unitPrice;
  final String? imageUrl;
  final bool checked;

  /// 商品備註（顯示於商品列下方的藍色提示）。
  final String? note;

  /// 組合商品子品清單（null 表示非組合商品）。
  final List<BundleSubItem>? bundleItems;
  final bool bundleExpanded;
  final VoidCallback? onToggleBundle;
  bool get isBundle => bundleItems != null;

  /// 待挑選規格（直播下標未選 SKU）：顯示琥珀提示 + 「挑選規格」按鈕。
  final bool specPending;
  final List<SpecOption>? specOptions;

  /// 已確定的規格分配（規格 → 數量）；購物車列顯示摘要用。
  final Map<String, int> specAllocation;

  /// 挑選規格彈窗按「確定」後套用分配。
  final void Function(Map<String, int> allocation)? onConfirmAlloc;

  /// 買多優惠：達 [minQty] 件後每件折 [unitDiscount] 元（null 代表無此優惠）。
  final ({int minQty, int unitDiscount})? bulkOffer;

  int get committedTotal => specAllocation.values.fold(0, (a, b) => a + b);

  /// 逐項勾選框是否顯示：可選購（pickable）台才有；整台一起結 / 暫停收單不顯示
  /// （整台由 header 的「全選此店家」控制）。
  final bool showCheckbox;
  final bool canDelete;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
}

// ─────────────────────────────────────────────────────────────────────────
// Per-host group card — mirrors cart.jsx `groupKeys.map(host => ...)` block.
// ─────────────────────────────────────────────────────────────────────────
class _HostGroupCard extends StatelessWidget {
  const _HostGroupCard({required this.group});

  final _GroupVM group;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final groupSubtotal = group.subtotal;
    final badge = group.badge;
    final badgeColor = badge == '禁止棄標'
        ? appTheme.danger
        : group.badgeNormal
            ? appTheme.brandPalette.tone500
            : appTheme.fgMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
        boxShadow: appTheme.elevation1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: Column(
          children: [
            // Group header
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: appTheme.divider)),
              ),
              child: Row(
                children: [
                  // 「全選此店家」— 整台一起結 / 可選購台才顯示
                  if (group.showGroupCheckbox) ...[
                    GestureDetector(
                      onTap: group.onToggleGroupAll,
                      behavior: HitTestBehavior.opaque,
                      child: _SquareCheck(
                          selected: group.groupAllChecked, size: 18),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(AppIcons.liveFilled, size: 16, color: appTheme.danger),
                  const SizedBox(width: 8),
                  Text(
                    group.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                  ),
                  // 溫層 tag 在前
                  if (group.tempTag != null) ...[
                    const SizedBox(width: 6),
                    _TempTag(label: group.tempTag!),
                  ],
                  // 模式 tag 在後（禁止棄標 / 暫停收單；可選購不顯示）
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                  if (group.note != null) ...[
                    const Spacer(),
                    Icon(AppIcons.coupon, size: 13, color: appTheme.fgMuted),
                    const SizedBox(width: 4),
                    Text(
                      group.note!,
                      style: TextStyle(
                          fontSize: 11, color: appTheme.fgMuted),
                    ),
                    if (group.subtotalNote != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        group.subtotalNote!,
                        style: TextStyle(
                          fontSize: 11,
                          color: appTheme.brandPalette.tone500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            // Items
            for (var idx = 0; idx < group.items.length; idx++) ...[
              _CartItemRow(
                vm: group.items[idx],
                showDivider: idx < group.items.length - 1,
              ),
              if (group.giftZone && idx == 0) const _GiftZone(),
              if (group.items[idx].isBundle)
                _BundleBox(items: group.items[idx].bundleItems!),
            ],
            // Group subtotal row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: appTheme.bgSubtle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '訂單金額小計',
                    style: TextStyle(
                      fontSize: 12,
                      color: appTheme.fgMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${_format(groupSubtotal)}',
                    style: GoogleFonts.getFont(
                      appTheme.fontDisplay,
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: appTheme.brandPalette.tone500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Single item row — mirrors cart.jsx item layout.
// ─────────────────────────────────────────────────────────────────────────
class _CartItemRow extends StatelessWidget {
  const _CartItemRow({
    required this.vm,
    required this.showDivider,
  });

  final _ItemVM vm;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final hasImg = vm.imageUrl != null && vm.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: showDivider
              ? BorderSide(color: appTheme.divider)
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Square checkbox — 只在可選購台顯示（整台一起結由 header 全選控制）
          if (vm.showCheckbox) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: vm.onToggle,
                behavior: HitTestBehavior.opaque,
                child: _SquareCheck(selected: vm.checked, size: 20),
              ),
            ),
            const SizedBox(width: 10),
          ],
          // Product image — 70×70 with subtle border
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
              image: hasImg
                  ? DecorationImage(
                      image: NetworkImage(vm.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImg
                ? null
                : Icon(Icons.image_outlined,
                    color: appTheme.fgMuted, size: 24),
          ),
          const SizedBox(width: 10),
          // Title + spec + qty stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      if (vm.isAddon)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _AddonTag(),
                          ),
                        ),
                      TextSpan(
                        text: vm.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: appTheme.fg,
                          height: 1.4,
                        ),
                      ),
                      if (vm.cardTypeLabel != null)
                        TextSpan(
                          text: ' ${vm.cardTypeLabel}',
                          style: TextStyle(
                            fontSize: 11,
                            color: appTheme.fgMuted,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // 一般規格文字（非下標、且尚未做規格分配時）
                if (!vm.specPending &&
                    vm.committedTotal == 0 &&
                    vm.specLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    vm.specLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: appTheme.fgMuted,
                    ),
                  ),
                ],
                // 已分配規格摘要（規格 ×數量）
                if (vm.committedTotal > 0) ...[
                  const SizedBox(height: 4),
                  for (final e in vm.specAllocation.entries)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        '${e.key} ×${e.value}',
                        style: TextStyle(fontSize: 11, color: appTheme.fg),
                      ),
                    ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('數量',
                        style: TextStyle(
                            fontSize: 10, color: appTheme.fgMuted)),
                    const SizedBox(width: 10),
                    _QtyStepper(
                      qty: vm.qty,
                      onMinus: vm.onDecrement,
                      onPlus: vm.onIncrement,
                    ),
                  ],
                ),
                // 買多優惠提示（達標前顯示還差幾件，達標後顯示已折抵）
                if (vm.bulkOffer != null) ...[
                  const SizedBox(height: 6),
                  _BulkOfferLine(offer: vm.bulkOffer!, qty: vm.qty),
                ],
                // 直播下標：待挑選提示 + 挑選 / 修改規格按鈕
                if (vm.specOptions != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (vm.specPending)
                        _SpecPendingBadge(
                            remaining: vm.qty - vm.committedTotal),
                      _ChooseSpecButton(
                        label:
                            vm.committedTotal == 0 ? '挑選規格' : '修改規格',
                        onTap: () => _showSpecAllocSheet(context, vm),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right column: price + delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'NTD \$${_format(vm.unitPrice)}',
                style: GoogleFonts.getFont(
                  appTheme.fontDisplay,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: appTheme.brandPalette.tone500,
                  ),
                ),
              ),
              if (vm.canDelete) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: vm.onDelete,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: appTheme.divider),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close,
                          size: 11, color: appTheme.fgMuted),
                      const SizedBox(width: 3),
                      Text(
                        '刪除',
                        style: TextStyle(
                          fontSize: 10,
                          color: appTheme.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ],
          ),
            ],
          ),
          // 商品備註（藍色提示）
          if (vm.note != null) ...[
            const SizedBox(height: 8),
            _ItemNoteBanner(note: vm.note!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Square checkbox — matches cart.jsx 4px-radius square (NOT a circle).
// ─────────────────────────────────────────────────────────────────────────
class _SquareCheck extends StatelessWidget {
  const _SquareCheck({required this.selected, this.size = 20});
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: selected
            ? appTheme.brandPalette.tone500
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: selected
              ? appTheme.brandPalette.tone500
              : appTheme.divider,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Icons.check,
              size: 12, color: Colors.white)
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 溫層標籤（常溫 / 冷藏 / 冷凍）— 沿用群組 badge 的藥丸樣式，冷色調區分。
// ─────────────────────────────────────────────────────────────────────────
class _TempTag extends StatelessWidget {
  const _TempTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final Color color;
    switch (label) {
      case '冷凍':
        color = const Color(0xFF1D4ED8);
        break;
      case '冷藏':
        color = const Color(0xFF2563EB);
        break;
      default: // 常溫
        color = appTheme.fgMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 買多優惠提示：達標前顯示「再買 N 件即享」，達標後顯示「已折抵 -NT$X」。
// ─────────────────────────────────────────────────────────────────────────
class _BulkOfferLine extends StatelessWidget {
  const _BulkOfferLine({required this.offer, required this.qty});

  final ({int minQty, int unitDiscount}) offer;
  final int qty;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final color = appTheme.success;
    final headline = offer.unitDiscount * offer.minQty;
    final qualified = qty >= offer.minQty;
    final text = qualified
        ? '買 ${offer.minQty} 件以上折扣 NT\$$headline'
            ' · 已折抵 -NT\$${offer.unitDiscount * qty}'
        : '買 ${offer.minQty} 件以上折扣 NT\$$headline'
            '，再買 ${offer.minQty - qty} 件即享';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.local_offer_outlined, size: 13, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 商品備註：藍色資訊條（保存須知 / 賣家提醒），沿用參考的 info banner 樣式。
// ─────────────────────────────────────────────────────────────────────────
class _ItemNoteBanner extends StatelessWidget {
  const _ItemNoteBanner({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: appTheme.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 13, color: appTheme.info),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '商品備註：',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: appTheme.fg),
                  ),
                  TextSpan(
                      text: note,
                      style: TextStyle(color: appTheme.fgMuted)),
                ],
                style: const TextStyle(fontSize: 11, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 組合商品內容：可展開 / 收合的子品清單，沿用主題 subtle 面板樣式。
// ─────────────────────────────────────────────────────────────────────────
class _BundleBox extends StatelessWidget {
  const _BundleBox({required this.items});
  final List<BundleSubItem> items;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— 組合商品 —',
            style: TextStyle(fontSize: 10, color: appTheme.fgMuted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _BundleThumb(sub: items[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleThumb extends StatelessWidget {
  const _BundleThumb({required this.sub});
  final BundleSubItem sub;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: appTheme.divider,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(Icons.inventory_2_outlined,
              size: 18, color: appTheme.fgMuted),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sub.spec != null ? '${sub.name}（${sub.spec}）' : sub.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: appTheme.fg,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '數量 ${sub.qty}',
                style: TextStyle(fontSize: 10, color: appTheme.fgMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 待挑選規格：琥珀提示藥丸（直播下標尚未選 SKU）。
// ─────────────────────────────────────────────────────────────────────────
class _SpecPendingBadge extends StatelessWidget {
  const _SpecPendingBadge({required this.remaining});
  final int remaining;

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 12, color: amber),
          const SizedBox(width: 4),
          Text(
            '待挑選規格（尚缺 $remaining）',
            style: const TextStyle(
              fontSize: 11,
              color: amber,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// 「挑選規格」外框小按鈕 — 沿用品牌色描邊，開啟規格挑選彈窗。
class _ChooseSpecButton extends StatelessWidget {
  const _ChooseSpecButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: appTheme.brandPalette.tone500),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 12, color: appTheme.brandPalette.tone500),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: appTheme.brandPalette.tone500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 規格分配彈窗：選規格 + 數量 → 加入 → 累積「已選 X / N」→ 確定寫回購物車。
void _showSpecAllocSheet(BuildContext context, _ItemVM vm) {
  final appTheme = context.appTheme;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: appTheme.bgElev,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _SpecAllocSheet(vm: vm),
  );
}

class _SpecAllocSheet extends StatefulWidget {
  const _SpecAllocSheet({required this.vm});
  final _ItemVM vm;

  @override
  State<_SpecAllocSheet> createState() => _SpecAllocSheetState();
}

class _SpecAllocSheetState extends State<_SpecAllocSheet> {
  late final Map<String, int> _draft;
  SpecOption? _pick;
  int _pickQty = 1;

  @override
  void initState() {
    super.initState();
    _draft = Map<String, int>.of(widget.vm.specAllocation);
    final opts = widget.vm.specOptions ?? const <SpecOption>[];
    _pick = opts.isNotEmpty ? opts.first : null;
  }

  int get _target => widget.vm.qty;
  int get _allocated => _draft.values.fold(0, (a, b) => a + b);
  int get _remaining => _target - _allocated;

  /// 目前選中規格「還能加入」的上限：只受剩餘庫存、限購限制
  /// （不受得標數限制 → 數量可加到庫存最大值，超過得標數再以紅字提示）。
  int get _addCap {
    final o = _pick;
    if (o == null) return 0;
    final already = _draft[o.name] ?? 0;
    final byStock = o.stock - already;
    final byLimit = o.limit == null ? (1 << 30) : (o.limit! - already);
    final v = byStock < byLimit ? byStock : byLimit;
    return v < 0 ? 0 : v;
  }

  /// 已選超過得標數量。
  bool get _over => _allocated > _target;

  String _optLabel(SpecOption o) =>
      o.stock <= 0 ? '${o.name}（售罄）' : '${o.name}（剩餘 ${o.stock}）';

  void _add() {
    final o = _pick;
    if (o == null) return;
    final add = _pickQty > _addCap ? _addCap : _pickQty;
    if (add <= 0) return;
    setState(() {
      _draft[o.name] = (_draft[o.name] ?? 0) + add;
      _pickQty = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final opts = widget.vm.specOptions ?? const <SpecOption>[];
    final addCap = _addCap;
    final canAdd = _pick != null && addCap >= 1;
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 標題 + 已選 X / N
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 2),
              child: Row(
                children: [
                  Text('挑選規格',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: appTheme.fg)),
                  const Spacer(),
                  Text('已選 $_allocated / $_target',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _over
                              ? appTheme.danger
                              : _remaining == 0
                                  ? appTheme.brandPalette.tone500
                                  : appTheme.fgMuted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(widget.vm.name,
                  style: TextStyle(fontSize: 12, color: appTheme.fgMuted)),
            ),
            Divider(height: 1, color: appTheme.divider),
            // 選規格 + 數量 + 加入
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: appTheme.divider),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SpecOption>(
                          isExpanded: true,
                          isDense: true,
                          value: _pick,
                          style: TextStyle(fontSize: 13, color: appTheme.fg),
                          items: [
                            for (final o in opts)
                              DropdownMenuItem(
                                  value: o, child: Text(_optLabel(o))),
                          ],
                          onChanged: (v) => setState(() {
                            _pick = v;
                            _pickQty = 1;
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _QtyStepper(
                    qty: _pickQty,
                    onMinus: () => setState(
                        () => _pickQty = _pickQty > 1 ? _pickQty - 1 : 1),
                    onPlus: () => setState(() {
                      if (_pickQty < addCap) _pickQty++;
                    }),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: canAdd ? _add : null,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: canAdd
                            ? appTheme.brandPalette.tone500
                            : appTheme.muted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('加入',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            // 剩餘庫存 / 限購提示（依選中規格）
            if (_pick != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  _pick!.stock <= 0
                      ? '此規格已售罄'
                      : '剩餘庫存 ${_pick!.stock}'
                          '${_pick!.limit != null ? '　限購 ${_pick!.limit} 件' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        _pick!.stock <= 0 ? appTheme.danger : appTheme.fgMuted,
                  ),
                ),
              ),
            // 已選規格清單
            if (_draft.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text('已選規格',
                    style: TextStyle(fontSize: 11, color: appTheme.fgMuted)),
              ),
              for (final e in _draft.entries)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${e.key} ×${e.value}',
                            style:
                                TextStyle(fontSize: 14, color: appTheme.fg)),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _draft.remove(e.key)),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(Icons.close,
                            size: 16, color: appTheme.fgMuted),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
            ],
            // 超過得標數量：紅字提示
            if (_over)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        size: 13, color: appTheme.danger),
                    const SizedBox(width: 4),
                    Text('選超過了，請移除 ${_allocated - _target} 件',
                        style: TextStyle(
                            fontSize: 12,
                            color: appTheme.danger,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            // 確定
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _over
                      ? null
                      : () {
                          widget.vm.onConfirmAlloc?.call(_draft);
                          Navigator.of(context).pop();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: appTheme.brandPalette.tone500,
                    disabledBackgroundColor:
                        appTheme.muted.withValues(alpha: 0.4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(appTheme.buttonRadius),
                    ),
                  ),
                  child: const Text('確定',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Quantity stepper — − [N] +  with 1px border.
// ─────────────────────────────────────────────────────────────────────────
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            label: '−',
            onTap: onMinus,
            color: appTheme.fg,
          ),
          SizedBox(
            width: 22,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              // 明確用主題前景色，夜間直播等深色主題數字才看得到。
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: appTheme.fg,
              ),
            ),
          ),
          _StepperButton(
            label: '+',
            onTap: onPlus,
            color: appTheme.fg,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.label,
    required this.onTap,
    required this.color,
  });
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 22,
        height: 22,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Mock gift sub-items zone (Kelly group only) — 滿件贈品區
// `// TODO(API): cart should include "free gift" items linked to a group`
// ─────────────────────────────────────────────────────────────────────────
class _GiftZone extends StatelessWidget {
  const _GiftZone();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 0, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— 滿件贈品區 —',
            style: TextStyle(fontSize: 10, color: appTheme.fgMuted),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appTheme.bgSubtle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                _GiftThumb(label: '滿額贈 小香包'),
                SizedBox(width: 10),
                _GiftThumb(label: '專屬保溫袋'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftThumb extends StatelessWidget {
  const _GiftThumb({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: appTheme.divider,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.card_giftcard,
                size: 20, color: appTheme.fgMuted),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: appTheme.fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '數量 1',
                  style: TextStyle(fontSize: 10, color: appTheme.fgMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛍️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: appTheme.fg,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '挑幾件喜歡的商品吧',
            style: TextStyle(color: appTheme.fgMuted, fontSize: 13),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => GoRouter.of(context).go('/shop'),
            style: FilledButton.styleFrom(
              backgroundColor: appTheme.brandPalette.tone500,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(appTheme.buttonRadius),
              ),
            ),
            child: const Text(
              '去逛逛',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Tiny number-formatter helper — adds thousands separators, no decimals.
// ─────────────────────────────────────────────────────────────────────────
String _format(num value) {
  final intPart = value.toInt().toString();
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return buf.toString();
}

// ─────────────────────────────────────────────────────────────────────────
// 加購區 —— 購物車頁最下方的加購商品區。
//   • 標題「加購區 / 共 N 件」+ 搜尋框 + 直播場次 / 購物車 篩選（prototype，
//     視覺為主，不做實際過濾）。
//   • 商品以 2 欄格狀排列；區塊高度固定，預設露出兩排，其餘以捲軸捲動。
// 內容為 prototype 範例資料；樣式沿用 Theme token。
// ─────────────────────────────────────────────────────────────────────────
/// 商品名稱前的「加購」標籤（加購區加入的商品專用）。
class _AddonTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '加購',
        style: TextStyle(
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }
}

class _AddonProduct {
  const _AddonProduct({
    required this.name,
    required this.price,
    required this.groupId,
    required this.groupName,
  });
  final String name;
  final int price;

  /// 此加購商品所屬的購物車台 id 與名稱（下標同一場直播的加購）。
  final String groupId;
  final String groupName;
}

/// 各台加購商品：每一台（直播場次）有自己的加購商品，主題貼合該場次。
/// 下拉選「全部購物車」呈現全部；選某台只顯示該台的加購商品。
const List<_AddonProduct> _kAddonProducts = [
  // 07/12 晚間直播搶購場（彩妝）
  _AddonProduct(name: '美妝蛋 3 入組', price: 99, groupId: 'g_bid', groupName: '07/12 晚間直播搶購場'),
  _AddonProduct(name: '拋棄式睫毛刷 20 支', price: 59, groupId: 'g_bid', groupName: '07/12 晚間直播搶購場'),
  _AddonProduct(name: '隨身唇釉分裝瓶', price: 49, groupId: 'g_bid', groupName: '07/12 晚間直播搶購場'),
  _AddonProduct(name: '防水彩妝收納袋', price: 129, groupId: 'g_bid', groupName: '07/12 晚間直播搶購場'),
  // Kelly 美妝快閃直播（美妝工具）
  _AddonProduct(name: '洗臉海綿 5 入', price: 79, groupId: 'g_kelly', groupName: 'Kelly 美妝快閃直播'),
  _AddonProduct(name: '化妝刷清潔皂', price: 99, groupId: 'g_kelly', groupName: 'Kelly 美妝快閃直播'),
  _AddonProduct(name: '隨身補光化妝鏡', price: 199, groupId: 'g_kelly', groupName: 'Kelly 美妝快閃直播'),
  _AddonProduct(name: '電動眉筆削筆器', price: 39, groupId: 'g_kelly', groupName: 'Kelly 美妝快閃直播'),
  // Mia 保養專場（保養）
  _AddonProduct(name: '保養品旅行分裝組', price: 149, groupId: 'g_mia', groupName: 'Mia 保養專場'),
  _AddonProduct(name: '蠶絲面膜紙 10 入', price: 89, groupId: 'g_mia', groupName: 'Mia 保養專場'),
  _AddonProduct(name: '純棉化妝棉 200 抽', price: 69, groupId: 'g_mia', groupName: 'Mia 保養專場'),
  _AddonProduct(name: '臉部導入凝膠', price: 259, groupId: 'g_mia', groupName: 'Mia 保養專場'),
  // Jane 香氛小舖（香氛）
  _AddonProduct(name: '擴香竹替換棒 10 入', price: 99, groupId: 'g_jane', groupName: 'Jane 香氛小舖'),
  _AddonProduct(name: '不鏽鋼燭芯剪', price: 199, groupId: 'g_jane', groupName: 'Jane 香氛小舖'),
  _AddonProduct(name: '精油空瓶 10ml 5 入', price: 59, groupId: 'g_jane', groupName: 'Jane 香氛小舖'),
  _AddonProduct(name: '車用擴香出風口夾', price: 149, groupId: 'g_jane', groupName: 'Jane 香氛小舖'),
];

/// 加購商品去重後的所屬台清單（依商品出現順序），供下拉選單使用。
List<({String id, String name})> _addonGroupsFromProducts() {
  final seen = <String>{};
  final out = <({String id, String name})>[];
  for (final p in _kAddonProducts) {
    if (seen.add(p.groupId)) out.add((id: p.groupId, name: p.groupName));
  }
  return out;
}

/// 加購區「購物車」下拉「全部購物車」的哨符值（顯示全部台的加購商品）。
const _kAddonAllCarts = '__all__';

/// 加購區「購物車」下拉目前的篩選：[_kAddonAllCarts]（預設，全部台的加購商品）
/// 或某台 id（只顯示該台的加購商品）。加入時商品一律回到它所屬的台。
final _addonTargetGroupProvider =
    StateProvider<String>((ref) => _kAddonAllCarts);

class _AddonSection extends ConsumerWidget {
  const _AddonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    final filter = ref.watch(_addonTargetGroupProvider);
    final isAll = filter == _kAddonAllCarts;
    final products = isAll
        ? _kAddonProducts
        : _kAddonProducts.where((p) => p.groupId == filter).toList();

    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題 + 搜尋 + 篩選
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '加購區',
                      style: GoogleFonts.getFont(
                        appTheme.fontDisplay,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: appTheme.fg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '共 ${products.length} 件',
                        style: TextStyle(
                            fontSize: 11, color: appTheme.fgMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _AddonSearchBox(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _AddonDropChip(label: '直播場次')),
                    const SizedBox(width: 8),
                    Expanded(child: _AddonCartDropdown()),
                  ],
                ),
              ],
            ),
          ),
          // 標題底下的品牌色分隔線
          Container(height: 2, color: accent),
          // 商品格狀區：固定高度，露出兩排，其餘捲動。
          SizedBox(
            height: 452,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols =
                    (constraints.maxWidth / 190).floor().clamp(2, 5);
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisExtent: 210,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) => _AddonCard(
                    product: products[i],
                    // 「全部購物車」時每張卡標示所屬台，方便辨識屬於哪一台。
                    showGroupLabel: isAll,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddonSearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appTheme.bgSubtle,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        border: Border.all(color: appTheme.divider),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: appTheme.fgMuted),
          const SizedBox(width: 8),
          Text(
            '搜尋商品名稱',
            style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
          ),
        ],
      ),
    );
  }
}

class _AddonDropChip extends StatelessWidget {
  const _AddonDropChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        border: Border.all(color: appTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: appTheme.fg),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down,
              size: 16, color: appTheme.fgMuted),
        ],
      ),
    );
  }
}

/// 加購區「購物車」下拉（篩選）：選「全部購物車」看所有台的加購商品，
/// 選某台只看該台的加購商品。純篩選，不影響加入時的所屬台。
class _AddonCartDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final selectedId = ref.watch(_addonTargetGroupProvider);
    final isAll = selectedId == _kAddonAllCarts;
    final addonGroups = _addonGroupsFromProducts();

    String? selectedName;
    for (final g in addonGroups) {
      if (g.id == selectedId) {
        selectedName = g.name;
        break;
      }
    }
    final label = isAll ? '全部購物車' : (selectedName ?? '全部購物車');

    return PopupMenuButton<String>(
      tooltip: '選擇購物車場次',
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints(minWidth: 220),
      color: appTheme.bgElev,
      surfaceTintColor: appTheme.bgElev,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        side: BorderSide(color: appTheme.divider),
      ),
      onSelected: (id) =>
          ref.read(_addonTargetGroupProvider.notifier).state = id,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: _kAddonAllCarts,
          child: Text(
            '全部購物車',
            style: TextStyle(
              fontSize: 13,
              color: appTheme.brandPalette.tone500,
              fontWeight: isAll ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
        for (final g in addonGroups)
          PopupMenuItem<String>(
            value: g.id,
            child: Text(
              g.name,
              style: TextStyle(
                fontSize: 13,
                color: appTheme.fg,
                fontWeight:
                    g.id == selectedId ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          border: Border.all(color: appTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: appTheme.fg),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 16, color: appTheme.fgMuted),
          ],
        ),
      ),
    );
  }
}

class _AddonCard extends ConsumerWidget {
  const _AddonCard({required this.product, this.showGroupLabel = false});
  final _AddonProduct product;

  /// 「全部購物車」時顯示所屬台名稱（讓使用者知道這是哪一台的加購商品）。
  final bool showGroupLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 所屬台標示（僅「全部購物車」時）
        if (showGroupLabel) ...[
          Row(
            children: [
              Icon(Icons.storefront_outlined,
                  size: 11, color: appTheme.fgMuted),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  product.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: appTheme.fgMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        // 商品圖（prototype 以佔位圖示呈現）
        Container(
          height: showGroupLabel ? 80 : 96,
          width: double.infinity,
          decoration: BoxDecoration(
            color: appTheme.bgSubtle,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(color: appTheme.divider),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.image_outlined,
              size: 26, color: appTheme.muted),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: appTheme.fg,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'NT\$${product.price}',
          style: GoogleFonts.getFont(
            appTheme.fontDisplay,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: Material(
            color: accent,
            borderRadius: BorderRadius.circular(appTheme.buttonRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(appTheme.buttonRadius),
              onTap: () {
                // 加購商品一律回到它所屬的台。
                ref.read(previewCartProvider.notifier).addAddon(
                      product.name,
                      product.price,
                      groupId: product.groupId,
                    );
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                          Text('已加入「${product.groupName}」：${product.name}'),
                    ),
                  );
              },
              child: const SizedBox(
                height: 32,
                child: Row(
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
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Livebuy 直播回放加購區：直式影片卡橫向捲動；點按影片圖跳轉直播回放介紹。
// ─────────────────────────────────────────────────────────────────────────
class _ReplayVideo {
  const _ReplayVideo({
    required this.title,
    this.pinned = false,
    this.overlayText,
    this.productName,
    this.productPrice,
  });
  final String title;
  final bool pinned;

  /// 影片縮圖上的文字（如「00:34:43 TEST LIVE」）；null 則不顯示。
  final String? overlayText;

  /// 影片底部的商品標籤（有商品才顯示）。
  final String? productName;
  final int? productPrice;
}

const List<_ReplayVideo> _kReplayVideos = [
  _ReplayVideo(
    title: '影片123',
    pinned: true,
    productName: '「師園」蒜味鹽酥雞餅乾',
    productPrice: 290,
  ),
  _ReplayVideo(title: 'sdfbsfb'),
  _ReplayVideo(title: '0731test', overlayText: '00:34:43\nTEST LIVE'),
  _ReplayVideo(
    title: '晚間直播回放',
    productName: '玫瑰保濕精華液 30ml',
    productPrice: 1280,
  ),
];

class _LivebuyReplaySection extends StatefulWidget {
  const _LivebuyReplaySection();

  @override
  State<_LivebuyReplaySection> createState() => _LivebuyReplaySectionState();
}

class _LivebuyReplaySectionState extends State<_LivebuyReplaySection> {
  final _scrollCtrl = ScrollController();
  static const _cardWidth = 150.0;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    final target = (_scrollCtrl.offset + delta).clamp(
      0.0,
      _scrollCtrl.position.maxScrollExtent,
    );
    _scrollCtrl.animateTo(target,
        duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    Widget arrow(IconData icon, VoidCallback onTap) => Material(
          color: appTheme.bgElev,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: appTheme.fg),
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Livebuy 直播回放加購區',
              style: GoogleFonts.getFont(
                appTheme.fontDisplay,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: appTheme.fg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '只要點選商品的圖片，就會跳轉到直播回放介紹',
              style: TextStyle(fontSize: 12, color: accent),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ListView.separated(
                  controller: _scrollCtrl,
                  scrollDirection: Axis.horizontal,
                  itemCount: _kReplayVideos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => SizedBox(
                    width: _cardWidth,
                    child: _ReplayVideoCard(video: _kReplayVideos[i]),
                  ),
                ),
                // 左右箭頭
                Positioned(
                  left: -4,
                  child: arrow(Icons.chevron_left,
                      () => _scrollBy(-(_cardWidth + 12) * 2)),
                ),
                Positioned(
                  right: -4,
                  child: arrow(Icons.chevron_right,
                      () => _scrollBy((_cardWidth + 12) * 2)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplayVideoCard extends StatelessWidget {
  const _ReplayVideoCard({required this.video});

  final _ReplayVideo video;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 直式影片縮圖（點按跳轉直播回放介紹）
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text('跳轉到直播回放介紹：${video.title}')));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 縮圖佔位（prototype）
                  Container(
                    color: const Color(0xFF1E1E24),
                    alignment: Alignment.center,
                    child: video.overlayText != null
                        ? Text(
                            video.overlayText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          )
                        : Icon(Icons.play_circle_outline,
                            size: 36,
                            color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  // 置頂 pin
                  if (video.pinned)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Icon(Icons.push_pin, size: 14, color: accent),
                      ),
                    ),
                  // 底部商品標籤
                  if (video.productName != null)
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(appTheme.radiusSm),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: appTheme.bgSubtle,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Icon(Icons.image_outlined,
                                  size: 16, color: appTheme.fgMuted),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    video.productName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 10, color: appTheme.fg),
                                  ),
                                  Text(
                                    'NT\$ ${video.productPrice}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: accent),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: appTheme.fg),
        ),
      ],
    );
  }
}
