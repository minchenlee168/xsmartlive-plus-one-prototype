import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/flavor_config.dart';
import '../data/repositories/theme_repository.dart';
import '../data/theme_cache_storage.dart';
import 'remote_theme_builder.dart';
import 'theme_state.dart';

class RemoteThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // Trigger async load after build.
    // Future.microtask(_loadTheme);
    return const ThemeState.initial();
  }

  Future<void> _loadTheme() async {
    final merchantId = FlavorConfig.instance.merchantId;
    final cache = ref.read(_themeCacheStorageProvider);
    final repo = ref.read(_themeRepositoryProvider);

    state = const ThemeState.loading();

    // Step 1 — show cached theme immediately if available.
    final cached = await cache.read(merchantId);
    if (cached != null) {
      state = ThemeState.cached(RemoteThemeBuilder.build(cached));
    }

    // Step 2 — fetch latest from remote (no auth required).
    try {
      final remote = await repo.fetchTheme(merchantId);
      await cache.write(merchantId, remote);
      state = ThemeState.loaded(RemoteThemeBuilder.build(remote));
    } catch (e) {
      final fallback = cached != null
          ? RemoteThemeBuilder.build(cached)
          : FlavorConfig.instance.fallbackTheme;
      state = ThemeState.error(e.toString(), fallback);
    }
  }

  Future<void> reload() => _loadTheme();
}

// Internal providers (not exposed globally)
final _themeCacheStorageProvider = Provider<ThemeCacheStorage>(
  (ref) => ThemeCacheStorage(),
);

final _themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  throw UnimplementedError('Override via remoteThemeProvider scope');
});

/// Exposed provider — override [_themeRepositoryProvider] in the scope where
/// DioClient is available.
final remoteThemeNotifierProvider =
    NotifierProvider<RemoteThemeNotifier, ThemeState>(
  RemoteThemeNotifier.new,
);

/// Convenience provider: returns the active ThemeData (never null).
final activeThemeProvider = Provider<ThemeData>((ref) {
  final state = ref.watch(remoteThemeNotifierProvider);
  return state.themeOrNull ?? FlavorConfig.instance.fallbackTheme;
});
