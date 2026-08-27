import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/flavor_config.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_mode_provider.dart';
import 'providers/theme_provider.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lightTheme = ref.watch(activeLightThemeProvider);
    final darkTheme = ref.watch(activeDarkThemeProvider);
    final themeMode =
        ref.watch(themeModeNotifierProvider).valueOrNull ?? ThemeMode.system;
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeNotifierProvider).valueOrNull;

    ref.listen<bool>(sessionExpiredProvider, (prev, next) {
      if (!next) return;
      final navContext = rootNavigatorKey.currentContext;
      if (navContext == null) return;
      final l10n = AppLocalizations.of(navContext);
      showDialog<void>(
        context: navContext,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(l10n?.sessionExpiredTitle ?? '登入已過期'),
          content: Text(l10n?.sessionExpiredMessage ?? '您的登入階段已過期，請重新登入。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(navContext, rootNavigator: true).pop();
                ref.read(sessionExpiredProvider.notifier).state = false;
              },
              child: Text(l10n?.relogin ?? '重新登入'),
            ),
          ],
        ),
      );
    });

    return MaterialApp.router(
      title: FlavorConfig.instance.appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
