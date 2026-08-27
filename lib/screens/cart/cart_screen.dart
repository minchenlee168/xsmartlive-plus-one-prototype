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
            // 可選購不顯示 tag；整台一起結 → 禁止棄標；暫停收單保留。
            badge: g.mode == PreviewCheckoutMode.pickable
                ? null
                : g.mode == PreviewCheckoutMode.def
                    ? '禁止棄標'
                    : '暫停收單',
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
                  specLabel: it.spec,
                  qty: it.qty,
                  unitPrice: it.effectiveUnitPrice,
                  imageUrl: it.imageUrl,
                  checked: it.checked,
                  note: it.note,
                  bundleItems: it.bundleItems,
                  bundleExpanded: it.bundleExpanded,
                  onToggleBundle: () => notifier.toggleBundle(g.id, it.id),
                  // 逐項勾選只在可選購台顯示；整台一起結由 header 全選控制。
                  showCheckbox: g.mode == PreviewCheckoutMode.pickable,
                  // 整台一起結不可單獨刪項（整台一起）。
                  canDelete: g.mode != PreviewCheckoutMode.def,
                  specPending: it.specPending,
                  specOptions: it.specOptions,
                  specAllocation: it.specAllocation ?? const {},
                  onConfirmAlloc: (alloc) =>
                      notifier.setAllocation(g.id, it.id, alloc),
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
    required this.onToggle,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });
  final String name;
  final String? cardTypeLabel;
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
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
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
