import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/api_constants.dart';
import '../../config/social_auth_config.dart';
import '../../core/errors/app_exception.dart';
import '../../models/member_profile.dart';
import '../../models/user.dart';
import '../dio_client.dart';
import '../token_storage.dart';

/// Backend error code returned in HTTP 422 bodies when the supplied
/// `captcha` value fails Cloudflare siteverify. The backend collapses every
/// failure mode (empty / expired / replayed / action mismatch / siteverify
/// outage) into this single code so the UI must always respond by refreshing
/// the captcha widget.
const int _kCaptchaInvalidCode = 10007;

class AuthRepository {
  AuthRepository(this._dioClient, this._tokenStorage, this._cookieJar);

  final DioClient _dioClient;
  final TokenStorage _tokenStorage;
  final CookieJar _cookieJar;

  /// Normalise mobile: strip whitespace/dashes, remove leading 0 after country code.
  /// e.g. +886 0912-345-678 → +886912345678
  static String _formatMobile(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    return cleaned.replaceFirstMapped(
      RegExp(r'^(\+\d{1,4})0(\d+)$'),
      (m) => '${m[1]}${m[2]}',
    );
  }

  /// login_type = 1: 手機號碼 + 密碼登入.
  /// Authentication is entirely session-cookie based (laravel_session).
  /// The cookie is managed automatically by [CookieManager] in [DioClient].
  ///
  /// [captcha] is the verification token — either a legacy image-captcha
  /// answer or a Cloudflare Turnstile token depending on the active
  /// `TURNSTILE_ENABLED` backend flag. The transport is identical (string
  /// field named `captcha`, 2048 char cap).
  ///
  /// Throws [CaptchaInvalidException] when the backend rejects the captcha
  /// (HTTP 422 with code 10007). The UI should refresh the captcha widget
  /// and let the user retry.
  Future<User> login({
    required String mobile,
    required String password,
    required String captcha,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallLogin,
        data: {
          'login_type': 1,
          'mobile': formattedMobile,
          'password': password.trim(),
          'captcha': captcha.trim(),
          'store_id': 1,
          // 'store_id': int.parse(FlavorConfig.instance.merchantId),
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Login failed');
      }
      final data = body['data'] as Map<String, dynamic>;
      final user = User.fromJson(data);
      await _tokenStorage.saveUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      if (_isCaptchaInvalid(e)) {
        final body = e.response?.data;
        final msg = body is Map<String, dynamic>
            ? body['message'] as String?
            : null;
        throw CaptchaInvalidException(msg ?? 'Captcha verification failed');
      }
      throw dioErrorToAppException(e);
    }
  }

  static bool _isCaptchaInvalid(DioException e) {
    if (e.response?.statusCode != 422) return false;
    final body = e.response?.data;
    if (body is! Map<String, dynamic>) return false;
    final code = body['code'];
    if (code is int) return code == _kCaptchaInvalidCode;
    if (code is String) return code == '$_kCaptchaInvalidCode';
    return false;
  }

  /// Send SMS OTP to the given mobile number for registration.
  Future<void> sendRegisterOtp({
    required String country,
    required String mobile,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallSendRegisterOtp,
        data: {
          'country': country,
          'mobile': formattedMobile,
          'store_id': 1,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Register a new account with OTP verification.
  /// Returns true on success; the caller must redirect to login.
  Future<bool> register({
    required String name,
    required String country,
    required String mobile,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallRegister,
        data: {
          'name': name.trim(),
          'country': country,
          'mobile': formattedMobile,
          'otp': otp.trim(),
          'password': password,
          'confirm_password': confirmPassword,
          'store_id': 1,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Registration failed');
      }
      return true;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.get(ApiConstants.mallLogout);
    } catch (_) {
      // Best-effort; always clear local state.
    } finally {
      await _tokenStorage.clearUser();
      await _cookieJar.deleteAll();
    }
  }

  /// Fetches the current member's profile from [ApiConstants.me].
  Future<MemberProfile> fetchMe() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.me);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Failed to fetch profile');
      }
      return MemberProfile.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// POST /me/update — `name` 必填；`email`/`gender`/`birthday` 為可選。
  ///
  /// gender: 1=男性 2=女性 3=其他；birthday 須為 `Y-m-d` 格式。
  /// 成功時回傳更新後的 [MemberProfile]（後端回傳 MeResource）。
  Future<MemberProfile> updateMe({
    required String name,
    String? email,
    int? gender,
    String? birthday,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.meUpdate,
        data: {
          'name': name.trim(),
          if (email != null) 'email': email.trim(),
          if (gender != null) 'gender': gender,
          if (birthday != null) 'birthday': birthday,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception(body['message'] as String? ?? 'Failed to update profile');
      }
      return MemberProfile.fromJson(data);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Change Mobile flow ──────────────────────────────────────────────────
  // POST /me/changeMobile/request → sends OTP to the NEW mobile.
  // POST /me/changeMobile/confirm → validates OTP + persists new mobile.
  // Both endpoints expect `country` (E.164 country code, e.g. "+886") and
  // `mobile` (E.164 number); the confirm step also requires `otp`.

  /// Requests an OTP to be sent to the new mobile number for change-mobile
  /// confirmation. Throws on backend failure.
  Future<void> requestChangeMobile({
    required String country,
    required String mobile,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.meChangeMobileRequest,
        data: {
          'country': country,
          'mobile': formattedMobile,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(
            body['message'] as String? ?? 'Failed to send OTP for change mobile');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Confirms the new mobile number with the OTP delivered via
  /// [requestChangeMobile]. Backend updates the member's mobile on success.
  Future<void> confirmChangeMobile({
    required String country,
    required String mobile,
    required String otp,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.meChangeMobileConfirm,
        data: {
          'country': country,
          'mobile': formattedMobile,
          'otp': otp.trim(),
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(
            body['message'] as String? ?? 'Failed to confirm change mobile');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Bind Mobile flow (B4) ──────────────────────────────────────────────
  // POST /me/bindMobile → sends OTP to the supplied mobile.
  // POST /me/verifyOtp   → validates OTP and binds the mobile to the account.

  /// Sends an OTP to [mobile] for the initial bind-mobile flow (used by
  /// accounts created via social login that have no mobile yet).
  Future<void> bindMobile({
    required String country,
    required String mobile,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.meBindMobile,
        data: {
          'country': country,
          'mobile': formattedMobile,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(
            body['message'] as String? ?? 'Failed to send bind-mobile OTP');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Verifies the OTP delivered via [bindMobile] and binds the mobile.
  Future<void> verifyBindMobileOtp({
    required String country,
    required String mobile,
    required String otp,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.meVerifyOtp,
        data: {
          'country': country,
          'mobile': formattedMobile,
          'otp': otp.trim(),
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(
            body['message'] as String? ?? 'Bind-mobile OTP verification failed');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Change password (B5) ────────────────────────────────────────────────
  // POST /me/password body: { old_password?, password, confirm_password,
  //                           password_token? }
  // `old_password` is required for ordinary password change. `password_token`
  // is used for first-time password setup (after social login bind) and may
  // be nil otherwise.

  /// Changes the current member's password. Provide [oldPassword] for an
  /// ordinary change; provide [passwordToken] for first-time setup.
  Future<void> changePassword({
    String? oldPassword,
    required String password,
    required String confirmPassword,
    String? passwordToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mePassword,
        data: {
          if (oldPassword != null) 'old_password': oldPassword,
          'password': password,
          'confirm_password': confirmPassword,
          if (passwordToken != null) 'password_token': passwordToken,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(
            body['message'] as String? ?? 'Password change failed');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Bid Redirect (Facebook ASID binding flow) ──────────────────────────
  // After the buyer wins a bid, the merchant sends a Messenger / FB URL
  // containing a token. The mall app:
  //   1. Calls `resolveBidRedirect(token)` to learn whether the buyer
  //      already has FB ASID linked → server returns either an order URL
  //      (already bound) or a flag instructing the client to ask the buyer
  //      to FB-login.
  //   2. After the buyer logs into Facebook, the client calls
  //      `bindBidRedirect(token, fb_access_token)` to perform the bind and
  //      receive the order URL to navigate to.

  /// Resolves a bid-redirect token. Backend returns whether the buyer
  /// already has Facebook bound, plus order metadata. Caller is responsible
  /// for inspecting the returned map.
  Future<Map<String, dynamic>?> resolveBidRedirect({
    required String token,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallBidRedirectResolve,
        data: {'token': token},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      return data is Map<String, dynamic> ? data : null;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Binds the buyer's Facebook ASID using the bid-redirect token plus the
  /// FB access_token returned from the FB login flow. Returns the order
  /// page URL (or relevant payload) supplied by the backend.
  Future<Map<String, dynamic>?> bindBidRedirect({
    required String token,
    required String fbAccessToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallBidRedirectBind,
        data: {
          'token': token,
          'fb_access_token': fbAccessToken,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'];
      return data is Map<String, dynamic> ? data : null;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Sends a password-reset OTP to the given mobile number.
  /// [mobile] must be in E.164 format (e.g. "+886912345678").
  Future<void> forgotPassword({
    required String country,
    required String mobile,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.passwordForgot,
        data: {
          'country': country,
          'mobile': formattedMobile,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Verifies the OTP and returns a [passwordToken] for use in [resetPassword].
  Future<String> verifyPasswordOtp({
    required String country,
    required String mobile,
    required String otp,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.passwordVerifyOtp,
        data: {
          'country': country,
          'mobile': formattedMobile,
          'otp': otp.trim(),
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'OTP verification failed');
      }
      final data = body['data'];
      final token = (data is Map<String, dynamic>)
          ? data['password_token'] as String?
          : null;
      if (token == null || token.isEmpty) {
        throw Exception('Invalid OTP response: missing password_token');
      }
      return token;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Resets the password using a [passwordToken] obtained from [verifyPasswordOtp].
  Future<void> resetPassword({
    required String country,
    required String mobile,
    required String passwordToken,
    required String password,
    required String confirmPassword,
  }) async {
    final formattedMobile = _formatMobile(mobile.trim());
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.passwordReset,
        data: {
          'country': country,
          'mobile': formattedMobile,
          'password_token': passwordToken,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Password reset failed');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  // ── Social Login ──────────────────────────────────────────────────────────

  /// Logs in using a provider access/ID token.
  ///
  /// [loginType] follows the backend enum:
  ///   2 = Facebook ASID  3 = Facebook PSID  4 = Google
  Future<User> socialLogin({
    required int loginType,
    required String accessToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallLogin,
        data: {
          'login_type': loginType,
          'access_token': accessToken,
          'store_id': 1,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception(body['message'] as String? ?? 'Social login failed');
      }
      final user = User.fromJson(body['data'] as Map<String, dynamic>);
      await _tokenStorage.saveUser(jsonEncode(user.toJson()));
      return user;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Signs in with Facebook and calls [socialLogin] with the access token.
  /// Uses login_type=2 (FB ASID).
  ///
  /// Platform setup required — see android/app/src/main/res/values/strings.xml
  /// and ios/Runner/Info.plist for the Facebook App ID configuration.
  Future<User> facebookLogin() async {
    await FacebookAuth.instance.logOut(); // clear any stale session
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken!.tokenString;
        return socialLogin(loginType: 2, accessToken: token);
      case LoginStatus.cancelled:
        throw Exception('Facebook login cancelled');
      case LoginStatus.failed:
        throw Exception(result.message ?? 'Facebook login failed');
      case LoginStatus.operationInProgress:
        throw Exception('Facebook login already in progress');
    }
  }

  /// Signs in with Google and calls [socialLogin] with the idToken.
  ///
  /// Requires platform setup:
  ///   Android → android/app/google-services.json (download from Google Cloud
  ///             Console after registering the Android app + SHA-1 fingerprint)
  ///   iOS     → add GIDClientID & CFBundleURLSchemes to ios/Runner/Info.plist
  Future<User> googleLogin() async {
    final googleSignIn = GoogleSignIn(
      // serverClientId ensures we receive an idToken signed for the web client,
      // which the backend validates via Google's tokeninfo endpoint.
      serverClientId: SocialAuthConfig.googleServerClientId,
    );

    GoogleSignInAccount? account;
    try {
      // Sign out silently first so the account picker always appears.
      await googleSignIn.signOut();
      account = await googleSignIn.signIn();
    } catch (e) {
      throw Exception('Google sign-in error: $e');
    }
    if (account == null) throw Exception('Google sign-in cancelled');

    final auth = await account.authentication;
    final token = auth.idToken ?? auth.accessToken;
    if (token == null) throw Exception('Failed to obtain Google auth token');

    return socialLogin(loginType: 4, accessToken: token);
  }

  /// Completes a server-side OAuth flow (LINE / TikTok).
  ///
  /// [callbackUrl] is the full server callback URL intercepted from the
  /// WebView — e.g. https://www-uat-1.xsmartlive.com/api/auth/line/callback?code=xxx
  ///
  /// Strategy:
  ///   1. Replay the callback URL through Dio so the server processes the
  ///      auth code exchange and sets the laravel_session cookie in the
  ///      shared PersistCookieJar.
  ///   2. Call /me to retrieve the user profile from the new session.
  ///   3. Construct a [User] from the profile and persist to secure storage.
  Future<User> completeServerCallback(String callbackUrl) async {
    try {
      await _dioClient.dio.get(
        callbackUrl,
        options: Options(
          // Accept any 2xx/3xx; we only care about the cookies being set.
          validateStatus: (status) => status != null && status < 500,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
    } catch (_) {
      // Transport errors are non-fatal; the session cookie may still be set.
    }

    // Verify the session is now active.
    try {
      final loginResp = await _dioClient.dio.get(ApiConstants.mallIsLogin);
      final loginBody = loginResp.data as Map<String, dynamic>;
      if (loginBody['success'] != true) {
        throw Exception('OAuth login failed — session could not be established');
      }
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }

    // Fetch the user profile via the new session.
    final profile = await fetchMe();
    final user = User(
      memberId: profile.id,
      name: profile.name,
      avatarUrl: profile.avatarUrl,
    );
    await _tokenStorage.saveUser(jsonEncode(user.toJson()));
    return user;
  }

  // ── 2026-05 spec — third-party identity endpoints ───────────────────────

  /// POST /v1/mall/auth/isRegistered — probes whether the supplied
  /// third-party token belongs to an existing member so the social-login
  /// UI can branch login vs. register without forcing a sign-in attempt.
  ///
  /// [loginType] follows the backend enum used by [socialLogin]:
  ///   2 = FB ASID  3 = FB PSID  4 = Google
  ///
  /// Returns the raw `data` map when the identity is registered (caller
  /// inspects the bundled profile fields), or `null` when not registered.
  Future<Map<String, dynamic>?> isRegistered({
    required int loginType,
    required String accessToken,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.mallIsRegistered,
        data: {
          'login_type': loginType,
          'access_token': accessToken,
          'store_id': 1,
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) return null;
      final data = body['data'];
      return data is Map<String, dynamic> ? data : null;
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// GET /me/boundAccounts — returns a map of which third-party identities
  /// are bound to the current member. Providers without a bound id come
  /// back as `null`; line / instagram / tiktok are placeholders today and
  /// will always be `null`.
  Future<Map<String, String?>> fetchBoundAccounts() async {
    try {
      final response =
          await _dioClient.dio.get(ApiConstants.meBoundAccounts);
      final body = response.data;
      final data = body is Map<String, dynamic>
          ? (body['data'] ?? body)
          : body;
      if (data is! Map<String, dynamic>) return const {};
      return data.map<String, String?>(
        (key, value) => MapEntry(key, value?.toString()),
      );
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Restores the last-known [User] and verifies the session is still active.
  ///
  /// Flow:
  /// 1. Read cached [User] from secure storage. If absent → not logged in.
  /// 2. Call [mallIsLogin] to confirm the session cookie is still valid.
  ///    - success:true  → return cached user.
  ///    - success:false → session expired; clear local state, return null.
  ///    - network error → trust cache (allows offline launch).
  Future<User?> restoreUser() async {
    final userJson = await _tokenStorage.readUser();
    if (userJson == null) return null;

    try {
      final response = await _dioClient.dio.get(ApiConstants.mallIsLogin);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        await _tokenStorage.clearUser();
        return null;
      }
    } catch (_) {
      // Network unavailable — fall through and trust the cached user.
    }

    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
