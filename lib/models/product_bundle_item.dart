/// Display model for a single item inside a product bundle (combo).
///
/// Rendered by the "組合商品內容" section at the bottom of the product
/// detail screen. Richer than [ComboItem] because UI needs the product
/// name, image, spec label and quantity directly — backend must expose
/// these fields alongside the raw variant id.
class ProductBundleItem {
  const ProductBundleItem({
    required this.variantId,
    required this.name,
    required this.imageUrl,
    required this.specLabel,
    required this.quantity,
  });

  final int variantId;
  final String name;
  final String imageUrl;

  /// e.g. "黑-S" — pre-joined spec value labels for display.
  final String specLabel;

  /// How many of this variant are included in the bundle.
  final int quantity;

  factory ProductBundleItem.fromJson(Map<String, dynamic> json) {
    final specs = json['specs'] as List<dynamic>? ?? const [];
    final specLabel = specs
        .map((e) => (e as Map<String, dynamic>)['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .join('-');
    return ProductBundleItem(
      variantId: json['product_variant_id'] as int? ??
          json['variant_id'] as int? ??
          0,
      name: json['name'] as String? ?? '',
      imageUrl: json['image'] as String? ?? json['image_url'] as String? ?? '',
      specLabel: json['spec_label'] as String? ?? specLabel,
      quantity: json['quantity'] as int? ?? json['portion'] as int? ?? 1,
    );
  }
}
