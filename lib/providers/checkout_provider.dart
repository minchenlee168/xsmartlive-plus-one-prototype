import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/flavor_config.dart';
import '../core/errors/app_exception.dart';
import '../models/address.dart';
import '../models/applied_coupon.dart';
import '../models/cart_api.dart';
import '../models/checkout_task.dart';
import '../models/store_checkout_setting.dart';
import 'address_provider.dart';
import 'analytics_provider.dart';
import 'product_provider.dart';
import 'repository_providers.dart';

/// 預設發票類型 (2=個人電子發票/三聯，常見預設)。等發票選擇 UI 完成後再覆寫。
const int _defaultInvoiceType = 2;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// 2026-05 spec rev: confirm body now uses `delivery_type` + a member
/// address id, not `store_shipping_method_id`. The state tracks the chosen
/// type plus the optional pickup brand the customer selected.
class CheckoutState {
  const CheckoutState({
    this.deliveryType = 'home',
    this.pickupBrand,
    this.paymentMethodId = 1,
    this.isSubmitting = false,
    this.errorMessage,
    this.orderCreated = false,
    this.task,
    this.appliedCoupon,
  });

  /// `home` (宅配) or `pickup` (超商取貨).
  final String deliveryType;

  /// Brand string when [deliveryType] == `pickup` (e.g. "7-11", "全家").
  /// `null` for home delivery.
  final String? pickupBrand;

  final int paymentMethodId;
  final bool isSubmitting;
  final String? errorMessage;
  final bool orderCreated;
  final CheckoutTask? task;
  final AppliedCoupon? appliedCoupon;

  CheckoutState copyWith({
    String? deliveryType,
    String? pickupBrand,
    bool clearPickupBrand = false,
    int? paymentMethodId,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? orderCreated,
    CheckoutTask? task,
    bool clearTask = false,
    AppliedCoupon? appliedCoupon,
    bool clearCoupon = false,
  }) {
    return CheckoutState(
      deliveryType: deliveryType ?? this.deliveryType,
      pickupBrand:
          clearPickupBrand ? null : (pickupBrand ?? this.pickupBrand),
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      orderCreated: orderCreated ?? this.orderCreated,
      task: clearTask ? null : (task ?? this.task),
      appliedCoupon:
          clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
    );
  }
}

// ---------------------------------------------------------------------------
// ViewModel
// ---------------------------------------------------------------------------
class CheckoutNotifier extends AutoDisposeNotifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  /// Switch the top-level delivery type. Picking `home` always clears the
  /// pickup brand because brand is meaningless for home delivery.
  void changeDeliveryType(String code) {
    if (code != 'home' && code != 'pickup') return;
    state = state.copyWith(
      deliveryType: code,
      clearPickupBrand: code == 'home',
      clearError: true,
    );
  }

  /// Pick the pickup brand (e.g. "7-11", "全家"). No-op when delivery type
  /// is not `pickup`.
  void changePickupBrand(String? brand) {
    if (state.deliveryType != 'pickup') return;
    state = state.copyWith(
      pickupBrand: brand,
      clearPickupBrand: brand == null,
      clearError: true,
    );
  }

  void changePayment(int id) =>
      state = state.copyWith(paymentMethodId: id, clearError: true);

  void clearError() => state = state.copyWith(clearError: true);

  void clearCoupon() => state = state.copyWith(clearCoupon: true);

  /// Apply a coupon code against the current cart selection.
  ///
  /// Server-side this also claims the coupon for the member (idempotent).
  /// On success the [AppliedCoupon] is stored in state and the
  /// `checkoutPreviewProvider` is invalidated so the preview re-fetches with
  /// the discount baked in.
  Future<void> applyCouponCode(CartApi cart, String code) async {
    if (code.trim().isEmpty) return;
    state = state.copyWith(clearError: true);
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final applied = await repo.applyCoupon(
        couponCode: code.trim(),
        cartIds: [cart.id],
        cartItemIds: cart.items.map((e) => e.id).toList(),
      );
      state = state.copyWith(appliedCoupon: applied, clearError: true);
      ref.invalidate(checkoutPreviewProvider);
    } catch (e) {
      state = state.copyWith(errorMessage: '$e');
    }
  }

  Future<void> confirmOrder(CartApi cart) async {
    if (state.isSubmitting) return;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearTask: true,
    );
    try {
      final addressIds = _resolveAddressIds();
      final requestId = _generateRequestId();
      final repo = ref.read(checkoutRepositoryProvider);
      var task = await repo.confirm(
        requestId: requestId,
        storePaymentMethodId: state.paymentMethodId,
        deliveryType: state.deliveryType,
        snapshotUrl: _buildSnapshotUrl(cart, requestId),
        cartIds: [cart.id],
        cartItemIds: cart.items.map((e) => e.id).toList(),
        invoiceType: _defaultInvoiceType,
        memberShippingAddressId: addressIds.homeId,
        memberStorePickupAddressId: addressIds.pickupId,
        memberCouponId: state.appliedCoupon?.memberCouponId,
      );

      task = await _pollUntilTerminal(repo.fetchCheckoutTask, task);

      ref.invalidate(cartApiProvider);

      if (task.status == CheckoutTaskStatus.succeeded) {
        // Event #6 (完成結帳) — fire once on confirmed order.
        ref.read(analyticsServiceProvider).logPurchase(
              cart: cart,
              transactionId: task.requestId,
            );
        state = state.copyWith(
          isSubmitting: false,
          orderCreated: true,
          task: task,
        );
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: task.errorMessage ?? 'checkout_task_${task.status.name}',
          task: task,
        );
      }
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: '$e');
    }
  }

  /// Resolve the address-book id required by the new confirm body.
  ///
  /// 2026-05 spec: backend reads recipient name/phone/address from the
  /// member's address-book row keyed by id, so we only forward the id —
  /// no `recipient_name`/`recipient_phone` payload anymore. Surfaces a
  /// friendly error when the customer has not yet saved a matching address.
  ({int? homeId, int? pickupId}) _resolveAddressIds() {
    if (state.deliveryType == 'home') {
      final HomeDeliveryAddress? home =
          ref.read(defaultHomeDeliveryAddressProvider);
      if (home == null) throw const ServerException('請先新增宅配收件地址');
      return (homeId: home.id, pickupId: null);
    }
    final StorePickupAddress? pickup =
        ref.read(defaultStorePickupAddressProvider);
    if (pickup == null) throw const ServerException('請先新增超商取貨門市');
    return (homeId: null, pickupId: pickup.id);
  }

  Future<CheckoutTask> _pollUntilTerminal(
    Future<CheckoutTask> Function(String) fetch,
    CheckoutTask initial, {
    Duration interval = const Duration(seconds: 1),
    int maxAttempts = 30,
  }) async {
    var current = initial;
    var attempts = 0;
    while (!current.status.isTerminal && attempts < maxAttempts) {
      await Future<void>.delayed(interval);
      current = await fetch(current.requestId);
      attempts++;
    }
    return current;
  }

  String _generateRequestId() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = (ts ^ identityHashCode(this)).toRadixString(36);
    return 'mall-$ts-$rand';
  }

  /// 產生 cart snapshot URL — 後端以字串紀錄做為爭議處理佐證，
  /// 不會發出 request，因此此處組出一組含 cart / request_id 的可識別 URL。
  String _buildSnapshotUrl(CartApi cart, String requestId) {
    final base = FlavorConfig.instance.baseUrl.replaceAll(RegExp(r'/$'), '');
    final merchantId = FlavorConfig.instance.merchantId;
    return '$base/app-snapshot/$merchantId/cart/${cart.id}/$requestId';
  }
}

final checkoutProvider =
    AutoDisposeNotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);

// ---------------------------------------------------------------------------
// Preview provider (autoDispose — 離開畫面即釋放)
//
// Watches [checkoutProvider] so changes to delivery type / pickup brand /
// payment method automatically re-fetch the preview with the new probe
// values. Also pipes through the chosen address id so the backend can
// return an accurate shipping_fee instead of deferring to the default.
// ---------------------------------------------------------------------------
final checkoutPreviewProvider =
    FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final cart = ref.watch(cartApiProvider).valueOrNull;
  if (cart == null || cart.items.isEmpty) return null;
  final checkout = ref.watch(checkoutProvider);
  int? addressId;
  if (checkout.deliveryType == 'home') {
    addressId = ref.watch(defaultHomeDeliveryAddressProvider)?.id;
  } else if (checkout.deliveryType == 'pickup') {
    addressId = ref.watch(defaultStorePickupAddressProvider)?.id;
  }
  return ref.read(checkoutRepositoryProvider).preview(
        cartIds: [cart.id],
        cartItemIds: cart.items.map((e) => e.id).toList(),
        addressId: addressId,
        deliveryType: checkout.deliveryType,
        paymentMethodId: checkout.paymentMethodId,
      );
});

// ---------------------------------------------------------------------------
// Store checkout setting — keepAlive cached, single fetch per session.
// Drives checkout-time UX flags: enable_custom_mode / enable_merge_checkout
// / enable_member_abandon / deduct_stock_on_checkout / checkout_limit (mins).
// ---------------------------------------------------------------------------
final storeCheckoutSettingProvider =
    FutureProvider<StoreCheckoutSetting>((ref) async {
  return ref.read(checkoutRepositoryProvider).fetchStoreCheckoutSetting();
});

/// Top-level delivery types (home / pickup) + brand list per type, fetched
/// from the new `/cart/checkout/shippingOptions` endpoint (2026-05 spec).
/// Auto-disposes when the checkout screen leaves the route stack.
final checkoutShippingOptionsProvider =
    FutureProvider.autoDispose<List<CartDeliveryType>>((ref) async {
  return ref.read(checkoutRepositoryProvider).fetchShippingOptions();
});
