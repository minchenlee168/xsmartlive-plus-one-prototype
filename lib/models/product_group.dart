class ProductGroup {
  const ProductGroup({
    required this.id,
    required this.name,
    this.children = const [],
    this.isAttached = false,
  });

  final String id;
  final String name;
  final List<ProductGroup> children;

  /// 2026-05 spec rev (`StoreCategoryListResource.is_attached`) — only
  /// returned by the product `show` API. When true the current product is
  /// directly attached to this category leaf; when false it's a branch /
  /// sub-tree node carried for navigation. Defaults to false on the
  /// category-tree endpoint where the flag isn't included.
  final bool isAttached;

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    final childList = json['child'] as List<dynamic>? ?? [];
    return ProductGroup(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      children: childList
          .map((e) => ProductGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAttached: json['is_attached'] as bool? ?? false,
    );
  }
}
