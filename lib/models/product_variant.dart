class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.salePrice,
    required this.stock,
    this.originalPrice,
    this.specs = const [],
    this.productCardId,
    this.keyword,
    this.soldQuantity,
  });

  final int id;
  final double salePrice;
  final int stock;
  final double? originalPrice;
  final List<Map<String, dynamic>> specs;
  final int? productCardId;

  /// Concatenated spec names with " / " — backend now derives this from
  /// the linked productSpec rows so the client can render variant titles
  /// without re-joining specs[] itself. Optional for legacy responses.
  final String? keyword;

  /// Live sold quantity (success orders + pending reservations). Surfaced
  /// on the variant for live-stream "X 件已被搶" badges. Null on legacy
  /// payloads — treat as 0 if you need to render it.
  final int? soldQuantity;

  bool get inStock => stock > 0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final specList = json['specs'] as List<dynamic>? ?? [];
    return ProductVariant(
      id: json['id'] as int? ?? 0,
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      specs: specList.map((e) => e as Map<String, dynamic>).toList(),
      productCardId: json['product_card_id'] as int?,
      keyword: json['keyword'] as String?,
      soldQuantity: (json['sold_quantity'] as num?)?.toInt(),
    );
  }
}
