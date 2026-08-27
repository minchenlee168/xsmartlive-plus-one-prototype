import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    required String image,
    required String category,
    double? originalPrice,
    @Default(0.0) double rating,
    @Default(0) int sales,
    @Default(false) bool isHot,
    @Default(true) bool inStock,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@freezed
abstract class CartItem with _$CartItem {
  const factory CartItem({
    required Product product,
    @Default(1) int quantity,
  }) = _CartItem;
}

@freezed
abstract class FavoriteProduct with _$FavoriteProduct {
  const factory FavoriteProduct({
    required Product product,
    required String streamer,
  }) = _FavoriteProduct;

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) =>
      _$FavoriteProductFromJson(json);
}
