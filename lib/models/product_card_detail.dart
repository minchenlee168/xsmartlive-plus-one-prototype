import 'product_bundle_item.dart';
import 'product_spec.dart';
import 'product_variant.dart';

/// Rich model for a single productCard API response.
/// Used by the product detail screen to display images, specs, variants, etc.
class ProductCardDetail {
  const ProductCardDetail({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.marketId,
    required this.type,
    required this.name,
    required this.hasSpec,
    required this.allowOversell,
    required this.images,
    required this.variants,
    this.specs = const [],
    this.intro = '',
    this.tags = const [],
    this.category = '',
    this.categoryId = 0,
    this.bundleItems = const [],
    this.isOrderable = true,
    this.soldAmount = 0,
  });

  final int id;
  final int productId;
  final int storeId;
  final int marketId;

  /// Product card type — `1 = 直播卡 (live)`, `2 = 商城卡 (mall)`. Determines
  /// which `winLiveBid` / `winMallBid` endpoint must be hit when adding to
  /// cart (the server returns 20103 if the wrong endpoint is used).
  final int type;

  final String name;
  final bool hasSpec;
  final bool allowOversell;

  /// 2026-05 spec: backend computes whether the card can still be ordered
  /// (stock + market window + per-card flags). When false the UI disables
  /// the 加入購物車 button instead of waiting for /win to 422.
  final bool isOrderable;

  /// 2026-05 spec: aggregate sold quantity for the card. Surfaced on the
  /// detail screen near the price so buyers see live popularity.
  final int soldAmount;

  /// Image URLs extracted from the `image` array in the API response.
  final List<String> images;

  /// Variants from the `variant` array. Each has sale_price, stock, specs[].
  final List<ProductVariant> variants;

  /// Spec groups with children — loaded separately via /product/{productId}/spec
  /// when [hasSpec] is true.
  final List<ProductSpec> specs;

  final String intro;
  final List<String> tags;
  final String category;

  /// First category id from the API response. Used by `/upsell` (B9) which
  /// requires `category_id` to fetch matching add-on items.
  final int categoryId;

  /// Child items when this product is a bundle/combo — backend
  /// should populate this via the combo items sub-resource. Empty
  /// for regular products; drives the "組合商品內容" section on the
  /// detail screen.
  final List<ProductBundleItem> bundleItems;

  bool get inStock =>
      variants.any((v) => v.inStock || allowOversell);

  double get minSalePrice {
    if (variants.isEmpty) return 0;
    return variants.map((v) => v.salePrice).reduce((a, b) => a < b ? a : b);
  }

  double? get minOriginalPrice {
    final prices =
        variants.map((v) => v.originalPrice).whereType<double>().toList();
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  factory ProductCardDetail.fromJson(Map<String, dynamic> json) {
    final images = (json['image'] as List<dynamic>? ?? [])
        .map((e) => (e as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    // 2026-05 spec rev: `variant` renamed to `variants` on the resource.
    // Read the new key first; fall back to the legacy key so the client
    // copes with mixed backend versions during rollout.
    final variants = ((json['variants'] as List<dynamic>?) ??
            (json['variant'] as List<dynamic>?) ??
            const [])
        .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
        .toList();

    final specList = (json['spec'] as List<dynamic>? ?? [])
        .map((e) => ProductSpec.fromJson(e as Map<String, dynamic>))
        .toList();

    final detail = json['detail'] as Map<String, dynamic>? ?? {};
    final tags = (detail['tags'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    final categories = json['category'] as List<dynamic>? ?? [];
    final firstCategory =
        categories.isNotEmpty ? categories.first as Map<String, dynamic> : null;

    final bundleItems = (json['bundle_items'] as List<dynamic>? ??
            json['combo_items'] as List<dynamic>? ??
            const [])
        .map((e) => ProductBundleItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductCardDetail(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      storeId: json['store_id'] as int? ?? 0,
      marketId: json['market_id'] as int? ?? 0,
      type: json['type'] as int? ?? 2,
      name: json['name'] as String? ?? '',
      hasSpec: specList.isNotEmpty,
      allowOversell: json['allow_oversell'] as bool? ?? false,
      images: images,
      variants: variants,
      specs: specList,
      intro: detail['intro'] as String? ?? '',
      tags: tags,
      category: firstCategory?['name'] as String? ?? '',
      categoryId: (firstCategory?['id'] as num?)?.toInt() ?? 0,
      bundleItems: bundleItems,
      // Default `is_orderable` to true when missing so legacy responses
      // continue to render an enabled 加入購物車 button.
      isOrderable: json['is_orderable'] as bool? ?? true,
      soldAmount: (json['sold_amount'] as num?)?.toInt() ?? 0,
    );
  }

  ProductCardDetail copyWithSpecs(List<ProductSpec> specs) => ProductCardDetail(
        id: id,
        productId: productId,
        storeId: storeId,
        marketId: marketId,
        type: type,
        name: name,
        hasSpec: hasSpec,
        allowOversell: allowOversell,
        images: images,
        variants: variants,
        specs: specs,
        intro: intro,
        tags: tags,
        category: category,
        categoryId: categoryId,
        bundleItems: bundleItems,
        isOrderable: isOrderable,
        soldAmount: soldAmount,
      );
}

/// Lightweight model for `/upsell` results (B9). Backend returns
/// UpsellCampaignItemResource: id, name, detail{intro,...}, category[], image[].
class UpsellItem {
  const UpsellItem({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryName,
    this.intro = '',
  });

  final int id;
  final String name;
  final String image;
  final String categoryName;
  final String intro;

  factory UpsellItem.fromJson(Map<String, dynamic> json) {
    final images = json['image'] as List<dynamic>? ?? const [];
    final firstImage = images.isNotEmpty
        ? (images.first as Map<String, dynamic>)['url'] as String? ?? ''
        : '';
    final categories = json['category'] as List<dynamic>? ?? const [];
    final firstCategory = categories.isNotEmpty
        ? categories.first as Map<String, dynamic>
        : null;
    final detail = json['detail'] as Map<String, dynamic>? ?? const {};
    return UpsellItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      image: firstImage,
      categoryName: firstCategory?['name'] as String? ?? '',
      intro: detail['intro'] as String? ?? '',
    );
  }
}
