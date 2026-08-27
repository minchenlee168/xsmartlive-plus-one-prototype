import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/preset_themes.dart';

const _kPresetThemeKey = 'app_preset_theme';

/// Persisted [PresetId]. `null` (= "merchant default") means the app should
/// fall through to the remote theme JSON pipeline in [ThemeNotifier].
///
/// Selecting a preset takes priority over the remote/cached/flavor-fallback
/// chain — see `activeThemeProvider` in `theme_provider.dart`.
class PresetThemeNotifier extends AsyncNotifier<PresetId?> {
  @override
  Future<PresetId?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kPresetThemeKey);
    return PresetIdSerialization.fromStorage(saved);
  }

  /// Selects a preset and persists it. Pass `null` to clear the override
  /// (i.e. revert to the remote merchant theme).
  Future<void> setPreset(PresetId? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_kPresetThemeKey);
    } else {
      await prefs.setString(_kPresetThemeKey, id.storageKey);
    }
    state = AsyncData(id);
  }
}

final presetThemeProvider =
    AsyncNotifierProvider<PresetThemeNotifier, PresetId?>(
  PresetThemeNotifier.new,
);
