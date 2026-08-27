// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Purchase _$PurchaseFromJson(Map<String, dynamic> json) => _Purchase(
  id: (json['id'] as num).toInt(),
  createdAt: json['createdAt'] as String,
  itemCount: (json['itemCount'] as num).toInt(),
  amount: json['amount'] as num,
  paymentMethod: json['paymentMethod'] as String?,
  shippingMethod: json['shippingMethod'] as String?,
  mallType: json['mallType'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$PurchaseToJson(_Purchase instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt,
  'itemCount': instance.itemCount,
  'amount': instance.amount,
  'paymentMethod': instance.paymentMethod,
  'shippingMethod': instance.shippingMethod,
  'mallType': instance.mallType,
  'status': instance.status,
};

_PurchaseCollection _$PurchaseCollectionFromJson(Map<String, dynamic> json) =>
    _PurchaseCollection(
      data: (json['data'] as List<dynamic>)
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : PurchasePagination.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PurchaseCollectionToJson(_PurchaseCollection instance) =>
    <String, dynamic>{'data': instance.data, 'meta': instance.meta};

_PurchasePagination _$PurchasePaginationFromJson(Map<String, dynamic> json) =>
    _PurchasePagination(
      currentPage: json['currentPage'] as String,
      pageSize: json['pageSize'] as String,
      totalPages: json['totalPages'] as String,
      totalNumber: json['totalNumber'] as String,
    );

Map<String, dynamic> _$PurchasePaginationToJson(_PurchasePagination instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'totalNumber': instance.totalNumber,
    };

_PurchaseDetail _$PurchaseDetailFromJson(Map<String, dynamic> json) =>
    _PurchaseDetail(
      id: (json['id'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseDetailItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      shipment: json['shipment'] == null
          ? null
          : PurchaseShipment.fromJson(json['shipment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PurchaseDetailToJson(_PurchaseDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'items': instance.items,
      'shipment': instance.shipment,
    };

_PurchaseShipment _$PurchaseShipmentFromJson(Map<String, dynamic> json) =>
    _PurchaseShipment(
      deliveryType: json['deliveryType'] as String?,
      pickupProvider: json['pickupProvider'] as String?,
      shippingMethodId: (json['shippingMethodId'] as num?)?.toInt(),
      shippingMethodName: json['shippingMethodName'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      convenienceStoreCode: json['convenienceStoreCode'] as String?,
      trackingNo: json['trackingNo'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
    );

Map<String, dynamic> _$PurchaseShipmentToJson(_PurchaseShipment instance) =>
    <String, dynamic>{
      'deliveryType': instance.deliveryType,
      'pickupProvider': instance.pickupProvider,
      'shippingMethodId': instance.shippingMethodId,
      'shippingMethodName': instance.shippingMethodName,
      'recipientName': instance.recipientName,
      'recipientPhone': instance.recipientPhone,
      'recipientAddress': instance.recipientAddress,
      'convenienceStoreCode': instance.convenienceStoreCode,
      'trackingNo': instance.trackingNo,
      'trackingUrl': instance.trackingUrl,
    };

_PurchaseDetailItem _$PurchaseDetailItemFromJson(Map<String, dynamic> json) =>
    _PurchaseDetailItem(
      id: (json['id'] as num).toInt(),
      productName: json['productName'] as String?,
      variantName: json['variantName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      unitPrice: json['unitPrice'] as num?,
      quantity: (json['quantity'] as num).toInt(),
      fulfillments: (json['fulfillments'] as List<dynamic>)
          .map((e) => PurchaseFulfillment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PurchaseDetailItemToJson(_PurchaseDetailItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'variantName': instance.variantName,
      'imageUrl': instance.imageUrl,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'fulfillments': instance.fulfillments,
    };

_PurchaseFulfillment _$PurchaseFulfillmentFromJson(Map<String, dynamic> json) =>
    _PurchaseFulfillment(
      id: (json['id'] as num).toInt(),
      status: (json['status'] as num).toInt(),
      statusLabel: json['statusLabel'] as String,
      itemQuantity: json['itemQuantity'] as String,
      paidAt: json['paidAt'] as String?,
      shippedAt: json['shippedAt'] as String?,
      deliveredAt: json['deliveredAt'] as String?,
      completedAt: json['completedAt'] as String?,
    );

Map<String, dynamic> _$PurchaseFulfillmentToJson(
  _PurchaseFulfillment instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'statusLabel': instance.statusLabel,
  'itemQuantity': instance.itemQuantity,
  'paidAt': instance.paidAt,
  'shippedAt': instance.shippedAt,
  'deliveredAt': instance.deliveredAt,
  'completedAt': instance.completedAt,
};
