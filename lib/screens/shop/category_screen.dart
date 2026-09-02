import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/shop_product_card.dart';

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
        appBar: AppBar(title: const Text('分類')),
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
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, i) =>
                        ShopProductCard(product: products[i].product),
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
};
