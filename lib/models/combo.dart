class Combo {
  const Combo({
    required this.id,
    required this.name,
    this.intro,
    this.note,
    this.keyword,
    this.weight,
    this.cost,
    this.originalPrice,
    this.salePrice,
    this.stock,
    this.status,
    this.tags = const [],
    this.category = const [],
    this.images = const [],
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String? intro;
  final String? note;
  final String? keyword;
  final double? weight;
  final double? cost;
  final double? originalPrice;
  final double? salePrice;
  final int? stock;
  final int? status;
  final List<String> tags;
  final List<ComboCategory> category;
  final List<ComboImage> images;
  final List<ComboItem> items;
  final String? createdAt;
  final String? updatedAt;

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      intro: json['intro'] as String?,
      note: json['note'] as String?,
      keyword: json['keyword'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      cost: (json['cost'] as num?)?.toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      stock: json['stock'] as int?,
      status: json['status'] as int?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: (json['category'] as List<dynamic>?)
              ?.map((e) => ComboCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      images: (json['image'] as List<dynamic>?)
              ?.map((e) => ComboImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ComboItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class ComboCategory {
  const ComboCategory({required this.id, required this.name});

  final int id;
  final String name;

  factory ComboCategory.fromJson(Map<String, dynamic> json) => ComboCategory(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );
}

class ComboImage {
  const ComboImage({required this.id, required this.url, this.sequence});

  final int id;
  final String url;
  final int? sequence;

  factory ComboImage.fromJson(Map<String, dynamic> json) => ComboImage(
        id: json['id'] as int? ?? 0,
        url: json['url'] as String? ?? '',
        sequence: json['sequence'] as int?,
      );
}

class ComboItem {
  const ComboItem({
    required this.productVariantId,
    required this.portion,
  });

  final int productVariantId;
  final int portion;

  factory ComboItem.fromJson(Map<String, dynamic> json) => ComboItem(
        productVariantId: json['product_variant_id'] as int? ?? 0,
        portion: json['portion'] as int? ?? 1,
      );
}
