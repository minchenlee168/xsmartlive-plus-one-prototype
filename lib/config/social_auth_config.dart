/// OAuth client configuration for social login providers.
///
/// Credentials are sourced from the UAT environment.
/// Replace with production values when releasing.
class SocialAuthConfig {
  SocialAuthConfig._();

  // ── Facebook ──────────────────────────────────────────────────────────────
  /// Facebook App ID — sourced from NUXT_PUBLIC_FACEBOOK_ID.
  static const facebookAppId = '729262616782392';

  // ── Google ────────────────────────────────────────────────────────────────
  /// Web client ID — used as [serverClientId] so google_sign_in requests an
  /// idToken the backend can validate via Google's token-info endpoint.
  ///
  /// Platform setup required:
  ///   Android → google-services.json in android/app/ (add Android OAuth client
  ///             in Google Cloud Console, register app's SHA-1 fingerprint)
  ///   iOS     → GIDClientID entry in ios/Runner/Info.plist pointing to the
  ///             iOS client ID, plus CFBundleURLSchemes for the reversed ID.
  static const googleServerClientId =
      '956125442468-6a4efjk89uu3vpq3g96qq1rv1colsoud.apps.googleusercontent.com';

  // ── LINE ─────────────────────────────────────────────────────────────────
  static const lineChannelId = '2009040853';
  static const lineCallbackUrl =
      'https://www-uat-1.xsmartlive.com/api/auth/line/callback';

  /// Builds the LINE OAuth 2.1 authorisation URL.
  /// [state] should be a cryptographically random nonce.
  static String lineAuthUrl({required String state}) =>
      Uri.https('access.line.me', '/oauth2/v2.1/authorize', {
        'response_type': 'code',
        'client_id': lineChannelId,
        'redirect_uri': lineCallbackUrl,
        'scope': 'profile openid',
        'state': state,
        'bot_prompt': 'normal',
      }).toString();

  // ── TikTok ────────────────────────────────────────────────────────────────
  static const tikTokClientKey = 'sbaw16lh4xzro63va6';
  static const tikTokCallbackUrl =
      'https://www-uat-1.xsmartlive.com/api/auth/tiktok/callback';

  /// Builds the TikTok v2 OAuth authorisation URL.
  static String tikTokAuthUrl({required String state}) =>
      Uri.https('www.tiktok.com', '/v2/auth/authorize/', {
        'client_key': tikTokClientKey,
        'scope': 'user.info.basic',
        'response_type': 'code',
        'redirect_uri': tikTokCallbackUrl,
        'state': state,
      }).toString();
}
