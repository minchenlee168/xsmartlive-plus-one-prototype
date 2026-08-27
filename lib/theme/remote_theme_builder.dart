import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_extension.dart';
import 'preset_themes.dart';
import 'remote_theme_model.dart';

/// Converts a [RemoteThemeModel] (from `/theme/{id}` JSON) into Flutter
/// [ThemeData] — including the full [AppThemeExtension] token set.
///
/// Precedence: Remote JSON → model-level `@Default` → baseline in extension.
class RemoteThemeBuilder {
  RemoteThemeBuilder._();

  static ThemeData build(RemoteThemeModel model) {
    // Absent remote keys → baseline defaults.
    final spacing = model.spacing ?? const RemoteSpacing();
    final elevation = model.elevation ?? const RemoteElevation();
    final palette = model.brandPalette ?? const RemoteBrandPalette();

    // brandPalette is the source of truth for brand colours. Tones parsed once,
    // then reused as scheme overrides and the AppThemeExtension palette.
    final tone50 = _parseColor(palette.tone50);
    final tone100 = _parseColor(palette.tone100);
    final tone200 = _parseColor(palette.tone200);
    final tone300 = _parseColor(palette.tone300);
    final tone400 = _parseColor(palette.tone400);
    final tone500 = _parseColor(palette.tone500);
    final tone600 = _parseColor(palette.tone600);
    final tone700 = _parseColor(palette.tone700);
    final tone800 = _parseColor(palette.tone800);
    final tone900 = _parseColor(palette.tone900);
    final tone950 = _parseColor(palette.tone950);

    final primary = tone500;
    final secondary = _parseColor(model.colors.secondary);
    final error = _parseColor(model.colors.error);

    // M3 ColorScheme seeded from tone500 for harmonious neutral/tertiary
    // tones, then overridden on the brand roles so primary / container
    // colours match Figma 1:1 instead of HCT-derived approximations.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
      error: error,
      surface: _parseColor(model.colors.surface),
    ).copyWith(
      primary: tone500,
      onPrimary: Colors.white,
      primaryContainer: tone100,
      onPrimaryContainer: tone900,
      secondaryContainer: tone100,
      onSecondaryContainer: tone800,
    );

    // Fallback gracefully if the font name is not a valid Google Font.
    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.getTextTheme(model.typography.fontFamily);
    } catch (_) {
      textTheme = GoogleFonts.notoSansTextTheme();
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(model.shape.cardRadius),
        ),
        elevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(model.shape.buttonRadius),
          ),
        ),
      ),
      extensions: [
        AppThemeExtension(
          // ── Assets ──
          logoUrl: model.assets.logoUrl,
          splashUrl: model.assets.splashUrl,
          // ── Radii ──
          cardRadius: model.shape.cardRadius,
          buttonRadius: model.shape.buttonRadius,
          chipRadius: model.shape.chipRadius,
          dialogRadius: model.shape.dialogRadius,
          sheetRadius: model.shape.sheetRadius,
          avatarRadius: model.shape.avatarRadius,
          // ── Gradient ──
          gradientColors: [primary, secondary],
          authPageGradient: [
            _parseColor(model.colors.authGradientStart),
            _parseColor(model.colors.authGradientEnd),
          ],
          // ── Brand palette (11-tone ramp) ──
          brandPalette: BrandPalette(
            tone50: tone50,
            tone100: tone100,
            tone200: tone200,
            tone300: tone300,
            tone400: tone400,
            tone500: tone500,
            tone600: tone600,
            tone700: tone700,
            tone800: tone800,
            tone900: tone900,
            tone950: tone950,
          ),
          // ── Extended semantic colors ──
          success: _parseColor(model.colors.success),
          warning: _parseColor(model.colors.warning),
          info: _parseColor(model.colors.info),
          divider: _parseColor(model.colors.divider),
          muted: _parseColor(model.colors.muted),
          // ── Spacing ──
          spacingXxs: spacing.xxs,
          spacingXs: spacing.xs,
          spacingSm: spacing.sm,
          spacingMd: spacing.md,
          spacingLg: spacing.lg,
          spacingXl: spacing.xl,
          spacingXxl: spacing.xxl,
          spacingXxxl: spacing.xxxl,
          // ── Elevation ──
          elevation1: [
            BoxShadow(
              color: _parseColorWithAlpha(elevation.level1Color),
              blurRadius: elevation.level1Blur,
              offset: Offset(0, elevation.level1OffsetY),
            ),
          ],
          elevation2: [
            BoxShadow(
              color: _parseColorWithAlpha(elevation.level2Color),
              blurRadius: elevation.level2Blur,
              offset: Offset(0, elevation.level2OffsetY),
            ),
          ],
          elevation3: [
            BoxShadow(
              color: _parseColorWithAlpha(elevation.level3Color),
              blurRadius: elevation.level3Blur,
              offset: Offset(0, elevation.level3OffsetY),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds [ThemeData] for a built-in [PresetId]. Used by the local theme
  /// picker (overrides the remote theme JSON pipeline). Mirrors the output
  /// shape of [build] so consumers (`activeLightThemeProvider` etc.) can
  /// treat preset and remote themes identically.
  static ThemeData buildPreset(PresetId id) {
    final preset = kPresetThemes[id]!;
    final tokens = preset.tokens;
    final palette = tokens.brandPalette;

    final primary = palette.tone500;
    final secondary = tokens.accent;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: preset.brightness,
      secondary: secondary,
      error: tokens.danger,
      surface: tokens.bg,
    ).copyWith(
      primary: primary,
      onPrimary: preset.brightness == Brightness.light
          ? Colors.white
          : tokens.fg,
      primaryContainer: palette.tone100,
      onPrimaryContainer: palette.tone900,
      secondaryContainer: palette.tone100,
      onSecondaryContainer: palette.tone800,
      surface: tokens.bg,
      onSurface: tokens.fg,
      surfaceContainerHighest: tokens.bgSubtle,
    );

    // GoogleFonts fallback chain — display font may be a serif Diva uses;
    // body stays Noto Sans TC for CJK glyph coverage.
    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.getTextTheme(tokens.fontBody);
    } catch (_) {
      textTheme = GoogleFonts.notoSansTextTheme();
    }

    return ThemeData(
      useMaterial3: true,
      brightness: preset.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bg,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.cardRadius),
        ),
        elevation: tokens.elevation1.isEmpty ? 0 : 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.buttonRadius),
          ),
        ),
      ),
      extensions: [tokens],
    );
  }

  /// Parses `#RRGGBB` (opaque) or legacy `RRGGBB`. Returns primary purple
  /// on malformed input so UI never crashes.
  static Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
      if (clean.length == 8) {
        return Color(int.parse('0x$clean'));
      }
      return const Color(0xFF9333EA);
    } catch (_) {
      return const Color(0xFF9333EA);
    }
  }

  /// Parses `#AARRGGBB` (with alpha) or falls back to `_parseColor` for
  /// opaque 6-digit hex.
  static Color _parseColorWithAlpha(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 8) {
        return Color(int.parse('0x$clean'));
      }
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      }
      return const Color(0x14000000);
    } catch (_) {
      return const Color(0x14000000);
    }
  }
}
