import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/back_leading_button.dart';
import '../../widgets/standard_product_card.dart';

/// 商城分類頁（B）：由商城分類 tab 進入，含子分類篩選 + 商品卡。
///
/// prototype：分類 / 子分類 / 商品皆為前端範例資料。
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  /// 目前選到的子分類；null = 全部。
  String? _sub;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final data = _categoryData[widget.groupId];

    if (data == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackLeadingButton(fallbackLocation: '/shop'),
          title: const Text('分類'),
        ),
        body: Center(
          child: Text('找不到此分類',
              style: TextStyle(color: appTheme.fgMuted)),
        ),
      );
    }

    final products = _sub == null
        ? data.products
        : data.products.where((e) => e.sub == _sub).toList(growable: false);

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        leading: const BackLeadingButton(fallbackLocation: '/shop'),
        title: Text(data.name),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: appTheme.fg),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 子分類篩選
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: data.subs.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final label = i == 0 ? '全部' : data.subs[i - 1];
                final value = i == 0 ? null : data.subs[i - 1];
                final selected = _sub == value;
                return _SubChip(
                  label: label,
                  selected: selected,
                  onTap: () => setState(() => _sub = value),
                );
              },
            ),
          ),
          Divider(height: 1, color: appTheme.divider),
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Text('此子分類目前沒有商品',
                        style: TextStyle(color: appTheme.fgMuted)),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      const hPad = 16.0;
                      final avail = constraints.maxWidth - hPad * 2;
                      // 依可用寬度決定欄數（手機 2 欄、寬螢幕更多），
                      // 卡片為固定寬度並依內容收合高度，故按鈕下方不留白。
                      final cols = (avail / 190).floor().clamp(2, 6);
                      final cardW = (avail - spacing * (cols - 1)) / cols;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                        child: Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final p in products)
                              SizedBox(
                                width: cardW,
                                child: StandardProductCard(
                                  product: p.product,
                                  stock: previewStockFor(p.product),
                                ),
                              ),
                          ],
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

class _SubChip extends StatelessWidget {
  const _SubChip({
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
      color: selected ? accent : appTheme.chip,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : appTheme.chipFg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 供 web 預覽的商品內頁 fallback 查找：所有分類頁範例商品（去重）。
List<Product> categoryPreviewProducts() => [
      for (final data in _categoryData.values)
        for (final item in data.products) item.product,
    ];

// ── 範例資料（分類 → 子分類 + 商品）────────────────────────────────────────
typedef _CatProduct = ({String sub, Product product});
typedef _CatData = ({String name, List<String> subs, List<_CatProduct> products});

const Map<String, _CatData> _categoryData = {
  'g_apparel': (
    name: '服飾',
    subs: ['外套', '上衣', '童襪'],
    products: [
      (
        sub: '外套',
        product: Product(
            id: 'ca1',
            name: '秋冬童裝連帽外套',
            price: 590,
            originalPrice: 890,
            image: '',
            category: 'g_apparel',
            rating: 4.7,
            sales: 320,
            isHot: true)
      ),
      (
        sub: '外套',
        product: Product(
            id: 'ca2',
            name: '鋪棉防風夾克',
            price: 780,
            image: '',
            category: 'g_apparel',
            rating: 4.5,
            sales: 140)
      ),
      (
        sub: '上衣',
        product: Product(
            id: 'ca3',
            name: '柔軟針織毛衣',
            price: 480,
            image: '',
            category: 'g_apparel',
            rating: 4.6,
            sales: 210)
      ),
      (
        sub: '上衣',
        product: Product(
            id: 'ca4',
            name: '純棉長袖上衣',
            price: 320,
            originalPrice: 420,
            image: '',
            category: 'g_apparel',
            rating: 4.4,
            sales: 380)
      ),
      (
        sub: '童襪',
        product: Product(
            id: 'ca5',
            name: '保暖童襪 3 雙組',
            price: 129,
            originalPrice: 199,
            image: '',
            category: 'g_apparel',
            rating: 4.8,
            sales: 540)
      ),
    ],
  ),
  'g_beauty': (
    name: '美妝',
    subs: ['保養', '彩妝', '面膜'],
    products: [
      (
        sub: '保養',
        product: Product(
            id: 'cb1',
            name: '玫瑰保濕精華液 30ml',
            price: 1280,
            originalPrice: 1580,
            image: '',
            category: 'g_beauty',
            rating: 4.9,
            sales: 880,
            isHot: true)
      ),
      (
        sub: '保養',
        product: Product(
            id: 'cb2',
            name: '溫和保濕化妝水',
            price: 690,
            image: '',
            category: 'g_beauty',
            rating: 4.6,
            sales: 300)
      ),
      (
        sub: '彩妝',
        product: Product(
            id: 'cb3',
            name: '絲絨霧面唇釉 #05',
            price: 590,
            originalPrice: 720,
            image: '',
            category: 'g_beauty',
            rating: 4.6,
            sales: 430)
      ),
      (
        sub: '彩妝',
        product: Product(
            id: 'cb4',
            name: '持久眉筆',
            price: 350,
            image: '',
            category: 'g_beauty',
            rating: 4.5,
            sales: 260)
      ),
      (
        sub: '面膜',
        product: Product(
            id: 'cb5',
            name: '亮白面膜 5 片組',
            price: 480,
            image: '',
            category: 'g_beauty',
            rating: 4.4,
            sales: 260)
      ),
    ],
  ),
  'g_life': (
    name: '生活',
    subs: ['香氛', '廚房', '收納'],
    products: [
      (
        sub: '香氛',
        product: Product(
            id: 'cl1',
            name: '手工香氛蠟燭 200g',
            price: 890,
            image: '',
            category: 'g_life',
            rating: 4.7,
            sales: 150)
      ),
      (
        sub: '香氛',
        product: Product(
            id: 'cl2',
            name: '室內擴香瓶',
            price: 560,
            originalPrice: 720,
            image: '',
            category: 'g_life',
            rating: 4.6,
            sales: 220)
      ),
      (
        sub: '廚房',
        product: Product(
            id: 'cl3',
            name: '不鏽鋼保溫瓶 500ml',
            price: 690,
            originalPrice: 990,
            image: '',
            category: 'g_life',
            rating: 4.8,
            sales: 620,
            isHot: true)
      ),
      (
        sub: '廚房',
        product: Product(
            id: 'cl4',
            name: '矽膠料理鏟組',
            price: 299,
            image: '',
            category: 'g_life',
            rating: 4.3,
            sales: 180)
      ),
      (
        sub: '收納',
        product: Product(
            id: 'cl5',
            name: '多功能收納整理箱',
            price: 350,
            image: '',
            category: 'g_life',
            rating: 4.3,
            sales: 190)
      ),
    ],
  ),
  // ── 首頁「分類逛逛」對應的分類頁 ──────────────────────────────────────────
  'h_skincare': (
    name: '臉部保養',
    subs: ['精華', '化妝水', '乳液'],
    products: [
      (
        sub: '精華',
        product: Product(
            id: 'hs1',
            name: '玻尿酸保濕精華 30ml',
            price: 1180,
            originalPrice: 1480,
            image: '',
            category: 'h_skincare',
            rating: 4.8,
            sales: 640,
            isHot: true)
      ),
      (
        sub: '精華',
        product: Product(
            id: 'hs2',
            name: '維他命C 亮白精華',
            price: 1380,
            image: '',
            category: 'h_skincare',
            rating: 4.7,
            sales: 420)
      ),
      (
        sub: '化妝水',
        product: Product(
            id: 'hs3',
            name: '溫和保濕化妝水 200ml',
            price: 690,
            image: '',
            category: 'h_skincare',
            rating: 4.6,
            sales: 380)
      ),
      (
        sub: '乳液',
        product: Product(
            id: 'hs4',
            name: '清爽保濕乳液',
            price: 780,
            originalPrice: 980,
            image: '',
            category: 'h_skincare',
            rating: 4.5,
            sales: 260)
      ),
    ],
  ),
  'h_makeup': (
    name: '彩妝',
    subs: ['唇彩', '底妝', '眼妝'],
    products: [
      (
        sub: '唇彩',
        product: Product(
            id: 'hm1',
            name: '絲絨霧面唇釉 #05',
            price: 590,
            originalPrice: 720,
            image: '',
            category: 'h_makeup',
            rating: 4.6,
            sales: 430,
            isHot: true)
      ),
      (
        sub: '底妝',
        product: Product(
            id: 'hm2',
            name: '輕透遮瑕粉底液 SPF30',
            price: 880,
            image: '',
            category: 'h_makeup',
            rating: 4.5,
            sales: 310)
      ),
      (
        sub: '底妝',
        product: Product(
            id: 'hm3',
            name: '控油蜜粉餅',
            price: 650,
            image: '',
            category: 'h_makeup',
            rating: 4.4,
            sales: 200)
      ),
      (
        sub: '眼妝',
        product: Product(
            id: 'hm4',
            name: '持久眉筆',
            price: 350,
            image: '',
            category: 'h_makeup',
            rating: 4.5,
            sales: 260)
      ),
    ],
  ),
  'h_fragrance': (
    name: '香氛',
    subs: ['香水', '擴香', '蠟燭'],
    products: [
      (
        sub: '香水',
        product: Product(
            id: 'hf1',
            name: '沉香木質淡香精 50ml',
            price: 1980,
            originalPrice: 2380,
            image: '',
            category: 'h_fragrance',
            rating: 4.8,
            sales: 180,
            isHot: true)
      ),
      (
        sub: '擴香',
        product: Product(
            id: 'hf2',
            name: '室內擴香瓶',
            price: 560,
            originalPrice: 720,
            image: '',
            category: 'h_fragrance',
            rating: 4.6,
            sales: 220)
      ),
      (
        sub: '蠟燭',
        product: Product(
            id: 'hf3',
            name: '手工香氛蠟燭 200g',
            price: 890,
            image: '',
            category: 'h_fragrance',
            rating: 4.7,
            sales: 150)
      ),
    ],
  ),
  'h_body': (
    name: '身體護理',
    subs: ['沐浴', '身體乳', '手部'],
    products: [
      (
        sub: '沐浴',
        product: Product(
            id: 'hb1',
            name: '胺基酸保濕沐浴乳 500ml',
            price: 420,
            image: '',
            category: 'h_body',
            rating: 4.6,
            sales: 340)
      ),
      (
        sub: '身體乳',
        product: Product(
            id: 'hb2',
            name: '燕麥修護身體乳 250ml',
            price: 480,
            originalPrice: 620,
            image: '',
            category: 'h_body',
            rating: 4.7,
            sales: 280,
            isHot: true)
      ),
      (
        sub: '手部',
        product: Product(
            id: 'hb3',
            name: '滋潤護手霜 3 入組',
            price: 360,
            image: '',
            category: 'h_body',
            rating: 4.5,
            sales: 410)
      ),
    ],
  ),
  'h_men': (
    name: '男士',
    subs: ['洗面乳', '刮鬍', '保養'],
    products: [
      (
        sub: '洗面乳',
        product: Product(
            id: 'hn1',
            name: '男士控油潔面乳 150ml',
            price: 390,
            image: '',
            category: 'h_men',
            rating: 4.5,
            sales: 300)
      ),
      (
        sub: '刮鬍',
        product: Product(
            id: 'hn2',
            name: '溫和刮鬍泡 200ml',
            price: 320,
            image: '',
            category: 'h_men',
            rating: 4.4,
            sales: 210)
      ),
      (
        sub: '保養',
        product: Product(
            id: 'hn3',
            name: '男士全效保濕乳',
            price: 680,
            originalPrice: 880,
            image: '',
            category: 'h_men',
            rating: 4.6,
            sales: 240,
            isHot: true)
      ),
    ],
  ),
};
