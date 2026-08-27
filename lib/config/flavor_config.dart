import 'package:flutter/material.dart';

enum Flavor { merchantA, merchantB, merchantC }

class FlavorConfig {
  static FlavorConfig? _instance;
  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig.initialize() must be called before accessing instance');
    return _instance!;
  }

  final Flavor flavor;
  final String appName;
  final String baseUrl;
  final String merchantId;
  final ThemeData fallbackTheme;

  /// Cloudflare Turnstile site key for this environment. Each flavor wires
  /// its own (UAT / production / per-merchant) — see Turnstile spec section 2.
  /// Empty string means Turnstile is not provisioned for this build and the
  /// login screen falls back to the legacy image captcha.
  final String turnstileSiteKey;

  /// Whether Turnstile is the active captcha mode for this build. When
  /// false the login screen keeps using the legacy image captcha and the
  /// backend should have `TURNSTILE_ENABLED=false` set for this environment.
  /// Toggling is build-time — backend RD will sync the switch with a
  /// coordinated release per Turnstile spec section 6.
  final bool turnstileEnabled;

  /// Turnstile `data-action` attribute. Backend matches against this to
  /// authorise the token; mismatch returns HTTP 422 / code 10007.
  /// Mall login is always `login_mall`.
  final String turnstileAction;

  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.baseUrl,
    required this.merchantId,
    required this.fallbackTheme,
    required this.turnstileSiteKey,
    required this.turnstileEnabled,
    required this.turnstileAction,
  });

  static void initialize({
    required Flavor flavor,
    required String appName,
    required String baseUrl,
    required String merchantId,
    required ThemeData fallbackTheme,
    String turnstileSiteKey = '',
    bool turnstileEnabled = false,
    String turnstileAction = 'login_mall',
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      baseUrl: baseUrl,
      merchantId: merchantId,
      fallbackTheme: fallbackTheme,
      turnstileSiteKey: turnstileSiteKey,
      turnstileEnabled: turnstileEnabled,
      turnstileAction: turnstileAction,
    );
  }

  bool get isDebug => flavor == Flavor.merchantA;
}
