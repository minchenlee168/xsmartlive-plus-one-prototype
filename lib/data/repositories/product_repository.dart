import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/mock_data.dart';
import '../../models/product.dart';
import '../../models/product_card_detail.dart';
import '../../models/product_group.dart';
import '../../models/product_spec.dart';
import '../../models/product_variant.dart';
import '../dio_client.dart';

class ProductRepository {
  ProductRepository(this._dioClient);

  final DioClient _dioClient;

  /// 2026-05 spec — backend enforces `keyword` ≤ 100 chars (OS match_phrase
  /// / DB LIKE blow up beyond that). Trim + clamp client-side so paste
  /// accidents don't trigger a 422.
  static String? _clampKeyword(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.length > 100 ? trimmed.substring(0, 100) : trimmed;
  }

  // ── Store Categories ────────────────────────────────────────────────────────

  /// Fetches store category tree from GET /store/{store}/storeCategory.
  /// Top-level items become the main group tabs; their children are sub-tabs.
  Future<List<ProductGroup>> fetchProductGroups() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.storeCategories);
      final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return list
          .map((e) => ProductGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  /// Fetches product categories from GET /store/{store}/category.
  /// Used as sub-category tabs within each group; filter products with category_ids[].
  Future<List<ProductGroup>> fetchCategories() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.categories);
      final list = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      final seen = <String>{};
      final result = <ProductGroup>[];
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final id = map['id']?.toString() ?? '';
        final name = map['name'] as String? ?? '';
        if (id.isNotEmpty && seen.add(id)) {
          result.add(ProductGroup(id: id, name: name));
        }
      }
      return result;
    } on DioException catch (_) {
      return [];
    }
  }

  // ── Product Cards ───────────────────────────────────────────────────────────

  /// Fetches a paginated page of product cards.
  ///
  /// Returns `({products, hasMore})`. Sends:
  /// - `store_category_ids[]` for the top-level group filter
  /// - `category_ids[]` for the sub-category tab filter
  /// - `keyword` for search
  Future<({List<Product> products, bool hasMore})> fetchProductsPage({
    String? storeCategoryId,
    String? categoryId,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.productCards,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'market_id': 1,
          //TODO-LIST: 修改 market_id
          if (storeCategoryId != null && storeCategoryId.isNotEmpty)
            'store_category_ids[]': [int.parse(storeCategoryId)],
          if (categoryId != null && categoryId.isNotEmpty)
            'category_ids[]': [int.parse(categoryId)],
          if (_clampKeyword(keyword) != null) 'keyword': _clampKeyword(keyword),
        },
      );
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>;
      final pagination = ((data['meta'] as Map<String, dynamic>?)
          ?['pagination']) as Map<String, dynamic>?;
      final totalPages = (pagination?['total_pages'] as int?) ?? 1;
      final currentPage = (pagination?['current_page'] as int?) ?? page;
      final products =
          list.map((e) => _parseProduct(e as Map<String, dynamic>)).toList();
      return (products: products, hasMore: currentPage < totalPages);
    } on DioException catch (_) {
      return (products: <Product>[], hasMore: false);
    }
  }

  /// Fetches product cards without pagination (used by search and legacy callers).
  Future<List<Product>> fetchProducts({
    List<int>? categoryIds,
    List<int>? storeCategoryIds,
    String? keyword,
    String? orderBy,
    String? direction,
    int? marketId,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.productCards,
        queryParameters: {
          if (categoryIds != null && categoryIds.isNotEmpty)
            'category_ids[]': categoryIds,
          if (storeCategoryIds != null && storeCategoryIds.isNotEmpty)
            'store_category_ids[]': storeCategoryIds,
          if (_clampKeyword(keyword) != null) 'keyword': _clampKeyword(keyword),
          if (orderBy != null) 'order_by': orderBy,
          if (direction != null) 'direction': direction,
          if (marketId != null) 'market_id': marketId,
        },
      );
      final list =
          (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return list
          .map((e) => _parseProduct(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return MockData.products;
    }
  }

  // ── Product Card Detail ─────────────────────────────────────────────────────

  /// GET /store/{store}/productCard/{id} — returns rich detail model.
  Future<ProductCardDetail?> fetchProductCardDetail(String id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.productCard(id));
      final data = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return ProductCardDetail.fromJson(data);
    } on DioException catch (_) {
      return null;
    }
  }

  /// GET /store/{store}/productCard/{id} — returns lightweight Product model.
  Future<Product?> fetchProductCard(String id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.productCard(id));
      final card = (response.data as Map<String, dynamic>)['data']
          as Map<String, dynamic>;
      return _parseProduct(card);
    } on DioException catch (_) {
      return null;
    }
  }

  // ── Upsell (加價購) ─────────────────────────────────────────────────────────

  /// GET /store/{store}/upsell — returns upsell campaign items eligible
  /// for the supplied main product. All three query params are required by
  /// the backend (it 422s otherwise).
  ///
  /// `marketType` semantics per API_DOCUMENT.json:
  ///   1 = 直播賣場, 2 = 社團貼文, 3 = 粉絲團貼文, 4 = 商城
  Future<List<UpsellItem>> fetchUpsell({
    required int productId,
    required int marketType,
    required int categoryId,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.upsell,
        queryParameters: {
          'product_id': productId,
          'market_type': marketType,
          'category_id': categoryId,
        },
      );
      final body = response.data as Map<String, dynamic>;
      // Per OpenAPI the response is `{ data: UpsellCampaignItemResourceCollection }`
      // which itself wraps a `data: [...]`. Be tolerant either way.
      final outer = body['data'];
      final list = outer is List
          ? outer
          : (outer is Map<String, dynamic>
              ? (outer['data'] as List<dynamic>? ?? const [])
              : const []);
      return list
          .whereType<Map<String, dynamic>>()
          .map(UpsellItem.fromJson)
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  // ── Specs & Variants ────────────────────────────────────────────────────────

  /// GET /store/{store}/product/{productId}/spec
  Future<List<ProductSpec>> fetchProductSpecs(int productId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.productSpecs(productId));
      final list =
          (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return list
          .map((e) => ProductSpec.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  /// GET /store/{store}/product/{productId}/variant
  Future<List<ProductVariant>> fetchProductVariants(int productId) async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.productVariants(productId));
      final list =
          (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
      return list
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  // ── Favorites ───────────────────────────────────────────────────────────────

  /// Favorites endpoint does not exist on the server. Returns mock data only.
  Future<List<FavoriteProduct>> fetchFavorites() async {
    return MockData.products
        .take(3)
        .map((p) => FavoriteProduct(product: p, streamer: '美妝達人'))
        .toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Product _parseProduct(Map<String, dynamic> card) {
    final images = card['image'] as List<dynamic>? ?? [];
    // 2026-05 spec rev: ProductCardResource renamed `variant` → `variants`.
    // Read the new key first, fall back to the legacy key during rollout.
    final variants = (card['variants'] as List<dynamic>?) ??
        (card['variant'] as List<dynamic>?) ??
        const [];
    final firstVariant =
        variants.isNotEmpty ? variants.first as Map<String, dynamic> : null;
    final categories = card['category'] as List<dynamic>? ?? [];
    final firstCategory =
        categories.isNotEmpty ? categories.first as Map<String, dynamic> : null;
    // `is_orderable` lets the backend veto add-to-cart for stockless / closed
    // cards before the client tries /win. Default to true for legacy payloads.
    final isOrderable = card['is_orderable'] as bool? ?? true;
    return Product(
      id: card['id']?.toString() ?? '',
      name: card['name'] as String? ?? '',
      price: (firstVariant?['sale_price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (firstVariant?['original_price'] as num?)?.toDouble(),
      image: images.isNotEmpty
          ? (images.first as Map<String, dynamic>)['url'] as String? ?? ''
          : '',
      category: firstCategory?['name'] as String? ?? '',
      sales: (card['sold_amount'] as num?)?.toInt() ?? 0,
      inStock: isOrderable &&
          ((firstVariant?['stock'] as int? ?? 0) > 0 ||
              (card['allow_oversell'] as bool? ?? false)),
    );
  }
}
