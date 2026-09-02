import '../../models/product.dart';

/// 主題館範例資料（web 預覽）：每館一標題 + 副標 + 該館商品卡。
/// [standard] = true 用標準商品卡（可選數量 + 庫存）；false 用精簡商品卡。
typedef ThemeHallItem = ({Product product, int stock});
typedef ThemeHall = ({
  String title,
  String subtitle,
  bool standard,
  List<ThemeHallItem> items,
});

const List<ThemeHall> themeHalls = [
  (
    title: '秋冬童裝主題館',
    subtitle: '換季新品 5 折起（精簡商品卡）',
    standard: false,
    items: [
      (
        stock: 30,
        product: Product(
            id: 'th1',
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
        stock: 12,
        product: Product(
            id: 'th2',
            name: '鋪棉防風夾克',
            price: 780,
            image: '',
            category: 'g_apparel',
            rating: 4.5,
            sales: 140)
      ),
      (
        stock: 45,
        product: Product(
            id: 'th3',
            name: '柔軟針織毛衣',
            price: 480,
            image: '',
            category: 'g_apparel',
            rating: 4.6,
            sales: 210)
      ),
      (
        stock: 88,
        product: Product(
            id: 'th4',
            name: '保暖童襪 3 雙組',
            price: 129,
            originalPrice: 199,
            image: '',
            category: 'g_apparel',
            rating: 4.8,
            sales: 540)
      ),
      (
        stock: 20,
        product: Product(
            id: 'th4b',
            name: '純棉長袖上衣',
            price: 320,
            originalPrice: 420,
            image: '',
            category: 'g_apparel',
            rating: 4.4,
            sales: 380)
      ),
      (
        stock: 6,
        product: Product(
            id: 'th4c',
            name: '毛絨保暖圍脖',
            price: 260,
            image: '',
            category: 'g_apparel',
            rating: 4.6,
            sales: 90)
      ),
      // 任選組合商品（加入購物車會跳出挑選彈窗，點名稱進組合內頁）。
      (
        stock: 99,
        product: Product(
            id: 'combo1',
            name: '任選 4 件 寶寶配件超值組合',
            price: 599,
            image: '',
            category: 'g_apparel',
            rating: 4.8,
            sales: 260,
            isHot: true)
      ),
    ],
  ),
  (
    title: '美妝新品主題館',
    subtitle: '人氣熱銷精選（標準商品卡）',
    standard: true,
    items: [
      (
        stock: 25,
        product: Product(
            id: 'th5',
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
        stock: 8,
        product: Product(
            id: 'th6',
            name: '絲絨霧面唇釉 #05',
            price: 590,
            originalPrice: 720,
            image: '',
            category: 'g_beauty',
            rating: 4.6,
            sales: 430)
      ),
      (
        stock: 60,
        product: Product(
            id: 'th7',
            name: '亮白面膜 5 片組',
            price: 480,
            image: '',
            category: 'g_beauty',
            rating: 4.4,
            sales: 260)
      ),
      (
        stock: 3,
        product: Product(
            id: 'th8',
            name: '溫和保濕化妝水',
            price: 690,
            image: '',
            category: 'g_beauty',
            rating: 4.6,
            sales: 300)
      ),
      (
        stock: 15,
        product: Product(
            id: 'th8b',
            name: '維他命C 亮白精華',
            price: 1380,
            image: '',
            category: 'g_beauty',
            rating: 4.7,
            sales: 420)
      ),
      (
        stock: 0,
        product: Product(
            id: 'th8c',
            name: '控油蜜粉餅',
            price: 650,
            image: '',
            category: 'g_beauty',
            rating: 4.4,
            sales: 200)
      ),
    ],
  ),
];
