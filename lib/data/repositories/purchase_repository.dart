import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../models/purchase.dart';
import '../dio_client.dart';

class PurchaseRepository {
  PurchaseRepository(this._dioClient);

  final DioClient _dioClient;

  Future<PurchaseCollection> fetchPurchases({
    int page = 1,
    String? status,
    int? perPage,
    DateTime? startTime,
    DateTime? endTime,
    int? mallType,
    String? productName,
    String? sort,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.purchases,
        queryParameters: {
          'page': page,
          if (status != null && status.isNotEmpty) 'status': status,
          if (perPage != null) 'per_page': perPage,
          if (startTime != null) 'start_time': _formatDateTime(startTime),
          if (endTime != null) 'end_time': _formatDateTime(endTime),
          if (mallType != null) 'mall_type': mallType,
          if (productName != null && productName.isNotEmpty)
            'product_name': productName,
          if (sort != null && sort.isNotEmpty) 'sort': sort,
        },
      );

      final root = response.data as Map<String, dynamic>;
      final payload = _asMap(root['data']) ?? root;
      final list = (payload['data'] is List)
          ? payload['data'] as List<dynamic>
          : (root['data'] as List<dynamic>? ?? const <dynamic>[]);

      final items = list
          .whereType<Map<String, dynamic>>()
          .map(_mapPurchase)
          .toList();

      final metaMap = _asMap(payload['meta']) ?? _asMap(root['meta']);
      final pagination = _asMap(metaMap?['pagination']);
      final meta = pagination == null
          ? null
          : PurchasePagination(
              currentPage: _toText(pagination['current_page'], fallback: '1'),
              pageSize: _toText(pagination['page_size'], fallback: '10'),
              totalPages: _toText(pagination['total_pages'], fallback: '1'),
              totalNumber: _toText(pagination['total_number'], fallback: '0'),
            );

      return PurchaseCollection(data: items, meta: meta);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<PurchaseDetail> fetchPurchaseDetail(int id) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.purchase(id));
      final root = response.data as Map<String, dynamic>;
      final payload = _asMap(root['data']) ?? root;
      return _mapDetail(payload);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Purchase _mapPurchase(Map<String, dynamic> json) {
    return Purchase(
      id: _toInt(json['id']),
      createdAt: _toText(json['created_at'] ?? json['createdAt']),
      itemCount: _toInt(json['item_count'] ?? json['itemCount']),
      amount: _toNum(json['amount']),
      paymentMethod: _toNullableText(json['payment_method'] ?? json['paymentMethod']),
      shippingMethod:
          _toNullableText(json['shipping_method'] ?? json['shippingMethod']),
      mallType: _toNullableText(json['mall_type'] ?? json['mallType']),
      status: _toNullableText(json['status']),
    );
  }

  PurchaseDetail _mapDetail(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(_mapDetailItem)
        .toList();
    final fulfillment = _asMap(json['fulfillment']);
    return PurchaseDetail(
      id: _toInt(json['id']),
      items: items,
      shipment: fulfillment == null ? null : _mapShipment(fulfillment),
    );
  }

  /// Parses the order-level `fulfillment` block (2026-05 spec).
  PurchaseShipment _mapShipment(Map<String, dynamic> json) {
    return PurchaseShipment(
      deliveryType: _toNullableText(json['delivery_type']),
      pickupProvider: _toNullableText(json['pickup_provider']),
      shippingMethodId: json['shipping_method'] == null
          ? null
          : _toInt(json['shipping_method']),
      shippingMethodName: _toNullableText(json['shipping_method_name']),
      recipientName: _toNullableText(json['recipient_name']),
      recipientPhone: _toNullableText(json['recipient_phone']),
      recipientAddress: _toNullableText(json['recipient_address']),
      convenienceStoreCode: _toNullableText(json['convenience_store_code']),
      trackingNo: _toNullableText(json['tracking_no']),
      trackingUrl: _toNullableText(json['tracking_url']),
    );
  }

  PurchaseDetailItem _mapDetailItem(Map<String, dynamic> json) {
    final fulfillmentsRaw =
        json['fulfillments'] as List<dynamic>? ?? const <dynamic>[];
    final fulfillments = fulfillmentsRaw
        .whereType<Map<String, dynamic>>()
        .map(_mapFulfillment)
        .toList();
    return PurchaseDetailItem(
      id: _toInt(json['id']),
      productName: _toNullableText(json['product_name'] ?? json['productName']),
      variantName: _toNullableText(json['variant_name'] ?? json['variantName']),
      imageUrl: _toNullableText(json['image_url'] ?? json['imageUrl']),
      unitPrice: json['unit_price'] == null && json['unitPrice'] == null
          ? null
          : _toNum(json['unit_price'] ?? json['unitPrice']),
      quantity: _toInt(json['quantity']),
      fulfillments: fulfillments,
    );
  }

  PurchaseFulfillment _mapFulfillment(Map<String, dynamic> json) {
    return PurchaseFulfillment(
      id: _toInt(json['id']),
      status: _toInt(json['status']),
      statusLabel: _toText(json['status_label'] ?? json['statusLabel']),
      itemQuantity: _toText(json['item_quantity'] ?? json['itemQuantity']),
      paidAt: _toNullableText(json['paid_at'] ?? json['paidAt']),
      shippedAt: _toNullableText(json['shipped_at'] ?? json['shippedAt']),
      deliveredAt: _toNullableText(json['delivered_at'] ?? json['deliveredAt']),
      completedAt: _toNullableText(json['completed_at'] ?? json['completedAt']),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static num _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _toText(dynamic value, {String fallback = ''}) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return fallback;
    return text;
  }

  static String? _toNullableText(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  /// Backend expects `Y-m-d H:i:s` (local time) per Laravel validation rule.
  static String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    final local = dt.toLocal();
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
