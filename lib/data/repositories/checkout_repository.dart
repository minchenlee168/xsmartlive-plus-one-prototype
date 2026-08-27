import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../models/address.dart' show CartDeliveryType;
import '../../models/applied_coupon.dart';
import '../../models/checkout_task.dart';
import '../../models/store_checkout_setting.dart';
import '../dio_client.dart';

class CheckoutRepository {
  CheckoutRepository(this._dioClient);

  final DioClient _dioClient;

  /// 預覽結帳金額（含折扣計算）。
  ///
  /// 注意：2026-04 規格已移除 `member_coupon_id` 欄位，優惠券改由
  /// [applyCoupon] 先綁定到購物車，preview / confirm 會自動沿用。
  ///
  /// 2026-05 spec rev — request body accepts 3 optional probe fields so the
  /// backend can return a non-zero `shipping_fee` *before* confirm:
  ///   • `address_id`        — chosen home / pickup address (id only).
  ///   • `delivery_type`     — `home` / `pickup` toggle.
  ///   • `payment_method_id` — selected payment row (probes per-method fees).
  /// When omitted the backend falls back to the member's default address +
  /// `home` + `online_payment`, and surfaces the deferral reason via the
  /// new top-level `shipping_fee_reason` field on the response.
  Future<Map<String, dynamic>> preview({
    required List<int> cartIds,
    required List<int> cartItemIds,
    int? addressId,
    String? deliveryType,
    int? paymentMethodId,
  }) async {
    assert(
      deliveryType == null || deliveryType == 'home' || deliveryType == 'pickup',
      'deliveryType must be "home", "pickup" or null',
    );
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.checkoutPreview,
        data: {
          'cart_ids': cartIds,
          'cart_item_ids': cartItemIds,
          if (addressId != null) 'address_id': addressId,
          if (deliveryType != null) 'delivery_type': deliveryType,
          if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// 確認下單。Controller 會建立 task 並 dispatch job，
  /// 回傳 [CheckoutTask]，呼叫端須以 [fetchCheckoutTask] 輪詢直到 terminal。
  ///
  /// **2026-05 spec rev:** body shape changed.
  ///   - Removed: `store_shipping_method_id`, `recipient_name`,
  ///     `recipient_phone`, `recipient_address`, `convenience_store_code`.
  ///   - Added: `delivery_type` (`home`/`pickup`),
  ///     `member_shipping_address_id` (when home),
  ///     `member_store_pickup_address_id` (when pickup).
  ///
  /// Backend now reads recipient/address from the member address book row
  /// referenced by the supplied id, so the App must persist a chosen home /
  /// pickup address before calling confirm.
  Future<CheckoutTask> confirm({
    required String requestId,
    required int storePaymentMethodId,
    required String deliveryType,
    required String snapshotUrl,
    required List<int> cartIds,
    required List<int> cartItemIds,
    required int invoiceType,
    int? memberShippingAddressId,
    int? memberStorePickupAddressId,
    int? memberCouponId,
    int? bonusAmount,
    String? buyerTaxId,
    String? buyerName,
    int? carrierType,
    String? carrierId,
    String? donateOrgCode,
    String? note,
  }) async {
    assert(
      deliveryType == 'home' || deliveryType == 'pickup',
      'deliveryType must be "home" or "pickup"',
    );
    assert(
      deliveryType != 'home' || memberShippingAddressId != null,
      'home delivery requires a memberShippingAddressId',
    );
    assert(
      deliveryType != 'pickup' || memberStorePickupAddressId != null,
      'pickup delivery requires a memberStorePickupAddressId',
    );

    try {
      final response = await _dioClient.dio.post(
        ApiConstants.checkoutConfirm,
        data: {
          'request_id': requestId,
          'store_payment_method_id': storePaymentMethodId,
          'delivery_type': deliveryType,
          'snapshot_url': snapshotUrl,
          'invoice_type': invoiceType,
          'cart_ids': cartIds,
          'cart_item_ids': cartItemIds,
          if (memberShippingAddressId != null)
            'member_shipping_address_id': memberShippingAddressId,
          if (memberStorePickupAddressId != null)
            'member_store_pickup_address_id': memberStorePickupAddressId,
          if (memberCouponId != null) 'member_coupon_id': memberCouponId,
          if (bonusAmount != null) 'bonus_amount': bonusAmount,
          if (buyerTaxId != null) 'buyer_tax_id': buyerTaxId,
          if (buyerName != null) 'buyer_name': buyerName,
          if (carrierType != null) 'carrier_type': carrierType,
          if (carrierId != null) 'carrier_id': carrierId,
          if (donateOrgCode != null) 'donate_org_code': donateOrgCode,
          if (note != null) 'note': note,
        },
      );
      return _parseTask(response.data);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// GET /cart/checkout/shippingOptions — returns the top-level delivery
  /// types (home / pickup) plus, for pickup, the brand list (7-11/全家)
  /// the merchant has activated. Tolerates either `{ delivery_types: [...] }`
  /// or a bare `[...]` envelope.
  Future<List<CartDeliveryType>> fetchShippingOptions() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.checkoutShippingOptions,
      );
      final body = response.data;
      final list = body is List
          ? body
          : (body is Map<String, dynamic>
              ? (body['delivery_types'] as List<dynamic>? ??
                  body['data'] as List<dynamic>? ??
                  const [])
              : const []);
      return list
          .whereType<Map<String, dynamic>>()
          .map(CartDeliveryType.fromJson)
          .toList();
    } on DioException {
      return [];
    }
  }

  /// 套用優惠碼至目前 cart 選取項目並回傳折抵預覽。
  ///
  /// 後端會：
  ///   1. 依 coupon_code 找到對應的 Coupon（store 限定）
  ///   2. 幫當前會員領取該優惠券（已領取時冪等處理）
  ///   3. 試算本次勾選內容的折抵，回傳 [AppliedCoupon]
  Future<AppliedCoupon> applyCoupon({
    required String couponCode,
    required List<int> cartIds,
    required List<int> cartItemIds,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.checkoutCouponApply,
        data: {
          'coupon_code': couponCode,
          'cart_ids': cartIds,
          'cart_item_ids': cartItemIds,
        },
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ServerException('Invalid coupon apply response');
      }
      final data = body['data'] ?? body;
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Invalid coupon apply response');
      }
      return AppliedCoupon.fromJson(data);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// 查詢結帳任務狀態 — GET /cart/checkout/task/{requestId}。
  Future<CheckoutTask> fetchCheckoutTask(String requestId) async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.checkoutTask(requestId),
      );
      return _parseTask(response.data);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  CheckoutTask _parseTask(dynamic body) {
    if (body is! Map<String, dynamic>) {
      throw const ServerException('Invalid checkout task response');
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const ServerException('Invalid checkout task response');
    }
    return CheckoutTask.fromJson(data);
  }

  /// 取得商家結帳設定（自選模式 / 合併結帳 / 棄標 / 結帳扣庫存 / 結帳時限）。
  /// GET /v1/mall/store/{id}/storeCheckoutSetting → StoreCheckoutSettingResource
  Future<StoreCheckoutSetting> fetchStoreCheckoutSetting() async {
    try {
      final response = await _dioClient.dio.get(
        ApiConstants.storeCheckoutSetting,
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ServerException('Invalid checkout setting response');
      }
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Invalid checkout setting response');
      }
      return StoreCheckoutSetting.fromJson(data);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }
}
