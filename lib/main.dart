import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'config/flavor_config.dart';
import 'data/analytics/analytics_service.dart';
import 'providers/repository_providers.dart';
import 'theme/preset_themes.dart';
import 'theme/remote_theme_builder.dart';

/// Phase-1 verification entry point.
///
/// Mirrors `main_merchant_a.dart` (same flavor / API base URL / merchant ID)
/// but seeds [FlavorConfig.fallbackTheme] with the **Diva preset** instead of
/// the neutral SmartLive purple — so the new design language is visible the
/// moment the app launches, without needing to navigate to
/// `Profile → APP 主題` first.
///
/// User-chosen presets (persisted via `presetThemeProvider`) still take
/// priority over this fallback; tap "商戶預設" in the theme picker to fall
/// back to whatever `FlavorConfig.fallbackTheme` is set to (here: Diva).
///
/// Production flavor entries (`main_merchant_a/b/c.dart`) remain
/// untouched and continue to use the merchant remote/JSON fallback.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  FlavorConfig.initialize(
    flavor: Flavor.merchantA,
    appName: 'Brand A Live',
    baseUrl: 'https://api-uat-1.xsmartlive.com',
    merchantId: '1',
    fallbackTheme: RemoteThemeBuilder.buildPreset(PresetId.diva),
    turnstileEnabled: !kIsWeb, // web 無 WebView 實作，Turnstile captcha 會崩潰，預覽時關閉
    turnstileSiteKey: '0x4AAAAAADYKlBG7z9-a0xhV',
  );

  await initAnalytics();

  // Web 沒有檔案系統，path_provider 的 getApplicationDocumentsDirectory
  // 在 web 上會丟 MissingPluginException 導致啟動崩潰（白畫面）。
  // 預覽用途改用 in-memory CookieJar，其他平台維持檔案持久化。
  final CookieJar cookieJar;
  if (kIsWeb) {
    cookieJar = CookieJar();
  } else {
    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      ignoreExpires: false,
      storage: FileStorage('${dir.path}/.cookies/'),
    );
  }

  runApp(ProviderScope(
    overrides: [cookieJarProvider.overrideWithValue(cookieJar)],
    child: const MyApp(),
  ));
}
