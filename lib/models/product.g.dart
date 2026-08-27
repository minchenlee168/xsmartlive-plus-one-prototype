// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  image: json['image'] as String,
  category: json['category'] as String,
  originalPrice: (json['originalPrice'] as num?)?.toDouble(),
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  sales: (json['sales'] as num?)?.toInt() ?? 0,
  isHot: json['isHot'] as bool? ?? false,
  inStock: json['inStock'] as bool? ?? true,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'image': instance.image,
  'category': instance.category,
  'originalPrice': instance.originalPrice,
  'rating': instance.rating,
  'sales': instance.sales,
  'isHot': instance.isHot,
  'inStock': instance.inStock,
};

_FavoriteProduct _$FavoriteProductFromJson(Map<String, dynamic> json) =>
    _FavoriteProduct(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      streamer: json['streamer'] as String,
    );

Map<String, dynamic> _$FavoriteProductToJson(_FavoriteProduct instance) =>
    <String, dynamic>{
      'product': instance.product,
      'streamer': instance.streamer,
    };
