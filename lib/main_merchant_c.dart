import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'config/flavor_config.dart';
import 'data/analytics/analytics_service.dart';
import 'providers/repository_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  FlavorConfig.initialize(
    flavor: Flavor.merchantC,
    appName: 'Brand C Live',
    baseUrl: 'https://api.merchant-c.com',
    merchantId: 'merchant_c',
    fallbackTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
    ),
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
