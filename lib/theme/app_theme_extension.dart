import 'dart:ui';

import 'package:flutter/material.dart';

/// White-label design tokens exposed via `Theme.of(context).extension`.
///
/// ### Architecture
/// All visual tokens (colors, spacing, radii, elevation, fonts) are sourced
/// through this extension — never hardcoded at call sites.
///
/// Fallback order when building the extension in `RemoteThemeBuilder`:
///   1. Local preset (selected by user via theme picker)  — highest priority
///   2. Remote theme JSON (`/theme/{id}`)                  — merchant default
///   3. Flavor-specific defaults                           — per-merchant overrides
///   4. Global baseline defaults defined here              — fallback
///
/// Call from UI:
/// ```dart
/// context.appTheme.spacingLg          // padding
/// context.appTheme.success            // semantic color
/// context.appTheme.elevation1         // drop shadow
/// context.appTheme.dialogRadius       // rounded corner
/// context.appTheme.bgSubtle           // subtle background fill
/// context.appTheme.fontDisplay        // headline font family name
/// ```
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    // ── Assets ────────────────────────────────────────────────
    this.logoUrl,
    this.splashUrl,

    // ── Radii ─────────────────────────────────────────────────
    this.cardRadius = 12.0,
    this.buttonRadius = 8.0,
    this.chipRadius = 8.0,
    this.dialogRadius = 16.0,
    this.sheetRadius = 20.0,
    this.avatarRadius = 999.0,
    this.radiusSm = 4.0,
    this.radiusLg = 24.0,

    // ── Gradient ──────────────────────────────────────────────
    this.gradientColors = const [Color(0xFF9333EA), Color(0xFFEC4899)],

    // ── Brand tonal palette ──────────────────────────────────
    // 11-stop palette mirroring the Figma design system reference
    // (SmartLive). Each merchant should override these via
    // `/theme/{id}` JSON to keep tone-derived UI (coupon panels,
    // tag chips, button states) on-brand under white-label.
    this.brandPalette = const BrandPalette(
      tone50: Color(0xFFF2EBFF),
      tone100: Color(0xFFE0D0FC),
      tone200: Color(0xFFC29FFA),
      tone300: Color(0xFFA370F7),
      tone400: Color(0xFF8441F5),
      tone500: Color(0xFF7008E7),
      tone600: Color(0xFF5218C2),
      tone700: Color(0xFF3D0F91),
      tone800: Color(0xFF290661),
      tone900: Color(0xFF270251),
      tone950: Color(0xFF130128),
    ),

    // Auth page (login / register / forgot-password) background decoration
    // gradient. Rendered as radial blobs on the page — separate from the
    // brand primary gradient so auth pages can carry their own visual accent.
    this.authPageGradient = const [Color(0xFF64C6EC), Color(0xFFF032FF)],

    // ── Surface palette (prototype: bg / bgElev / bgSubtle / fg / fgMuted) ──
    // Mirrors the React prototype's per-theme surface tokens. Defaults match
    // a neutral light scheme so widgets that adopt these tokens pre-Diva
    // continue to look correct.
    this.bg = const Color(0xFFFAFAFA),
    this.bgElev = const Color(0xFFFFFFFF),
    this.bgSubtle = const Color(0xFFF3F4F6),
    this.fg = const Color(0xFF1F2937),
    this.fgMuted = const Color(0xFF6B7280),
    this.chip = const Color(0xFFF3F4F6),
    this.chipFg = const Color(0xFF374151),
    this.accent = const Color(0xFFEC4899),
    this.danger = const Color(0xFFEF4444),

    // ── Extended semantic colors ──────────────────────────────
    this.success = const Color(0xFF10B981),
    this.warning = const Color(0xFFF59E0B),
    this.info = const Color(0xFF3B82F6),
    this.divider = const Color(0xFFE5E7EB),
    this.muted = const Color(0xFF9CA3AF),

    // ── Typography family + display weight ────────────────────
    // `fontDisplay` and `fontBody` are *Google Fonts family names*
    // (e.g. "Cormorant Garamond", "Noto Sans TC", "Playfair Display").
    // Resolve to TextStyle via `GoogleFonts.getFont(family)` at the
    // call site, or via the ThemeData.textTheme already wired by
    // RemoteThemeBuilder.
    this.fontDisplay = 'Noto Sans TC',
    this.fontBody = 'Noto Sans TC',
    this.fontWeightDisplay = FontWeight.w700,

    // ── Spacing scale (4-pt base, semantic names) ─────────────
    this.spacingXxs = 2.0,
    this.spacingXs = 4.0,
    this.spacingSm = 8.0,
    this.spacingMd = 12.0,
    this.spacingLg = 16.0,
    this.spacingXl = 20.0,
    this.spacingXxl = 24.0,
    this.spacingXxxl = 32.0,

    // ── Elevation shadows ─────────────────────────────────────
    this.elevation1 = const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ],
    this.elevation2 = const [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
    this.elevation3 = const [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],

    // ── Status bar contrast ──────────────────────────────────
    // True for dark themes (use light status bar icons).
    this.isDarkSurface = false,
  });

  // Assets
  final String? logoUrl;

  /// In-app splash only — native splash is set per-flavor at compile time.
  final String? splashUrl;

  // Radii
  final double cardRadius;
  final double buttonRadius;
  final double chipRadius;
  final double dialogRadius;
  final double sheetRadius;
  final double avatarRadius;
  final double radiusSm;
  final double radiusLg;

  // Gradient
  final List<Color> gradientColors;

  /// Auth page background decoration gradient (e.g. register / login screens).
  /// Rendered as soft radial blobs at page corners.
  final List<Color> authPageGradient;

  /// 11-tone brand palette (50/100/200/300/400/500/600/700/800/900/950).
  /// Mirrors the Figma design-system reference so UI that needs specific
  /// tones (e.g. coupon panel backgrounds, tag chips) stays on-brand
  /// without HSL approximation. Access tones via `palette.tone500` etc.
  final BrandPalette brandPalette;

  // Surface palette (parallel to ColorScheme but with semantic prototype names)
  final Color bg;
  final Color bgElev;
  final Color bgSubtle;
  final Color fg;
  final Color fgMuted;
  final Color chip;
  final Color chipFg;
  final Color accent;
  final Color danger;

  // Extended semantic colors
  final Color success;
  final Color warning;
  final Color info;
  final Color divider;
  final Color muted;

  // Typography
  final String fontDisplay;
  final String fontBody;
  final FontWeight fontWeightDisplay;

  // Spacing
  final double spacingXxs;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;
  final double spacingXxxl;

  // Elevation
  final List<BoxShadow> elevation1;
  final List<BoxShadow> elevation2;
  final List<BoxShadow> elevation3;

  // Surface mode hint
  final bool isDarkSurface;

  LinearGradient get primaryGradient => LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  AppThemeExtension copyWith({
    String? logoUrl,
    String? splashUrl,
    double? cardRadius,
    double? buttonRadius,
    double? chipRadius,
    double? dialogRadius,
    double? sheetRadius,
    double? avatarRadius,
    double? radiusSm,
    double? radiusLg,
    List<Color>? gradientColors,
    List<Color>? authPageGradient,
    BrandPalette? brandPalette,
    Color? bg,
    Color? bgElev,
    Color? bgSubtle,
    Color? fg,
    Color? fgMuted,
    Color? chip,
    Color? chipFg,
    Color? accent,
    Color? danger,
    Color? success,
    Color? warning,
    Color? info,
    Color? divider,
    Color? muted,
    String? fontDisplay,
    String? fontBody,
    FontWeight? fontWeightDisplay,
    double? spacingXxs,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
    double? spacingXxxl,
    List<BoxShadow>? elevation1,
    List<BoxShadow>? elevation2,
    List<BoxShadow>? elevation3,
    bool? isDarkSurface,
  }) {
    return AppThemeExtension(
      logoUrl: logoUrl ?? this.logoUrl,
      splashUrl: splashUrl ?? this.splashUrl,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      dialogRadius: dialogRadius ?? this.dialogRadius,
      sheetRadius: sheetRadius ?? this.sheetRadius,
      avatarRadius: avatarRadius ?? this.avatarRadius,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusLg: radiusLg ?? this.radiusLg,
      gradientColors: gradientColors ?? this.gradientColors,
      authPageGradient: authPageGradient ?? this.authPageGradient,
      brandPalette: brandPalette ?? this.brandPalette,
      bg: bg ?? this.bg,
      bgElev: bgElev ?? this.bgElev,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      fg: fg ?? this.fg,
      fgMuted: fgMuted ?? this.fgMuted,
      chip: chip ?? this.chip,
      chipFg: chipFg ?? this.chipFg,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      divider: divider ?? this.divider,
      muted: muted ?? this.muted,
      fontDisplay: fontDisplay ?? this.fontDisplay,
      fontBody: fontBody ?? this.fontBody,
      fontWeightDisplay: fontWeightDisplay ?? this.fontWeightDisplay,
      spacingXxs: spacingXxs ?? this.spacingXxs,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
      spacingXxxl: spacingXxxl ?? this.spacingXxxl,
      elevation1: elevation1 ?? this.elevation1,
      elevation2: elevation2 ?? this.elevation2,
      elevation3: elevation3 ?? this.elevation3,
      isDarkSurface: isDarkSurface ?? this.isDarkSurface,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      logoUrl: t < 0.5 ? logoUrl : other.logoUrl,
      splashUrl: t < 0.5 ? splashUrl : other.splashUrl,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t)!,
      buttonRadius: lerpDouble(buttonRadius, other.buttonRadius, t)!,
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t)!,
      dialogRadius: lerpDouble(dialogRadius, other.dialogRadius, t)!,
      sheetRadius: lerpDouble(sheetRadius, other.sheetRadius, t)!,
      avatarRadius: lerpDouble(avatarRadius, other.avatarRadius, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      gradientColors: [
        Color.lerp(gradientColors[0], other.gradientColors[0], t)!,
        Color.lerp(
          gradientColors.length > 1 ? gradientColors[1] : gradientColors[0],
          other.gradientColors.length > 1
              ? other.gradientColors[1]
              : other.gradientColors[0],
          t,
        )!,
      ],
      authPageGradient: [
        Color.lerp(authPageGradient[0], other.authPageGradient[0], t)!,
        Color.lerp(
          authPageGradient.length > 1
              ? authPageGradient[1]
              : authPageGradient[0],
          other.authPageGradient.length > 1
              ? other.authPageGradient[1]
              : other.authPageGradient[0],
          t,
        )!,
      ],
      brandPalette: BrandPalette.lerp(brandPalette, other.brandPalette, t),
      bg: Color.lerp(bg, other.bg, t)!,
      bgElev: Color.lerp(bgElev, other.bgElev, t)!,
      bgSubtle: Color.lerp(bgSubtle, other.bgSubtle, t)!,
      fg: Color.lerp(fg, other.fg, t)!,
      fgMuted: Color.lerp(fgMuted, other.fgMuted, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      chipFg: Color.lerp(chipFg, other.chipFg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      fontDisplay: t < 0.5 ? fontDisplay : other.fontDisplay,
      fontBody: t < 0.5 ? fontBody : other.fontBody,
      fontWeightDisplay:
          t < 0.5 ? fontWeightDisplay : other.fontWeightDisplay,
      spacingXxs: lerpDouble(spacingXxs, other.spacingXxs, t)!,
      spacingXs: lerpDouble(spacingXs, other.spacingXs, t)!,
      spacingSm: lerpDouble(spacingSm, other.spacingSm, t)!,
      spacingMd: lerpDouble(spacingMd, other.spacingMd, t)!,
      spacingLg: lerpDouble(spacingLg, other.spacingLg, t)!,
      spacingXl: lerpDouble(spacingXl, other.spacingXl, t)!,
      spacingXxl: lerpDouble(spacingXxl, other.spacingXxl, t)!,
      spacingXxxl: lerpDouble(spacingXxxl, other.spacingXxxl, t)!,
      elevation1: t < 0.5 ? elevation1 : other.elevation1,
      elevation2: t < 0.5 ? elevation2 : other.elevation2,
      elevation3: t < 0.5 ? elevation3 : other.elevation3,
      isDarkSurface: t < 0.5 ? isDarkSurface : other.isDarkSurface,
    );
  }
}

/// 11-tone brand palette (Material-style 50–950 ramp). Mirrors the Figma
/// design-system reference; defaults are the SmartLive purple ramp.
@immutable
class BrandPalette {
  const BrandPalette({
    required this.tone50,
    required this.tone100,
    required this.tone200,
    required this.tone300,
    required this.tone400,
    required this.tone500,
    required this.tone600,
    required this.tone700,
    required this.tone800,
    required this.tone900,
    required this.tone950,
  });

  final Color tone50;
  final Color tone100;
  final Color tone200;
  final Color tone300;
  final Color tone400;
  final Color tone500;
  final Color tone600;
  final Color tone700;
  final Color tone800;
  final Color tone900;
  final Color tone950;

  static BrandPalette lerp(BrandPalette a, BrandPalette b, double t) {
    return BrandPalette(
      tone50: Color.lerp(a.tone50, b.tone50, t)!,
      tone100: Color.lerp(a.tone100, b.tone100, t)!,
      tone200: Color.lerp(a.tone200, b.tone200, t)!,
      tone300: Color.lerp(a.tone300, b.tone300, t)!,
      tone400: Color.lerp(a.tone400, b.tone400, t)!,
      tone500: Color.lerp(a.tone500, b.tone500, t)!,
      tone600: Color.lerp(a.tone600, b.tone600, t)!,
      tone700: Color.lerp(a.tone700, b.tone700, t)!,
      tone800: Color.lerp(a.tone800, b.tone800, t)!,
      tone900: Color.lerp(a.tone900, b.tone900, t)!,
      tone950: Color.lerp(a.tone950, b.tone950, t)!,
    );
  }
}

extension AppThemeExtensionContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ??
      const AppThemeExtension();
}
