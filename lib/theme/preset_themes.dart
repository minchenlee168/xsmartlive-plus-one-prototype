import 'package:flutter/material.dart';

import 'app_theme_extension.dart';

/// Identifier for the 6 built-in preset themes derived from the
/// `直播管家觀眾App` design prototype (`src/themes.jsx`).
///
/// `null` (i.e. absent) means "use the merchant's remote theme JSON" —
/// preset selection lives in `presetThemeProvider`.
enum PresetId {
  warm,
  minimal,
  vibrant,
  ecom,
  night,
  diva,
}

extension PresetIdSerialization on PresetId {
  String get storageKey => name;

  static PresetId? fromStorage(String? raw) {
    if (raw == null) return null;
    for (final id in PresetId.values) {
      if (id.name == raw) return id;
    }
    return null;
  }
}

/// Display metadata + design tokens for a single preset theme.
///
/// `tokens` is the full `AppThemeExtension` for the preset; `colorScheme` is
/// derived in `RemoteThemeBuilder.buildPreset()` from the same primary +
/// surface colours so M3 widgets stay coherent.
@immutable
class PresetTheme {
  const PresetTheme({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.brightness,
    required this.tokens,
  });

  final PresetId id;
  final String name;
  final String nameEn;
  final Brightness brightness;
  final AppThemeExtension tokens;

  /// Shorthand: gradient used for the preview swatch in the theme picker.
  LinearGradient get previewGradient => tokens.primaryGradient;
}

/// Lookup of every preset theme. Indexed by [PresetId]. Order is the same as
/// the prototype's `THEMES` object so the picker UI mirrors `app.jsx`.
final Map<PresetId, PresetTheme> kPresetThemes = {
  PresetId.warm: _warm,
  PresetId.minimal: _minimal,
  PresetId.vibrant: _vibrant,
  PresetId.ecom: _ecom,
  PresetId.night: _night,
  PresetId.diva: _diva,
};

// ─────────────────────────────────────────────────────────────────────────────
// Tone-ramp helper
// ─────────────────────────────────────────────────────────────────────────────

/// Generates a 11-tone palette by lerping between a near-white tint and a
/// near-black shade of [primary]. Good enough for non-Diva presets where we
/// don't need a hand-tuned ramp; Diva uses an explicit ramp.
BrandPalette _generatePalette(Color primary) {
  final hsl = HSLColor.fromColor(primary);
  Color tone(double lightness) => hsl.withLightness(lightness).toColor();
  return BrandPalette(
    tone50: tone(0.96),
    tone100: tone(0.92),
    tone200: tone(0.84),
    tone300: tone(0.74),
    tone400: tone(0.62),
    tone500: primary,
    tone600: tone(0.42),
    tone700: tone(0.32),
    tone800: tone(0.22),
    tone900: tone(0.14),
    tone950: tone(0.08),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. 暖調奧茲 — Warm
// ─────────────────────────────────────────────────────────────────────────────
final _warm = PresetTheme(
  id: PresetId.warm,
  name: '暖調奧茲',
  nameEn: 'Warm',
  brightness: Brightness.light,
  tokens: AppThemeExtension(
    cardRadius: 18,
    buttonRadius: 18,
    chipRadius: 12,
    dialogRadius: 18,
    sheetRadius: 28,
    radiusSm: 12,
    radiusLg: 28,
    bg: const Color(0xFFFBF6F0),
    bgElev: const Color(0xFFFFFFFF),
    bgSubtle: const Color(0xFFF4ECE2),
    fg: const Color(0xFF2A1F18),
    fgMuted: const Color(0xFF8A7868),
    chip: const Color(0xFFF4ECE2),
    chipFg: const Color(0xFF5C4633),
    accent: const Color(0xFFC29FFA),
    danger: const Color(0xFFD14A3D),
    success: const Color(0xFF7BA05B),
    warning: const Color(0xFFE07856),
    info: const Color(0xFF8C5BC2),
    divider: const Color(0x1F785032),
    muted: const Color(0xFF8A7868),
    gradientColors: const [Color(0xFFFFE0CC), Color(0xFFFFCFB8)],
    authPageGradient: const [Color(0xFFFFE0CC), Color(0xFFE07856)],
    fontDisplay: 'Noto Sans TC',
    fontBody: 'Noto Sans TC',
    fontWeightDisplay: FontWeight.w700,
    brandPalette: _generatePalette(const Color(0xFFE07856)),
    elevation1: const [
      BoxShadow(
        color: Color(0x0F785032),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    elevation2: const [
      BoxShadow(
        color: Color(0x14785032),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
    elevation3: const [
      BoxShadow(
        color: Color(0x1A785032),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// 2. 高級簡約 — Minimal
// ─────────────────────────────────────────────────────────────────────────────
final _minimal = PresetTheme(
  id: PresetId.minimal,
  name: '高級簡約',
  nameEn: 'Minimal',
  brightness: Brightness.light,
  tokens: AppThemeExtension(
    cardRadius: 4,
    buttonRadius: 4,
    chipRadius: 2,
    dialogRadius: 4,
    sheetRadius: 8,
    radiusSm: 2,
    radiusLg: 8,
    bg: const Color(0xFFFAF9F6),
    bgElev: const Color(0xFFFFFFFF),
    bgSubtle: const Color(0xFFF0EEE8),
    fg: const Color(0xFF0A0A0A),
    fgMuted: const Color(0xFF737373),
    chip: const Color(0xFFF0EEE8),
    chipFg: const Color(0xFF3A3A3A),
    accent: const Color(0xFFA89072),
    danger: const Color(0xFFA33A2E),
    success: const Color(0xFF3D6B4A),
    warning: const Color(0xFFA89072),
    info: const Color(0xFF3D6B4A),
    divider: const Color(0x140A0A0A),
    muted: const Color(0xFF737373),
    gradientColors: const [Color(0xFFF0EEE8), Color(0xFFE8E5DD)],
    authPageGradient: const [Color(0xFFF0EEE8), Color(0xFF0A0A0A)],
    fontDisplay: 'Playfair Display',
    fontBody: 'Noto Sans TC',
    fontWeightDisplay: FontWeight.w600,
    brandPalette: _generatePalette(const Color(0xFF0A0A0A)),
    elevation1: const [],
    elevation2: const [],
    elevation3: const [],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// 3. 年輕繽紛 — Vibrant
// ─────────────────────────────────────────────────────────────────────────────
final _vibrant = PresetTheme(
  id: PresetId.vibrant,
  name: '年輕繽紛',
  nameEn: 'Vibrant',
  brightness: Brightness.light,
  tokens: AppThemeExtension(
    cardRadius: 24,
    buttonRadius: 24,
    chipRadius: 16,
    dialogRadius: 24,
    sheetRadius: 36,
    radiusSm: 16,
    radiusLg: 36,
    bg: const Color(0xFFFFFEF7),
    bgElev: const Color(0xFFFFFFFF),
    bgSubtle: const Color(0xFFFFF4D6),
    fg: const Color(0xFF1A0F2E),
    fgMuted: const Color(0xFF6B5B7B),
    chip: const Color(0xFFFFE4F1),
    chipFg: const Color(0xFFC41A6E),
    accent: const Color(0xFF7C5CFF),
    danger: const Color(0xFFFF4444),
    success: const Color(0xFF00C896),
    warning: const Color(0xFFFFC107),
    info: const Color(0xFF7C5CFF),
    divider: const Color(0x1A1A0F2E),
    muted: const Color(0xFF6B5B7B),
    gradientColors: const [Color(0xFFFF2E93), Color(0xFF7C5CFF)],
    authPageGradient: const [Color(0xFFFF2E93), Color(0xFF7C5CFF)],
    fontDisplay: 'DM Sans',
    fontBody: 'Noto Sans TC',
    fontWeightDisplay: FontWeight.w800,
    brandPalette: _generatePalette(const Color(0xFFFF2E93)),
    elevation1: const [
      BoxShadow(
        color: Color(0x267C5CFF),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
    elevation2: const [
      BoxShadow(
        color: Color(0x40FF2E93),
        blurRadius: 32,
        offset: Offset(0, 12),
      ),
    ],
    elevation3: const [
      BoxShadow(
        color: Color(0x40FF2E93),
        blurRadius: 48,
        offset: Offset(0, 16),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// 4. 電商強對比 — Commerce
// ─────────────────────────────────────────────────────────────────────────────
final _ecom = PresetTheme(
  id: PresetId.ecom,
  name: '電商強對比',
  nameEn: 'Commerce',
  brightness: Brightness.light,
  tokens: AppThemeExtension(
    cardRadius: 6,
    buttonRadius: 6,
    chipRadius: 4,
    dialogRadius: 6,
    sheetRadius: 10,
    radiusSm: 4,
    radiusLg: 10,
    bg: const Color(0xFFF5F5F5),
    bgElev: const Color(0xFFFFFFFF),
    bgSubtle: const Color(0xFFEEEEEE),
    fg: const Color(0xFF1A1A1A),
    fgMuted: const Color(0xFF888888),
    chip: const Color(0xFFFFE8EA),
    chipFg: const Color(0xFFC42836),
    accent: const Color(0xFFFF7A00),
    danger: const Color(0xFFEE3F4D),
    success: const Color(0xFF26A65B),
    warning: const Color(0xFFFF7A00),
    info: const Color(0xFFEE3F4D),
    divider: const Color(0x14000000),
    muted: const Color(0xFF888888),
    gradientColors: const [Color(0xFFEE3F4D), Color(0xFFFF7A00)],
    authPageGradient: const [Color(0xFFEE3F4D), Color(0xFFFF7A00)],
    fontDisplay: 'Noto Sans TC',
    fontBody: 'Noto Sans TC',
    fontWeightDisplay: FontWeight.w700,
    brandPalette: _generatePalette(const Color(0xFFEE3F4D)),
    elevation1: const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
    elevation2: const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
    elevation3: const [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// 5. 夜間直播 — Night (dark)
// ─────────────────────────────────────────────────────────────────────────────
final _night = PresetTheme(
  id: PresetId.night,
  name: '夜間直播',
  nameEn: 'Night',
  brightness: Brightness.dark,
  tokens: AppThemeExtension(
    cardRadius: 16,
    buttonRadius: 16,
    chipRadius: 10,
    dialogRadius: 16,
    sheetRadius: 24,
    radiusSm: 10,
    radiusLg: 24,
    bg: const Color(0xFF0E0E10),
    bgElev: const Color(0xFF1A1A1F),
    bgSubtle: const Color(0xFF222229),
    fg: const Color(0xFFF5F5F7),
    fgMuted: const Color(0xFF8E8E93),
    chip: const Color(0xFF222229),
    chipFg: const Color(0xFFE5E5E7),
    accent: const Color(0xFF9B6DFF),
    danger: const Color(0xFFFF453A),
    success: const Color(0xFF30D158),
    warning: const Color(0xFFFFD60A),
    info: const Color(0xFF9B6DFF),
    divider: const Color(0x14FFFFFF),
    muted: const Color(0xFF8E8E93),
    gradientColors: const [Color(0xFFFF3B6F), Color(0xFF9B6DFF)],
    authPageGradient: const [Color(0xFFFF3B6F), Color(0xFF9B6DFF)],
    fontDisplay: 'Noto Sans TC',
    fontBody: 'Noto Sans TC',
    fontWeightDisplay: FontWeight.w700,
    brandPalette: _generatePalette(const Color(0xFFFF3B6F)),
    isDarkSurface: true,
    elevation1: const [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    elevation2: const [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
    ],
    elevation3: const [
      BoxShadow(
        color: Color(0x99000000),
        blurRadius: 48,
        offset: Offset(0, 16),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// 6. 天后闆妹 — Diva Boss  (PRIMARY target for Phase 1)
// ─────────────────────────────────────────────────────────────────────────────
//
// Hand-tuned ramp from the prototype's `B8966E` (gold-bronze) primary.
// Other presets use `_generatePalette()` since they're stub implementations
// for now; Diva is the showcase theme, so its tones are explicit.
const _divaPalette = BrandPalette(
  tone50: Color(0xFFFAF5EE),
  tone100: Color(0xFFF4EAD9),
  tone200: Color(0xFFE9D5B5),
  tone300: Color(0xFFDDC091),
  tone400: Color(0xFFD0AB6D),
  tone500: Color(0xFFB8966E),
  tone600: Color(0xFF9E7D5A),
  tone700: Color(0xFF7E6346),
  tone800: Color(0xFF5E4A35),
  tone900: Color(0xFF3F3123),
  tone950: Color(0xFF2A2018),
);

final _diva = PresetTheme(
  id: PresetId.diva,
  name: '天后闆妹',
  nameEn: 'Diva Boss',
  brightness: Brightness.light,
  tokens: AppThemeExtension(
    cardRadius: 4,
    buttonRadius: 4,
    chipRadius: 2,
    dialogRadius: 4,
    sheetRadius: 8,
    radiusSm: 2,
    radiusLg: 8,
    bg: const Color(0xFFFAF9F7),
    bgElev: const Color(0xFFFFFFFF),
    bgSubtle: const Color(0xFFFDF3E3),
    fg: const Color(0xFF2C2826),
    fgMuted: const Color(0xFF8B8480),
    chip: const Color(0xFFFDF3E3),
    chipFg: const Color(0xFF9E7D5A),
    accent: const Color(0xFFD4B896),
    danger: const Color(0xFFEF5350),
    success: const Color(0xFF27AE60),
    warning: const Color(0xFFD4B896),
    info: const Color(0xFFB8966E),
    divider: const Color(0xFFF0EDE8),
    muted: const Color(0xFF8B8480),
    gradientColors: const [Color(0xFFB8966E), Color(0xFFD4AD81)],
    authPageGradient: const [Color(0xFFD4AD81), Color(0xFFB8966E)],
    fontDisplay: 'Cormorant Garamond',
    fontBody: 'Noto Sans TC',
    fontWeightDisplay: FontWeight.w400,
    brandPalette: _divaPalette,
    elevation1: const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    elevation2: const [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 24,
        offset: Offset(0, 6),
      ),
    ],
    elevation3: const [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 40,
        offset: Offset(0, 12),
      ),
    ],
  ),
);
