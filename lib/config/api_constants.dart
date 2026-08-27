import 'flavor_config.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl => FlavorConfig.instance.baseUrl;
  static String get merchantId => FlavorConfig.instance.merchantId;

  static String get _api => '$baseUrl/api';
  static String get _store => '$_api/v1/mall/store/$merchantId';

  // ── Common ────────────────────────────────────────────────────────────────
  static String get captcha => '$_api/v1/common/captcha';
  static String get sendSms => '$_api/v1/common/sms';

  // ── Mall Auth ──────────────────────────────────────────────────────────────
  static String get mallLogin           => '$_api/v1/mall/auth/login';
  static String get mallRegister        => '$_api/v1/mall/auth/register';
  static String get mallSendRegisterOtp => '$_api/v1/mall/auth/sendRegisterOtp';
  static String get mallLogout          => '$_api/v1/mall/auth/logout';
  static String get mallIsLogin => '$_api/v1/mall/auth/isLogin';
  // Note: refresh not in API doc; kept for token-refresh interceptor.
  static String get mallRefreshToken => '$_api/v1/mall/auth/refresh';

  // ── Mall Auth — 2026-05 new endpoints ──────────────────────────────────────
  // POST /v1/mall/auth/isRegistered — check whether a third-party identity
  // (FB ASID / FB PSID / Google sub) is already linked to an account so the
  // social-login UI can branch login vs. register without a 422 round-trip.
  static String get mallIsRegistered => '$_api/v1/mall/auth/isRegistered';

  // ── Bid Redirect (FB ASID binding flow) ──────────────────────────────────
  // POST /v1/mall/bid-redirect/resolve  body: { token }
  // POST /v1/mall/bid-redirect/bind     body: { token, fb_access_token }
  static String get mallBidRedirectResolve =>
      '$_api/v1/mall/bid-redirect/resolve';
  static String get mallBidRedirectBind =>
      '$_api/v1/mall/bid-redirect/bind';

  // ── Store Profile ──────────────────────────────────────────────────────────
  static String storeProfile(String storeId) =>
      '$_api/v1/mall/store/$storeId/profile';

  // ── App Setting (not in API doc; kept for compatibility) ──────────────────
  static String get appSetting => '$_api/v1/mall/app/setting';

  // ── Theme (not in API doc; kept for compatibility) ────────────────────────
  static String theme(String id) => '$baseUrl/theme/$id';

  // ── Member Profile ─────────────────────────────────────────────────────────
  static String get me => '$_store/me';
  static String get meUpdate => '$_store/me/update';
  // Change mobile flow (request OTP → confirm with OTP)
  // POST /v1/mall/store/{store}/me/changeMobile/request body: { country, mobile }
  // POST /v1/mall/store/{store}/me/changeMobile/confirm body: { country, mobile, otp }
  static String get meChangeMobileRequest =>
      '$_store/me/changeMobile/request';
  static String get meChangeMobileConfirm =>
      '$_store/me/changeMobile/confirm';

  // ── Bind mobile (B4) — initial bind for accounts without a mobile yet
  //    (e.g. social-login users). Different from changeMobile which assumes
  //    a mobile is already bound.
  // POST /me/bindMobile body: { country, mobile, captcha? }   → sends OTP
  // POST /me/verifyOtp   body: { country, mobile, otp }       → confirms bind
  static String get meBindMobile => '$_store/me/bindMobile';
  static String get meVerifyOtp => '$_store/me/verifyOtp';

  // ── Change password (B5)
  // POST /me/password body: { old_password?, password, confirm_password,
  //                           password_token? }
  static String get mePassword => '$_store/me/password';

  // GET /me/boundAccounts — returns the third-party IDs bound to the current
  // member (e.g. { fb_asid: ..., fb_psid: ..., google_sub: ..., line: null,
  // instagram: null, tiktok: null }). Used by 帳號設定 to label which
  // providers are linked.
  static String get meBoundAccounts => '$_store/me/boundAccounts';

  // ── Store Checkout Setting ────────────────────────────────────────────────
  // GET /v1/mall/store/{id}/storeCheckoutSetting → StoreCheckoutSettingResource
  // (enable_custom_mode / enable_merge_checkout / enable_member_abandon /
  //  deduct_stock_on_checkout / checkout_limit)
  static String get storeCheckoutSetting => '$_store/storeCheckoutSetting';

  // ── Address - Home Delivery ────────────────────────────────────────────────
  static String get homeDeliveryAddresses => '$_store/address/homeDelivery';
  static String get homeDeliveryCountries =>
      '$_store/address/homeDelivery/countries';
  static String homeDeliveryDestroy(int id) =>
      '$_store/address/homeDelivery/$id/destroy';
  static String homeDeliveryDefault(int id) =>
      '$_store/address/homeDelivery/$id/default';

  // ── Address - Store Pickup ─────────────────────────────────────────────────
  static String get storePickupAddresses => '$_store/address/storePickup';
  static String get storePickupCountries =>
      '$_store/address/storePickup/countries';
  // 2026-05 spec rev: response shape changed to {brand, type_label,
  // shipping_method_display_name}; the store_shipping_method_id /
  // shipping_method_id columns were dropped. Checkout UI no longer chooses
  // a store_shipping_method_id at confirm time — it picks delivery_type +
  // pickup brand via the new /cart/checkout/shippingOptions endpoint.
  static String get storePickupMethods => '$_store/address/storePickup/method';
  static String storePickupDestroy(int id) =>
      '$_store/address/storePickup/$id/destroy';
  static String storePickupDefault(int id) =>
      '$_store/address/storePickup/$id/default';

  // ── Category ──────────────────────────────────────────────────────────────
  static String get categories => '$_store/category';
  static String get storeCategories => '$_store/storeCategory';

  // ── Products ──────────────────────────────────────────────────────────────
  // Deprecated: use productCards / productCard instead.
  @Deprecated('Use productCards with category_ids[] query param instead')
  static String get products => '$_store/product';
  @Deprecated('Use productCard(String id) instead')
  static String product(String id) => '$_store/product/$id';

  @Deprecated('Replaced by storeCategories (/storeCategory)')
  static String get productGroups => '$_store/productGroup';

  // productCard index: supports category_ids[], type, keyword, order_by,
  // direction, group_id, market_id — pass as Dio queryParameters.
  static String get productCards => '$_store/productCard';
  static String productCard(String id) => '$_store/productCard/$id';

  // upsell: required query params product_id, market_type, category_id
  // — pass as Dio queryParameters.
  static String get upsell => '$_store/upsell';

  static String productSpecs(int productId) =>
      '$_store/product/$productId/spec';
  static String productSpec(String id) => '$_store/product/spec/$id';
  static String productVariants(int productId) =>
      '$_store/product/$productId/variant';
  static String productVariant(String id) => '$_store/product/variant/$id';

  // ── Bids ──────────────────────────────────────────────────────────────────
  static String get bids => '$_store/bid';

  // ── Cart ──────────────────────────────────────────────────────────────────
  // Note: POST /cart/item (新增購物車項目) is deprecated — use
  // marketMallWin / marketLiveWin to enter the purchase flow instead.
  static String get cart => '$_store/cart';
  static String cartDetail(int cartId) => '$_store/cart/$cartId';
  static String cartDestroy(int cartId) => '$_store/cart/$cartId/destroy';
  static String cartUpdateItem(int cartItemId) =>
      '$_store/cart/item/$cartItemId/update';
  static String cartRemoveItem(int cartItemId) =>
      '$_store/cart/item/$cartItemId/destroy';

  // ── Checkout ──────────────────────────────────────────────────────────────
  static String get checkoutPreview => '$_store/cart/checkout/preview';
  static String get checkoutConfirm => '$_store/cart/checkout/confirm';
  // GET — top-level delivery types (home / pickup) plus brand list per type.
  // Response: { delivery_types: [{code, label, available, brands[]}] }
  // Replaces the old "show every store_shipping_method" UX.
  static String get checkoutShippingOptions =>
      '$_store/cart/checkout/shippingOptions';
  // Apply coupon code to current cart selection — returns AppliedCouponResource
  // describing the discount that will be applied at preview/confirm.
  static String get checkoutCouponApply =>
      '$_store/cart/checkout/coupon/apply';
  // Poll the async checkout task created by /cart/checkout/confirm.
  static String checkoutTask(String requestId) =>
      '$_store/cart/checkout/task/$requestId';

  // ── Purchases ─────────────────────────────────────────────────────────────
  static String get purchases => '$_store/purchases';
  static String purchase(int id) => '$_store/purchases/$id';

  // ── Coupons ───────────────────────────────────────────────────────────────
  static String get coupons => '$_store/coupon/member';
  static String get couponsClaimable => '$_store/coupon/claimable';
  static String get couponClaim => '$_store/coupon/member/claim';
  // Backend marks `/coupon/member/redeem` as `deprecated: true` — coupon
  // codes are now applied during checkout via `cart/checkout/coupon/apply`.
  // Kept for reference but **must not be called** from new UI.
  @Deprecated('Use /cart/checkout/coupon/apply during checkout instead')
  static String get couponRedeem => '$_store/coupon/member/redeem';

  // ── Bonus Points ──────────────────────────────────────────────────────────
  static String get bonusBalance => '$_store/bonus/balance';
  static String get bonusEarning => '$_store/bonus/earning';
  static String get bonusUsage => '$_store/bonus/usage';
  static String get bonusSpend => '$_store/bonus/spend';
  // 2026-05 spec: GET {storeId}/bonus/history merges earning + usage,
  // sorted by created_at desc, with optional start_date / end_date /
  // page_size query params. Replaces having to fetch earning + usage
  // separately for the 紅利明細 screen.
  static String get bonusHistory => '$_store/bonus/history';

  // ── Market ────────────────────────────────────────────────────────────────
  static String get markets => '$_store/market';
  static String market(int id) => '$_store/market/$id';
  static String get marketsMall => '$_store/market/mall';
  static String marketMallWin(int marketId) =>
      '$_store/market/mall/$marketId/win';
  static String get marketsLive => '$_store/market/live';
  static String marketLiveWin(int marketId) =>
      '$_store/market/live/$marketId/win';
  static String get marketGroupPosts => '$_store/market/groupPost';
  static String get marketFanPagePosts => '$_store/market/fanPagePost';
  static String marketWinTask(String requestId) =>
      '$_store/market/win-task/$requestId';

  // ── Combo ─────────────────────────────────────────────────────────────────
  static String get combos => '$_store/combo';
  static String combo(int id) => '$_store/combo/$id';

  // ── Password Reset ────────────────────────────────────────────────────────
  static String get passwordForgot    => '$_store/password/forgot';
  static String get passwordVerifyOtp => '$_store/password/verifyOtp';
  static String get passwordReset     => '$_store/password/reset';

  // ── Banner & Stream Board ─────────────────────────────────────────────────
  static String get bannerList      => '$_store/banner/list';
  static String get streamBoardList => '$_store/streamBoard/list';
  static String get storeMarqueeList => '$_store/storeMarquee/list';
  static String get keywordList      => '$_store/keyword/list';

  // ── Store Collection (主題館 — B8) ─────────────────────────────────────────
  // POST {storeId}/storeCollection/list — list active themed catalogues.
  // GET  {storeId}/storeCollection/{id} — items inside a specific 主題館.
  static String get storeCollections => '$_store/storeCollection/list';
  static String storeCollection(int id) => '$_store/storeCollection/$id';

  // ── Live ──────────────────────────────────────────────────────────────────
  // GET /api/v1/mall/store/{store}/market/live
  // Query params: page_size (int, 1-1000, optional)
  // Note: marketsLive (line above) is the correct endpoint; use it for live list.
  // historicalLives and liveComments have no matching API spec entry.
  static String get historicalLives => '$_api/v1/mall/live/history';
  static String liveComments(String liveId) =>
      '$_api/v1/mall/live/$liveId/comments';

  // ── Favorites ─────────────────────────────────────────────────────────────
  // NOTE: Route confirmed non-existent on server (404). No API endpoint.
}
