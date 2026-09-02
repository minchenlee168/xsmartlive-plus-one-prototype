import '../utils/platform_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_api.dart';
import '../models/combo.dart';
import '../models/win_mall_bid.dart';
import '../models/product.dart';
import '../models/product_card_detail.dart';
import '../models/product_group.dart';
import '../models/product_spec.dart';
import '../models/product_variant.dart';
import 'analytics_provider.dart';
import 'auth_provider.dart';
import 'repository_providers.dart';

/// Web 預覽用的商城分類與商品範例。分類 tab 與商品皆為前端範例，
/// 商品的 [Product.category] 存所屬分類 id，供切換分類時篩選。
const _sampleGroups = <ProductGroup>[
  ProductGroup(id: 'g_apparel', name: '服飾'),
  ProductGroup(id: 'g_beauty', name: '美妝'),
  ProductGroup(id: 'g_life', name: '生活'),
];

/// Web 預覽用的首頁「分類逛逛」分類。id 對應 `category_screen.dart`
/// 的 `_categoryData`，點按分類卡即可導向對應分類頁。
const _sampleCategories = <ProductGroup>[
  ProductGroup(id: 'h_skincare', name: '臉部保養'),
  ProductGroup(id: 'h_makeup', name: '彩妝'),
  ProductGroup(id: 'h_fragrance', name: '香氛'),
  ProductGroup(id: 'h_body', name: '身體護理'),
  ProductGroup(id: 'h_men', name: '男士'),
];

const _sampleShopProducts = <Product>[
  // 服飾
  Product(
      id: 'sp1',
      name: '秋冬童裝連帽外套',
      price: 590,
      originalPrice: 890,
      image: '',
      category: 'g_apparel',
      rating: 4.7,
      sales: 320,
      isHot: true),
  Product(
      id: 'sp2',
      name: '柔軟針織毛衣',
      price: 480,
      image: '',
      category: 'g_apparel',
      rating: 4.5,
      sales: 210),
  Product(
      id: 'sp3',
      name: '保暖童襪 3 雙組',
      price: 129,
      originalPrice: 199,
      image: '',
      category: 'g_apparel',
      rating: 4.8,
      sales: 540),
  // 美妝
  Product(
      id: 'sp4',
      name: '玫瑰保濕精華液 30ml',
      price: 1280,
      originalPrice: 1580,
      image: '',
      category: 'g_beauty',
      rating: 4.9,
      sales: 880,
      isHot: true),
  Product(
      id: 'sp5',
      name: '絲絨霧面唇釉 #05',
      price: 590,
      originalPrice: 720,
      image: '',
      category: 'g_beauty',
      rating: 4.6,
      sales: 430),
  Product(
      id: 'sp6',
      name: '亮白面膜 5 片組',
      price: 480,
      image: '',
      category: 'g_beauty',
      rating: 4.4,
      sales: 260),
  // 生活
  Product(
      id: 'sp7',
      name: '手工香氛蠟燭 200g',
      price: 890,
      image: '',
      category: 'g_life',
      rating: 4.7,
      sales: 150),
  Product(
      id: 'sp8',
      name: '不鏽鋼保溫瓶 500ml',
      price: 690,
      originalPrice: 990,
      image: '',
      category: 'g_life',
      rating: 4.8,
      sales: 620,
      isHot: true),
  Product(
      id: 'sp9',
      name: '多功能收納整理箱',
      price: 350,
      image: '',
      category: 'g_life',
      rating: 4.3,
      sales: 190),
];

/// Fetches all product groups for the store.
final productGroupsProvider = FutureProvider<List<ProductGroup>>((ref) async {
  if (isWebPreview) return _sampleGroups;
  return ref.read(productRepositoryProvider).fetchProductGroups();
});

/// Fetches categories from GET /store/{store}/category.
final categoriesProvider = FutureProvider<List<ProductGroup>>((ref) async {
  if (isWebPreview) return _sampleCategories;
  return ref.read(productRepositoryProvider).fetchCategories();
});

// ── Product list filter ───────────────────────────────────────────────────────

/// Filter key for [productListProvider].
///
/// [storeCategoryId] – top-level storeCategory id (the active group tab).
/// [categoryId]      – product category id from the sub-category tab row;
///                     null means "全部" (no category filter).
class ProductFilter {
  const ProductFilter({this.storeCategoryId, this.categoryId});

  final String? storeCategoryId;
  final String? categoryId;

  @override
  bool operator ==(Object other) =>
      other is ProductFilter &&
      other.storeCategoryId == storeCategoryId &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(storeCategoryId, categoryId);
}

// ── Paginated product list state + notifier ───────────────────────────────────

class ProductListState {
  const ProductListState({
    required this.products,
    required this.hasMore,
    this.isLoadingMore = false,
    this.page = 1,
  });

  final List<Product> products;
  final bool hasMore;
  final bool isLoadingMore;
  final int page;

  ProductListState copyWith({
    List<Product>? products,
    bool? hasMore,
    bool? isLoadingMore,
    int? page,
  }) =>
      ProductListState(
        products: products ?? this.products,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        page: page ?? this.page,
      );
}

class ProductListNotifier
    extends FamilyAsyncNotifier<ProductListState, ProductFilter> {
  static const _pageSize = 20;

  @override
  Future<ProductListState> build(ProductFilter filter) async {
    // Web 預覽：用範例商品，並依所選分類（storeCategoryId）篩選，
    // 讓切換分類 tab 看得到商品清單變化。
    if (isWebPreview) {
      final id = filter.storeCategoryId;
      final products = id == null
          ? _sampleShopProducts
          : _sampleShopProducts
              .where((p) => p.category == id)
              .toList(growable: false);
      return ProductListState(products: products, hasMore: false);
    }
    final result = await ref.read(productRepositoryProvider).fetchProductsPage(
          storeCategoryId: filter.storeCategoryId,
          categoryId: filter.categoryId,
          page: 1,
          pageSize: _pageSize,
        );
    return ProductListState(
        products: result.products, hasMore: result.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final result =
          await ref.read(productRepositoryProvider).fetchProductsPage(
                storeCategoryId: arg.storeCategoryId,
                categoryId: arg.categoryId,
                page: current.page + 1,
                pageSize: _pageSize,
              );
      state = AsyncData(current.copyWith(
        products: [...current.products, ...result.products],
        hasMore: result.hasMore,
        isLoadingMore: false,
        page: current.page + 1,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

/// Paginated product card list, keyed by [ProductFilter].
final productListProvider = AsyncNotifierProvider.family<ProductListNotifier,
    ProductListState, ProductFilter>(
  ProductListNotifier.new,
);

// ── Search ────────────────────────────────────────────────────────────────────

/// Filter parameter for [searchProductsProvider].
class SearchFilter {
  const SearchFilter({required this.keyword});

  final String keyword;

  @override
  bool operator ==(Object other) =>
      other is SearchFilter && other.keyword == keyword;

  @override
  int get hashCode => keyword.hashCode;
}

/// Searches products by keyword (page 1 only, no pagination).
final searchProductsProvider =
    FutureProvider.family<List<Product>, SearchFilter>((ref, filter) async {
  if (filter.keyword.isEmpty) return [];
  final result = await ref
      .read(productRepositoryProvider)
      .fetchProductsPage(keyword: filter.keyword);
  return result.products;
});

/// Fetches a single product card by ID (lightweight Product model).
final productCardProvider = FutureProvider.family<Product?, String>(
  (ref, id) async {
    return ref.read(productRepositoryProvider).fetchProductCard(id);
  },
);




/// Fetches the full ProductCardDetail for the detail screen.
/// Specs are parsed directly from the product card API response.
final productCardDetailProvider =
    FutureProvider.family<ProductCardDetail?, String>((ref, id) async {
  return ref.read(productRepositoryProvider).fetchProductCardDetail(id);
});

/// Fetches specs for a product.
final productSpecsProvider = FutureProvider.family<List<ProductSpec>, int>(
  (ref, productId) async {
    return ref.read(productRepositoryProvider).fetchProductSpecs(productId);
  },
);

/// Fetches variants for a product.
final productVariantsProvider =
    FutureProvider.family<List<ProductVariant>, int>(
  (ref, productId) async {
    return ref.read(productRepositoryProvider).fetchProductVariants(productId);
  },
);

/// Fetches combo list.
final combosProvider = FutureProvider<List<Combo>>((ref) async {
  return ref.read(comboRepositoryProvider).fetchCombos();
});

/// Filter for upsell lookups (B9). Card type 1 (直播卡) maps to
/// market_type 1 (直播賣場); everything else falls back to market_type 4 (商城).
class UpsellFilter {
  const UpsellFilter({
    required this.productId,
    required this.cardType,
    required this.categoryId,
  });

  final int productId;
  final int cardType;
  final int categoryId;

  int get marketType => cardType == 1 ? 1 : 4;

  @override
  bool operator ==(Object other) =>
      other is UpsellFilter &&
      other.productId == productId &&
      other.cardType == cardType &&
      other.categoryId == categoryId;

  @override
  int get hashCode => Object.hash(productId, cardType, categoryId);
}

/// Fetches upsell add-on items for a given main product (B9).
final upsellProvider =
    FutureProvider.family<List<UpsellItem>, UpsellFilter>((ref, filter) async {
  if (filter.productId <= 0 || filter.categoryId <= 0) {
    return const <UpsellItem>[];
  }
  return ref.read(productRepositoryProvider).fetchUpsell(
        productId: filter.productId,
        marketType: filter.marketType,
        categoryId: filter.categoryId,
      );
});

/// Fetches a single combo by ID.
final comboProvider = FutureProvider.family<Combo?, int>(
  (ref, id) async {
    return ref.read(comboRepositoryProvider).fetchCombo(id);
  },
);

// Kept for search screen reset; no longer drives product filtering directly.
final selectedCategoryProvider = StateProvider<int?>((ref) => null);

final favoritesProvider =
    FutureProvider<List<FavoriteProduct>>((ref) async {
  try {
    return await ref.read(productRepositoryProvider).fetchFavorites();
  } catch (_) {
    // Web 預覽（未登入 / 無法打真實 API）→ 回退範例收藏，讓「收藏 / 追蹤」
    // 頁有內容可預覽；真機登入後走真實 API。
    return _sampleFavorites;
  }
});

const List<FavoriteProduct> _sampleFavorites = [
  FavoriteProduct(
    streamer: '美妝達人小芸',
    product: Product(
      id: 'fav1',
      name: '玫瑰保濕精華液 30ml',
      price: 1280,
      originalPrice: 1580,
      image: '',
      category: '保養',
    ),
  ),
  FavoriteProduct(
    streamer: 'Kelly 美妝快閃',
    product: Product(
      id: 'fav2',
      name: '絲絨霧面唇釉 #05 楓糖',
      price: 590,
      originalPrice: 720,
      image: '',
      category: '彩妝',
    ),
  ),
  FavoriteProduct(
    streamer: 'Mia 保養專場',
    product: Product(
      id: 'fav3',
      name: '玻尿酸保濕面膜 10 入組',
      price: 399,
      image: '',
      category: '保養',
    ),
  ),
  FavoriteProduct(
    streamer: '鮮選市集直播',
    product: Product(
      id: 'fav4',
      name: '挪威生鮮鮭魚切片 300g',
      price: 380,
      image: '',
      category: '生鮮',
      inStock: false,
    ),
  ),
  FavoriteProduct(
    streamer: '廚娘小桂的直播廚房',
    product: Product(
      id: 'fav5',
      name: '古早味手工冷凍水餃 60 顆',
      price: 199,
      image: '',
      category: '冷凍',
    ),
  ),
  FavoriteProduct(
    streamer: '媽咪好物推薦',
    product: Product(
      id: 'fav6',
      name: '寶寶學步防滑襪 3 雙組',
      price: 129,
      image: '',
      category: '嬰幼兒',
    ),
  ),
];

// Cart — client-side state only.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    // Reset the in-memory quick-add cart whenever the logged-in member
    // changes. Logout and session expiry both null out the member (see
    // AuthNotifier), so this clears one account's items before the next
    // session — and rebuilds for an account switch.
    ref.watch(
      authNotifierProvider.select((auth) => auth.valueOrNull?.memberId),
    );
    return [];
  }

  void addItem(Product product) {
    final idx = state.indexWhere((c) => c.product.id == product.id);
    if (idx >= 0) {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx)
            state[i].copyWith(quantity: state[i].quantity + 1)
          else
            state[i],
      ];
    } else {
      state = [...state, CartItem(product: product)];
    }
    // Event #4 (加入購物車) — central chokepoint for every in-memory add
    // (live room, favorites, shop card). Server-cart adds that bypass this
    // notifier log at their own call site (e.g. product detail).
    ref.read(analyticsServiceProvider).logAddToCartProduct(product);
  }

  void removeItem(String productId) {
    state = state.where((c) => c.product.id != productId).toList();
  }

  void clear() => state = [];

  double get total =>
      state.fold(0, (sum, c) => sum + c.product.price * c.quantity);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider.notifier).total;
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartApiProvider).whenOrNull(
        data: (cart) =>
            cart?.items.fold(0, (sum, c) => sum! + c.quantity) ?? 0,
      ) ??
      0;
});

// Cart API — server-side state.
class CartApiNotifier extends AsyncNotifier<CartApi?> {
  @override
  Future<CartApi?> build() async {
    // The server cart is scoped to the authenticated member, so make this
    // provider rebuild whenever the logged-in member changes. This refetches
    // the cart on a fresh login (updating the count badge — login screen is
    // outside the shell so the badge was never refreshed before) and clears
    // the stale cart on logout / account switch.
    final memberId = ref.watch(
      authNotifierProvider.select((auth) => auth.valueOrNull?.memberId),
    );
    // Web 預覽（未登入）回傳假購物車，方便查看「已有商品」的畫面。
    if (isWebPreview && memberId == null) return _previewCart();
    if (memberId == null) return null;
    return ref.read(cartRepositoryProvider).fetchCart();
  }

  /// Adds an item to the server cart. [cardType] 1 = 直播卡 (winLiveBid),
  /// 2 = 商城卡 (winMallBid). Calling the wrong endpoint returns
  /// `20103: 賣場類型不符` so dispatching by card type is mandatory.
  Future<void> addItem({
    required int variantId,
    required int marketId,
    int quantity = 1,
    int cardType = 2,
  }) async {
    final repo = ref.read(cartRepositoryProvider);
    final request = WinMallBidRequest(
      productCardVariantId: variantId,
      quantity: quantity,
    );
    if (cardType == 1) {
      await repo.winLiveBid(marketId: marketId, request: request);
    } else {
      await repo.winMallBid(marketId: marketId, request: request);
    }
    ref.invalidateSelf();
  }

  /// Optimistic quantity update — applies the new quantity to local state
  /// immediately so the UI updates without waiting for the round trip,
  /// then calls the API and refetches in the background to sync totals.
  /// Reverts on failure and rethrows so the caller can show a snackbar.
  Future<void> updateItem(int cartItemId, {required int quantity}) async {
    if (quantity < 1) return;
    final previous = state.valueOrNull;
    if (previous != null) {
      final newItems = [
        for (final item in previous.items)
          if (item.id == cartItemId)
            item.copyWith(quantity: quantity)
          else
            item,
      ];
      state = AsyncData(previous.copyWith(items: newItems));
    }
    try {
      await ref
          .read(cartRepositoryProvider)
          .updateItem(cartItemId, quantity: quantity);
      // Sync totals from server (subtotal/discount may change).
      final fresh =
          await ref.read(cartRepositoryProvider).fetchCart();
      state = AsyncData(fresh);
    } catch (e) {
      // Revert on failure.
      state = await AsyncValue.guard(
        () => ref.read(cartRepositoryProvider).fetchCart(),
      );
      rethrow;
    }
  }

  /// Optimistic remove — drops the item from local state immediately,
  /// then hits the API + refetches. Reverts on failure.
  Future<void> removeItem(int cartItemId) async {
    final previous = state.valueOrNull;
    if (previous != null) {
      final newItems =
          previous.items.where((item) => item.id != cartItemId).toList();
      state = AsyncData(previous.copyWith(items: newItems));
    }
    try {
      await ref.read(cartRepositoryProvider).removeItem(cartItemId);
      final fresh =
          await ref.read(cartRepositoryProvider).fetchCart();
      state = AsyncData(fresh);
    } catch (e) {
      state = await AsyncValue.guard(
        () => ref.read(cartRepositoryProvider).fetchCart(),
      );
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(cartRepositoryProvider).fetchCart(),
    );
  }
}

final cartApiProvider = AsyncNotifierProvider<CartApiNotifier, CartApi?>(
  CartApiNotifier.new,
);

/// 假的購物車資料——prototype 預覽用（未登入時），讓「購物車已有商品」的畫面
/// 可以被瀏覽。要調整預覽內容改這裡的 items / 折扣即可。
CartApi _previewCart() {
  const ts = '2026-08-27T10:00:00Z';
  CartApiItem item(int id, String name, int qty, int price) => CartApiItem(
        id: id,
        cartId: 9001,
        productId: id,
        productVariantId: id,
        quantity: qty,
        unitPrice: price,
        product: CartApiProduct(id: id, name: name),
        createdAt: ts,
        updatedAt: ts,
      );

  final items = [
    item(1, '玫瑰保濕精華液 30ml', 1, 1280),
    item(2, '絲絨霧面唇釉 #05 楓糖', 2, 590),
    item(3, '白麝香淡香精 50ml', 1, 2180),
  ];
  final subtotal =
      items.fold<int>(0, (s, i) => s + i.unitPrice * i.quantity).toDouble();
  const discount = 200.0;

  return CartApi(
    id: 9001,
    skuCount: items.length,
    subtotal: subtotal,
    discount: discount,
    total: subtotal - discount,
    items: items,
    canAbandon: true,
    createdAt: ts,
    updatedAt: ts,
  );
}
