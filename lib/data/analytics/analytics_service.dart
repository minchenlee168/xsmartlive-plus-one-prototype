import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../config/flavor_config.dart';
import '../../models/cart_api.dart';
import '../../models/product.dart';

/// Flips to `true` once [Firebase.initializeApp] succeeds.
///
/// Until a merchant's `google-services.json` / `GoogleService-Info.plist` is
/// present the init throws, this stays `false`, and every GA4 call becomes a
/// no-op — the app still runs and Meta (Facebook) events still fire (the FB
/// SDK is already configured for login). GA lights up the moment the config
/// files exist, with no code change.
bool firebaseAnalyticsReady = false;

/// Currency for all monetary events. Centralised so it can later be derived
/// per-flavor if a merchant trades in a different currency.
const String kAnalyticsCurrency = 'TWD';

/// Brings GA4 online if it can. Safe to call unconditionally from every flavor
/// entry point — failure (no Firebase config yet) is swallowed and logged.
Future<void> initAnalytics() async {
  try {
    await Firebase.initializeApp();
    firebaseAnalyticsReady = true;
    // User property → every GA event is attributable to its merchant even
    // while all flavors still share one Firebase/GA project.
    await FirebaseAnalytics.instance.setUserProperty(
      name: 'merchant_id',
      value: FlavorConfig.instance.merchantId,
    );
  } catch (e) {
    firebaseAnalyticsReady = false;
    debugPrint('[analytics] GA4 disabled — Firebase not configured yet: $e');
  }
}

/// Unified analytics façade: one call fans out to **GA4** (Firebase Analytics)
/// and **Meta** (Facebook App Events) so the two never drift apart.
///
/// All sends are wrapped in [_safe]; a misbehaving SDK can never crash a user
/// flow. GA calls short-circuit when [firebaseAnalyticsReady] is `false`.
class AnalyticsService {
  AnalyticsService() : _fb = FacebookAppEvents();

  final FacebookAppEvents _fb;

  FirebaseAnalytics? get _ga =>
      firebaseAnalyticsReady ? FirebaseAnalytics.instance : null;

  String get _merchantId => FlavorConfig.instance.merchantId;

  // ── Meta standard event names / parameter keys ──
  static const _fbAddToCart = 'fb_mobile_add_to_cart';
  static const _fbViewContent = 'fb_mobile_content_view';
  static const _fbContentId = 'fb_content_id';
  static const _fbContentType = 'fb_content_type';
  static const _fbCurrency = 'fb_currency';
  static const _fbNumItems = 'fb_num_items';

  /// Wraps every send so an SDK error is logged, never thrown.
  Future<void> _safe(Future<void> Function() body) async {
    try {
      await body();
    } catch (e) {
      debugPrint('[analytics] event failed: $e');
    }
  }

  Map<String, Object> _ga4(Map<String, Object> params) =>
      {'merchant_id': _merchantId, ...params};

  // 1. 首頁
  Future<void> logHomeView() => _safe(() async {
        await _ga?.logScreenView(
          screenName: 'home',
          screenClass: 'HomeScreen',
        );
        await _fb.logEvent(
          name: 'Home',
          parameters: {'merchant_id': _merchantId},
        );
      });

  // 2. 觀看直播
  Future<void> logViewLive({required String streamId, String? title}) =>
      _safe(() async {
        await _ga?.logEvent(
          name: 'view_live',
          parameters: _ga4({
            'stream_id': streamId,
            if (title != null) 'item_name': title,
          }),
        );
        await _fb.logEvent(
          name: 'WatchLive',
          parameters: {
            'stream_id': streamId,
            'merchant_id': _merchantId,
            if (title != null) 'title': title,
          },
        );
      });

  // 3. 瀏覽商品內頁
  Future<void> logViewItem({
    required String itemId,
    String? name,
    double? price,
  }) =>
      _safe(() async {
        await _ga?.logEvent(
          name: 'view_item',
          parameters: _ga4({
            'currency': kAnalyticsCurrency,
            'item_id': itemId,
            if (name != null) 'item_name': name,
            if (price != null) 'value': price,
          }),
        );
        await _fb.logEvent(
          name: _fbViewContent,
          valueToSum: price,
          parameters: {
            _fbContentId: itemId,
            _fbContentType: 'product',
            _fbCurrency: kAnalyticsCurrency,
            'merchant_id': _merchantId,
          },
        );
      });

  // 4. 加入購物車
  Future<void> logAddToCart({
    required String itemId,
    String? name,
    double? price,
    int quantity = 1,
  }) =>
      _safe(() async {
        final value = (price ?? 0) * quantity;
        await _ga?.logEvent(
          name: 'add_to_cart',
          parameters: _ga4({
            'currency': kAnalyticsCurrency,
            'item_id': itemId,
            'quantity': quantity,
            'value': value,
            if (name != null) 'item_name': name,
          }),
        );
        await _fb.logEvent(
          name: _fbAddToCart,
          valueToSum: value,
          parameters: {
            _fbContentId: itemId,
            _fbContentType: 'product',
            _fbCurrency: kAnalyticsCurrency,
            _fbNumItems: quantity,
            'merchant_id': _merchantId,
          },
        );
      });

  /// Convenience overload from a [Product] model (the common case).
  Future<void> logAddToCartProduct(Product p, {int quantity = 1}) =>
      logAddToCart(
        itemId: p.id,
        name: p.name,
        price: p.price,
        quantity: quantity,
      );

  // 5. 進入購物車
  Future<void> logViewCart(CartApi? cart) => _safe(() async {
        final value = cart?.total ?? 0;
        final numItems = cart?.skuCount ?? 0;
        await _ga?.logEvent(
          name: 'view_cart',
          parameters: _ga4({
            'currency': kAnalyticsCurrency,
            'value': value,
            'num_items': numItems,
          }),
        );
        await _fb.logEvent(
          name: 'ViewCart',
          valueToSum: value.toDouble(),
          parameters: {
            _fbCurrency: kAnalyticsCurrency,
            _fbNumItems: numItems,
            'merchant_id': _merchantId,
          },
        );
      });

  // 6. 完成結帳
  Future<void> logPurchase({
    required CartApi cart,
    required String transactionId,
  }) =>
      _safe(() async {
        final value = cart.total;
        final itemIds = cart.items.map((e) => e.productId ?? e.id).join(',');
        await _ga?.logEvent(
          name: 'purchase',
          parameters: _ga4({
            'transaction_id': transactionId,
            'currency': kAnalyticsCurrency,
            'value': value,
            'num_items': cart.skuCount,
          }),
        );
        await _fb.logPurchase(
          amount: value.toDouble(),
          currency: kAnalyticsCurrency,
          parameters: {
            _fbContentType: 'product',
            _fbContentId: itemIds,
            _fbNumItems: cart.skuCount,
            'transaction_id': transactionId,
            'merchant_id': _merchantId,
          },
        );
      });
}
