// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartApi _$CartApiFromJson(Map<String, dynamic> json) => _CartApi(
  id: (json['id'] as num).toInt(),
  skuCount: (json['sku_count'] as num).toInt(),
  subtotal: (json['subtotal'] as num).toDouble(),
  discount: (json['discount'] as num).toDouble(),
  total: (json['total'] as num).toDouble(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartApiItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  canAbandon: json['can_abandon'] as bool? ?? true,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$CartApiToJson(_CartApi instance) => <String, dynamic>{
  'id': instance.id,
  'sku_count': instance.skuCount,
  'subtotal': instance.subtotal,
  'discount': instance.discount,
  'total': instance.total,
  'items': instance.items,
  'can_abandon': instance.canAbandon,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

_CartApiItem _$CartApiItemFromJson(Map<String, dynamic> json) => _CartApiItem(
  id: (json['id'] as num).toInt(),
  cartId: (json['cart_id'] as num).toInt(),
  bidId: (json['bid_id'] as num?)?.toInt(),
  productId: (json['product_id'] as num?)?.toInt(),
  productVariantId: (json['product_variant_id'] as num?)?.toInt(),
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unit_price'] as num).toInt(),
  image: json['image'] as String?,
  product: CartApiProduct.fromJson(
    _readProduct(json, 'product') as Map<String, dynamic>,
  ),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$CartApiItemToJson(_CartApiItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cart_id': instance.cartId,
      'bid_id': instance.bidId,
      'product_id': instance.productId,
      'product_variant_id': instance.productVariantId,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'image': instance.image,
      'product': instance.product,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_CartApiProduct _$CartApiProductFromJson(Map<String, dynamic> json) =>
    _CartApiProduct(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CartApiProductToJson(_CartApiProduct instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
