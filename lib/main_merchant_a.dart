import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'config/flavor_config.dart';
import 'data/analytics/analytics_service.dart';
import 'providers/repository_providers.dart';
import 'theme/remote_theme_builder.dart';
import 'theme/remote_theme_model.dart';

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
    fallbackTheme: RemoteThemeBuilder.build(const RemoteThemeModel(
      colors: RemoteColors(),
      typography: RemoteTypography(),
      shape: RemoteShape(),
      assets: RemoteAssets(),
    )),
    turnstileEnabled: true,
    turnstileSiteKey: '0x4AAAAAADYKlBG7z9-a0xhV',
  );

  await initAnalytics();

  final dir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    ignoreExpires: false,
    storage: FileStorage('${dir.path}/.cookies/'),
  );

  runApp(ProviderScope(
    overrides: [cookieJarProvider.overrideWithValue(cookieJar)],
    child: const MyApp(),
  ));
}
