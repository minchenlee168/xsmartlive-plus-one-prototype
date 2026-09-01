import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 純前端（web 預覽用）購物車，操作邏輯對齊參考專案
/// `xsmartlive-frontend-prototype`（src/pinia/cart.ts）：
/// - 依直播台分組，每台有 [PreviewCheckoutMode]
/// - 逐項勾選、加減數量、刪除全在前端 in-memory 完成（不打 server）
/// - 買多優惠：達 [PreviewCartItem.bulkMinQty] 件後每件單價變 bulkUnitPrice
///
/// 手機 / 正式版仍走 server 版 `cartApiProvider`，不受此檔影響。

/// 每台購物車的結帳模式（對齊參考 CheckoutMode 的核心三態）：
/// - [pickable]：可逐項勾選 / 改量 / 刪除，允許分批結帳
/// - [def]（default）：整台一起結，全部強制勾選、不可勾選 / 改量
/// - [paused]：暫停收單，僅供瀏覽，不可勾選 / 改量 / 結帳
/// - [abandon]：棄標結帳，整台一起結但每項皆可刪除（棄標），不顯示 tag
enum PreviewCheckoutMode { pickable, def, paused, abandon }

/// 組合商品的子品項。
class BundleSubItem {
  const BundleSubItem(this.name, {this.spec, required this.qty});
  final String name;
  final String? spec;
  final int qty;
}

/// 直播下標可選規格：含剩餘庫存與限購數量。
class SpecOption {
  const SpecOption(this.name, {required this.stock, this.limit});

  final String name;

  /// 剩餘庫存。
  final int stock;

  /// 每個規格的限購數量；null 表示不限購。
  final int? limit;
}

class PreviewCartItem {
  const PreviewCartItem({
    required this.id,
    required this.name,
    this.cardTypeLabel,
    required this.spec,
    required this.qty,
    required this.price,
    this.original,
    required this.checked,
    this.bulkMinQty,
    this.bulkUnitPrice,
    this.bulkNote,
    this.imageUrl,
    this.note,
    this.isBundle = false,
    this.bundleExpanded = true,
    this.bundleItems,
    this.specPending = false,
    this.specOptions,
    this.specAllocation,
    this.isAddon = false,
  });

  final String id;
  final String name;

  /// 是否為「加購區」加入的商品；為 true 時商品名稱前顯示「加購」標籤。
  final bool isAddon;

  /// 名稱後的來源標記，例如「（直播卡）」；null 則不顯示。
  final String? cardTypeLabel;
  final String spec;
  final int qty;
  final int price;
  final int? original;
  final bool checked;

  /// 買多優惠：達 [bulkMinQty] 件後，每件單價變為 [bulkUnitPrice]。
  final int? bulkMinQty;
  final int? bulkUnitPrice;
  final String? bulkNote;
  final String? imageUrl;

  /// 商品備註（顯示於商品列下方，如保存須知、賣家提醒）。
  final String? note;

  /// 組合商品：含子品清單，可展開 / 收合顯示組合內容。
  final bool isBundle;
  final bool bundleExpanded;
  final List<BundleSubItem>? bundleItems;

  /// 直播下標後尚未選規格：購物車需補選 SKU 才能結帳。
  final bool specPending;

  /// 待挑選規格時可選的規格清單（含庫存 / 限購，挑選規格彈窗用）。
  final List<SpecOption>? specOptions;

  /// 批次下標規格分配：規格 → 分配數量；總和需等於 qty 才算選完。
  final Map<String, int>? specAllocation;

  /// 目前已分配的總數。
  int get committedTotal =>
      (specAllocation ?? const {}).values.fold(0, (a, b) => a + b);

  /// 套用買多優惠後的實際單價。
  int get effectiveUnitPrice =>
      (bulkMinQty != null && bulkUnitPrice != null && qty >= bulkMinQty!)
          ? bulkUnitPrice!
          : price;

  int get lineTotal => effectiveUnitPrice * qty;

  PreviewCartItem copyWith({
    int? qty,
    bool? checked,
    String? spec,
    bool? specPending,
    Map<String, int>? specAllocation,
    bool? bundleExpanded,
  }) =>
      PreviewCartItem(
        id: id,
        name: name,
        cardTypeLabel: cardTypeLabel,
        spec: spec ?? this.spec,
        qty: qty ?? this.qty,
        price: price,
        original: original,
        checked: checked ?? this.checked,
        bulkMinQty: bulkMinQty,
        bulkUnitPrice: bulkUnitPrice,
        bulkNote: bulkNote,
        imageUrl: imageUrl,
        note: note,
        isBundle: isBundle,
        bundleExpanded: bundleExpanded ?? this.bundleExpanded,
        bundleItems: bundleItems,
        specPending: specPending ?? this.specPending,
        specOptions: specOptions,
        specAllocation: specAllocation ?? this.specAllocation,
        isAddon: isAddon,
      );
}

class PreviewCartGroup {
  const PreviewCartGroup({
    required this.id,
    required this.sellerName,
    required this.badge,
    required this.mode,
    this.tempTag,
    this.note,
    this.subtotalNote,
    this.giftZone = false,
    required this.items,
  });

  final String id;
  final String sellerName;
  final String badge;
  final PreviewCheckoutMode mode;

  /// 溫層標籤：常溫 / 冷藏 / 冷凍；null 表示不顯示。
  final String? tempTag;
  final String? note;
  final String? subtotalNote;
  final bool giftZone;
  final List<PreviewCartItem> items;

  bool get isEditable => mode == PreviewCheckoutMode.pickable;

  PreviewCartGroup copyWith({List<PreviewCartItem>? items}) => PreviewCartGroup(
        id: id,
        sellerName: sellerName,
        badge: badge,
        mode: mode,
        tempTag: tempTag,
        note: note,
        subtotalNote: subtotalNote,
        giftZone: giftZone,
        items: items ?? this.items,
      );
}

class PreviewCartNotifier extends Notifier<List<PreviewCartGroup>> {
  @override
  List<PreviewCartGroup> build() => _seed();

  PreviewCartGroup? _group(String groupId) {
    for (final g in state) {
      if (g.id == groupId) return g;
    }
    return null;
  }

  void _mutateItem(
    String groupId,
    String itemId,
    PreviewCartItem Function(PreviewCartItem) transform,
  ) {
    state = [
      for (final g in state)
        if (g.id == groupId)
          g.copyWith(items: [
            for (final it in g.items)
              if (it.id == itemId) transform(it) else it,
          ])
        else
          g,
    ];
  }

  /// 勾選 / 取消勾選（僅 pickable 台可操作）。
  void toggle(String groupId, String itemId) {
    if (!(_group(groupId)?.isEditable ?? false)) return;
    _mutateItem(groupId, itemId, (it) => it.copyWith(checked: !it.checked));
  }

  /// +1（僅 pickable 台可操作）。
  void increment(String groupId, String itemId) {
    if (!(_group(groupId)?.isEditable ?? false)) return;
    _mutateItem(groupId, itemId, (it) => it.copyWith(qty: it.qty + 1));
  }

  /// −1，最少 1（僅 pickable 台可操作）。
  void decrement(String groupId, String itemId) {
    if (!(_group(groupId)?.isEditable ?? false)) return;
    _mutateItem(
      groupId,
      itemId,
      (it) => it.qty <= 1 ? it : it.copyWith(qty: it.qty - 1),
    );
  }

  /// 組合商品：展開 / 收合「組合內容」。
  void toggleBundle(String groupId, String itemId) {
    _mutateItem(
        groupId, itemId, (it) => it.copyWith(bundleExpanded: !it.bundleExpanded));
  }

  /// 批次下標：寫回規格分配；總和等於 qty 才算選完（清除待挑選）。
  void setAllocation(
      String groupId, String itemId, Map<String, int> allocation) {
    // 過濾掉數量 0 的規格
    final cleaned = <String, int>{
      for (final e in allocation.entries)
        if (e.value > 0) e.key: e.value,
    };
    _mutateItem(groupId, itemId, (it) {
      final total = cleaned.values.fold(0, (a, b) => a + b);
      return it.copyWith(
        specAllocation: cleaned,
        specPending: total != it.qty,
      );
    });
  }

  /// 刪除項目；該台清空後整台移除。
  void remove(String groupId, String itemId) {
    state = [
      for (final g in state)
        if (g.id == groupId)
          g.copyWith(items: g.items.where((it) => it.id != itemId).toList())
        else
          g,
    ].where((g) => g.items.isNotEmpty).toList();
  }

  /// 整台全選 / 全不選：header 的「全選此店家」用。
  /// pickable 與 default（整台一起結）皆可用；paused（暫停收單）不可。
  void toggleGroupAll(String groupId) {
    final g = _group(groupId);
    if (g == null || g.mode == PreviewCheckoutMode.paused) return;
    final allChecked = g.items.every((it) => it.checked);
    _setGroupChecked(groupId, !allChecked);
  }

  void _setGroupChecked(String groupId, bool checked) {
    state = [
      for (final g in state)
        if (g.id == groupId)
          g.copyWith(
            items: [for (final it in g.items) it.copyWith(checked: checked)],
          )
        else
          g,
    ];
  }

  /// 從「加購區」加入商品，並標記 [PreviewCartItem.isAddon]。
  ///
  /// [groupId] 指定要加入哪一台（加購區「購物車」下拉選定的台）；
  /// 為 null 時退回第一個可選購（pickable）台。目標台已有同品 → 數量 +1，
  /// 否則新增一列；連目標台都找不到時，建立專屬「加購商品」台。
  ///
  /// 回傳實際加入的台名稱（供畫面提示「已加入某台」）。
  String addAddon(String name, int price, {String? groupId}) {
    final itemId = 'addon_$name';

    final targetIndex = groupId != null
        ? state.indexWhere((g) => g.id == groupId)
        : state.indexWhere((g) => g.isEditable);

    if (targetIndex >= 0) {
      final target = state[targetIndex];
      // 目標台已有同一加購品 → 數量 +1
      if (target.items.any((it) => it.id == itemId)) {
        _mutateItem(target.id, itemId, (i) => i.copyWith(qty: i.qty + 1));
        return target.sellerName;
      }
      final newItem = PreviewCartItem(
        id: itemId,
        name: name,
        spec: '',
        qty: 1,
        price: price,
        checked: true,
        isAddon: true,
      );
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == targetIndex)
            target.copyWith(items: [...target.items, newItem])
          else
            state[i],
      ];
      return target.sellerName;
    }

    // 連可選購台都沒有 → 建立專屬「加購商品」台
    return _addToNewAddonGroup(itemId, name, price);
  }

  /// 建立專屬「加購商品」台並放入一筆加購品；回傳台名。
  String _addToNewAddonGroup(String itemId, String name, int price) {
    const addonGroupName = '加購商品';
    state = [
      ...state,
      PreviewCartGroup(
        id: 'g_addon',
        sellerName: addonGroupName,
        badge: '可選購',
        mode: PreviewCheckoutMode.pickable,
        tempTag: '常溫',
        items: [
          PreviewCartItem(
            id: itemId,
            name: name,
            spec: '',
            qty: 1,
            price: price,
            checked: true,
            isAddon: true,
          ),
        ],
      ),
    ];
    return addonGroupName;
  }

  /// 全選 / 全不選：只作用於 pickable 台的項目
  /// （default 台恆勾選、paused 台恆不勾選，不受影響）。
  void setAllPickable(bool checked) {
    state = [
      for (final g in state)
        g.isEditable
            ? g.copyWith(
                items: [for (final it in g.items) it.copyWith(checked: checked)],
              )
            : g,
    ];
  }
}

final previewCartProvider =
    NotifierProvider<PreviewCartNotifier, List<PreviewCartGroup>>(
  PreviewCartNotifier.new,
);

/// 種子資料：三台分別示範 pickable / default / paused 三種結帳模式，
/// 並含一筆買多優惠 + 滿件贈品區。
List<PreviewCartGroup> _seed() => const [
      // 直播下標搶購場：整台一起結，車內需補選 SKU 才能結帳。
      PreviewCartGroup(
        id: 'g_bid',
        sellerName: '07/12 晚間直播搶購場',
        badge: '整台一起結',
        mode: PreviewCheckoutMode.def,
        tempTag: '常溫',
        items: [
          PreviewCartItem(
            id: 'b1',
            name: '柔霧持色唇釉 直播下標',
            cardTypeLabel: '（直播卡）',
            spec: '',
            qty: 1,
            price: 650,
            checked: true,
            note: '直播限定價，售完不補；下標後 3–5 個工作天出貨。',
            specPending: true,
            specOptions: [
              SpecOption('#01 蜜桃裸', stock: 8, limit: 3),
              SpecOption('#02 乾燥玫瑰', stock: 2, limit: 5),
              SpecOption('#03 焦糖楓', stock: 0),
              SpecOption('#04 正紅', stock: 5),
            ],
          ),
          PreviewCartItem(
            id: 'b2',
            name: '水潤光唇釉 直播下標',
            cardTypeLabel: '（直播卡）',
            spec: '',
            qty: 2,
            price: 520,
            checked: true,
            specPending: true,
            specOptions: [
              SpecOption('亮澤裸粉', stock: 6, limit: 2),
              SpecOption('珊瑚橘', stock: 3),
              SpecOption('正紅', stock: 1, limit: 1),
              SpecOption('莓果紫', stock: 10),
            ],
          ),
        ],
      ),
      PreviewCartGroup(
        id: 'g_kelly',
        sellerName: 'Kelly 美妝快閃直播',
        badge: '可選購',
        mode: PreviewCheckoutMode.pickable,
        tempTag: '常溫',
        giftZone: true,
        items: [
          PreviewCartItem(
            id: 'k1',
            name: '玫瑰保濕精華液 30ml',
            cardTypeLabel: '（直播卡）',
            spec: '規格 一般 / 標準',
            qty: 1,
            price: 1280,
            original: 1580,
            checked: true,
            note: '開封後請冷藏，並於 3 個月內使用完畢。',
          ),
          PreviewCartItem(
            id: 'k2',
            name: '絲絨霧面唇釉 #05 楓糖',
            cardTypeLabel: '（直播卡）',
            spec: '規格 #05 楓糖',
            qty: 2,
            price: 590,
            original: 720,
            checked: true,
            bulkMinQty: 2,
            bulkUnitPrice: 520,
            bulkNote: '買 2 件以上每件 \$520',
          ),
          // 組合商品：含子品清單（呈現比照滿件贈品區）
          PreviewCartItem(
            id: 'k3',
            name: '精選彩妝三件組',
            cardTypeLabel: '（直播卡）',
            spec: '',
            qty: 1,
            price: 1680,
            original: 2100,
            checked: true,
            isBundle: true,
            bundleItems: [
              BundleSubItem('絲絨唇膏', spec: '正紅', qty: 1),
              BundleSubItem('霧感腮紅', spec: '蜜桃', qty: 1),
              BundleSubItem('大地色眼影盤', qty: 1),
            ],
          ),
        ],
      ),
      PreviewCartGroup(
        id: 'g_mia',
        sellerName: 'Mia 保養專場',
        badge: '棄標結帳',
        mode: PreviewCheckoutMode.abandon,
        tempTag: '常溫',
        items: [
          // 單一商品、多規格（容量 / 香味）已選定：同一列顯示各規格 ×數量。
          PreviewCartItem(
            id: 'm1',
            name: '白麝香淡香精',
            cardTypeLabel: '（直播卡）',
            spec: '',
            qty: 3,
            price: 2180,
            checked: true,
            specOptions: [
              SpecOption('50ml / 玫瑰香', stock: 10),
              SpecOption('50ml / 茉莉香', stock: 8),
              SpecOption('100ml / 玫瑰香', stock: 5),
              SpecOption('100ml / 茉莉香', stock: 4),
            ],
            specAllocation: {
              '50ml / 玫瑰香': 1,
              '50ml / 茉莉香': 1,
              '100ml / 玫瑰香': 1,
            },
          ),
          PreviewCartItem(
            id: 'm2',
            name: '亮白面膜 5 片組',
            cardTypeLabel: '（直播卡）',
            spec: '規格 5 片',
            qty: 1,
            price: 480,
            checked: true,
          ),
        ],
      ),
      PreviewCartGroup(
        id: 'g_jane',
        sellerName: 'Jane 香氛小舖',
        badge: '暫停結帳',
        mode: PreviewCheckoutMode.paused,
        tempTag: '冷藏',
        items: [
          PreviewCartItem(
            id: 'j1',
            name: '手工香氛蠟燭 200g',
            cardTypeLabel: '（直播卡）',
            spec: '規格 雪松',
            qty: 1,
            price: 890,
            checked: false,
            note: '請遠離易燃物與孩童，單次點燃勿超過 4 小時。',
          ),
        ],
      ),
    ];
