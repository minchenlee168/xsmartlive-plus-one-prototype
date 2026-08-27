class ProductSpec {
  const ProductSpec({
    required this.id,
    required this.name,
    this.values = const [],
  });

  final int id;
  final String name;
  final List<ProductSpecValue> values;

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    final valueList = json['child'] as List<dynamic>? ?? [];
    return ProductSpec(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      values: valueList
          .map((e) => ProductSpecValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductSpecValue {
  const ProductSpecValue({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory ProductSpecValue.fromJson(Map<String, dynamic> json) =>
      ProductSpecValue(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );
}
