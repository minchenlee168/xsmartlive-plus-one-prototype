import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/flavor_config.dart';
import '../data/repositories/theme_repository.dart';
import '../data/theme_cache_storage.dart';
import '../theme/preset_themes.dart';
import '../theme/remote_theme_builder.dart';
import '../theme/theme_state.dart';
import 'preset_theme_provider.dart';
import 'repository_providers.dart';

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // Future.microtask(_loadTheme);
    return const ThemeState.initial();
  }

  Future<void> _loadTheme() async {
    final merchantId = FlavorConfig.instance.merchantId;
    final cache = ref.read(themeCacheStorageProvider);
    final repo = ref.read(themeRepositoryProvider);

    state = const ThemeState.loading();

    final cached = await cache.read(merchantId);
    if (cached != null) {
      state = ThemeState.cached(RemoteThemeBuilder.build(cached));
    }

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

// ignore: unused_element
final _themeRepositoryProvider = Provider<ThemeRepository>(
  (ref) => ref.watch(themeRepositoryProvider),
);

// ignore: unused_element
final _themeCacheStorageProvider = Provider<ThemeCacheStorage>(
  (ref) => ref.watch(themeCacheStorageProvider),
);

final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

/// The currently resolved "base" theme.
///
/// Resolution order (highest priority first):
///   1. Local preset selected via `presetThemeProvider`
///   2. Remote theme JSON (`themeNotifierProvider`)
///   3. Cached remote theme
///   4. Flavor fallback theme
///
/// When a preset is set, the remote pipeline is bypassed entirely so the
/// user-chosen design language is honoured even if the merchant later
/// updates `/theme/{id}`.
final activeThemeProvider = Provider<ThemeData>((ref) {
  final preset = ref.watch(presetThemeProvider).valueOrNull;
  if (preset != null) {
    return RemoteThemeBuilder.buildPreset(preset);
  }
  final state = ref.watch(themeNotifierProvider);
  return state.themeOrNull ?? FlavorConfig.instance.fallbackTheme;
});

/// Light-mode variant of the active theme, used by `MaterialApp.theme`.
/// If the base theme is already light, it is returned as-is; otherwise a
/// brightness-matched re-seed keeps the same primary hue.
final activeLightThemeProvider = Provider<ThemeData>((ref) {
  final base = ref.watch(activeThemeProvider);
  return _ensureBrightness(base, Brightness.light);
});

/// Dark-mode variant of the active theme, used by `MaterialApp.darkTheme`.
/// Same primary hue, recomputed M3 palette for dark surfaces.
final activeDarkThemeProvider = Provider<ThemeData>((ref) {
  final base = ref.watch(activeThemeProvider);
  return _ensureBrightness(base, Brightness.dark);
});

/// Convenience: which preset (if any) is currently active. Used by the
/// theme picker UI to show the selected card.
final activePresetProvider = Provider<PresetId?>((ref) {
  return ref.watch(presetThemeProvider).valueOrNull;
});

/// Re-seeds the color scheme at the requested brightness while preserving
/// `AppThemeExtension` and other theme extensions. Used to derive light/dark
/// pairs from a single base theme (e.g. the flavor fallback or a remote theme).
ThemeData _ensureBrightness(ThemeData base, Brightness brightness) {
  if (base.colorScheme.brightness == brightness) return base;
  final reseeded = ColorScheme.fromSeed(
    seedColor: base.colorScheme.primary,
    brightness: brightness,
  );
  return base.copyWith(
    brightness: brightness,
    colorScheme: reseeded,
    scaffoldBackgroundColor: reseeded.surface,
  );
}
