/// 「任選組合」商品（prototype）：買家需從商品池中挑選固定件數（可含規格）。
///
/// 兩種呈現共用這份資料：
/// - 商品卡按加入購物車 → 彈窗挑選（combo_sheet.dart）
/// - 商品內頁 → 組合挑選頁（combo_detail_screen.dart）
library;

class ComboItem {
  const ComboItem({
    required this.id,
    required this.name,
    this.limit = 1,
    this.specs = const [],
  });

  final String id;
  final String name;

  /// 限購件數。
  final int limit;

  /// 規格下拉選項（空代表無規格）。
  final List<String> specs;
}

class ComboConfig {
  const ComboConfig({
    required this.productId,
    required this.name,
    required this.price,
    required this.pickCount,
    required this.items,
  });

  /// 對應商品卡 / 內頁的商品 id。
  final String productId;
  final String name;
  final int price;

  /// 需挑選的總件數。
  final int pickCount;
  final List<ComboItem> items;
}

/// 以商品 id 為索引的任選組合設定。
const Map<String, ComboConfig> comboCatalog = {
  'combo1': ComboConfig(
    productId: 'combo1',
    name: '任選 4 件 寶寶配件超值組合',
    price: 599,
    pickCount: 4,
    items: [
      ComboItem(
          id: 'cbo1',
          name: '寶寶安撫奶嘴',
          limit: 1,
          specs: ['粉色', '藍色', '綠色']),
      ComboItem(
          id: 'cbo2',
          name: '嬰兒抗 UV 遮陽帽',
          limit: 1,
          specs: ['黃 / F', '白 / F']),
      ComboItem(
          id: 'cbo3',
          name: '寶寶嬰兒紗布手帕 5 入組',
          limit: 2,
          specs: ['白', '米']),
      ComboItem(
          id: 'cbo4',
          name: '嬰兒防踢被',
          limit: 2,
          specs: ['星星', '雲朵']),
      ComboItem(
          id: 'cbo5',
          name: '寶寶矽膠圍兜',
          limit: 1,
          specs: ['綠', '橘']),
    ],
  ),
};

/// 若該商品 id 是任選組合，回傳其設定；否則 null。
ComboConfig? comboForId(String id) => comboCatalog[id];
