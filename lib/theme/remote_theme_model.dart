import 'package:freezed_annotation/freezed_annotation.dart';

part 'remote_theme_model.freezed.dart';
part 'remote_theme_model.g.dart';

/// Remote white-label theme payload returned from `/theme/{id}`.
///
/// Every field is optional on the wire (thanks to `@Default`) so when the
/// backend hasn't shipped a token yet, the baseline default is used.
/// `spacing` / `elevation` / `brandPalette` are nullable — absent JSON keys
/// just fall back to [AppThemeExtension] baseline defaults in
/// `RemoteThemeBuilder`.
@freezed
abstract class RemoteThemeModel with _$RemoteThemeModel {
  const factory RemoteThemeModel({
    required RemoteColors colors,
    required RemoteTypography typography,
    required RemoteShape shape,
    required RemoteAssets assets,
    RemoteSpacing? spacing,
    RemoteElevation? elevation,
    RemoteBrandPalette? brandPalette,
  }) = _RemoteThemeModel;

  factory RemoteThemeModel.fromJson(Map<String, dynamic> json) =>
      _$RemoteThemeModelFromJson(json);
}

/// 11-tone brand palette (50/100/200/300/400/500/600/700/800/900/950).
/// Defaults mirror the Figma reference (SmartLive purple ramp) so the
/// app renders correctly when the backend hasn't shipped this section yet.
/// Once the backend returns `brandPalette`, the merchant's ramp replaces
/// these defaults.
@freezed
abstract class RemoteBrandPalette with _$RemoteBrandPalette {
  const factory RemoteBrandPalette({
    @Default('#F2EBFF') String tone50,
    @Default('#E0D0FC') String tone100,
    @Default('#C29FFA') String tone200,
    @Default('#A370F7') String tone300,
    @Default('#8441F5') String tone400,
    @Default('#7008E7') String tone500,
    @Default('#5218C2') String tone600,
    @Default('#3D0F91') String tone700,
    @Default('#290661') String tone800,
    @Default('#270251') String tone900,
    @Default('#130128') String tone950,
  }) = _RemoteBrandPalette;

  factory RemoteBrandPalette.fromJson(Map<String, dynamic> json) =>
      _$RemoteBrandPaletteFromJson(json);
}

@freezed
abstract class RemoteColors with _$RemoteColors {
  const factory RemoteColors({
    // `primary` / `onPrimary` are LEGACY fields retained for schema
    // backward-compat. The effective brand primary is now
    // `brandPalette.tone500`, and `onPrimary` is always white. New merchants
    // should configure brand colours via `brandPalette` (11-tone ramp).
    @Default('#9333EA') String primary,
    @Default('#FFFFFF') String onPrimary,
    @Default('#EC4899') String secondary,
    @Default('#FFFFFF') String surface,
    @Default('#F9FAFB') String background,
    @Default('#EF4444') String error,
    // Extended semantic colors
    @Default('#10B981') String success,
    @Default('#F59E0B') String warning,
    @Default('#3B82F6') String info,
    @Default('#E5E7EB') String divider,
    @Default('#9CA3AF') String muted,
    // Auth page decorative gradient (login / register / forgot password).
    // Separate from [primary]/[secondary] so auth pages can carry their own
    // accent without tying it to the brand primary.
    @Default('#64C6EC') String authGradientStart,
    @Default('#F032FF') String authGradientEnd,
  }) = _RemoteColors;

  factory RemoteColors.fromJson(Map<String, dynamic> json) =>
      _$RemoteColorsFromJson(json);
}

@freezed
abstract class RemoteTypography with _$RemoteTypography {
  const factory RemoteTypography({
    @Default('Noto Sans TC') String fontFamily,
    @Default(24.0) double headingSize,
    @Default(16.0) double titleSize,
    @Default(14.0) double bodySize,
    @Default(12.0) double labelSize,
    @Default(11.0) double captionSize,
  }) = _RemoteTypography;

  factory RemoteTypography.fromJson(Map<String, dynamic> json) =>
      _$RemoteTypographyFromJson(json);
}

@freezed
abstract class RemoteShape with _$RemoteShape {
  const factory RemoteShape({
    @Default(12.0) double cardRadius,
    @Default(8.0) double buttonRadius,
    @Default(8.0) double chipRadius,
    @Default(16.0) double dialogRadius,
    @Default(20.0) double sheetRadius,
    @Default(999.0) double avatarRadius,
  }) = _RemoteShape;

  factory RemoteShape.fromJson(Map<String, dynamic> json) =>
      _$RemoteShapeFromJson(json);
}

/// 4-pt-based spacing scale. Semantic names keep Figma → code mapping stable
/// even if a brand overrides the absolute numbers.
@freezed
abstract class RemoteSpacing with _$RemoteSpacing {
  const factory RemoteSpacing({
    @Default(2.0) double xxs,
    @Default(4.0) double xs,
    @Default(8.0) double sm,
    @Default(12.0) double md,
    @Default(16.0) double lg,
    @Default(20.0) double xl,
    @Default(24.0) double xxl,
    @Default(32.0) double xxxl,
  }) = _RemoteSpacing;

  factory RemoteSpacing.fromJson(Map<String, dynamic> json) =>
      _$RemoteSpacingFromJson(json);
}

/// Elevation tokens stored as ARGB hex (`#AARRGGBB`) + blur + vertical offset.
/// Horizontal offset is assumed 0 for white-label simplicity.
@freezed
abstract class RemoteElevation with _$RemoteElevation {
  const factory RemoteElevation({
    @Default('#0A000000') String level1Color,
    @Default(4.0) double level1Blur,
    @Default(1.0) double level1OffsetY,
    @Default('#14000000') String level2Color,
    @Default(8.0) double level2Blur,
    @Default(2.0) double level2OffsetY,
    @Default('#1F000000') String level3Color,
    @Default(16.0) double level3Blur,
    @Default(4.0) double level3OffsetY,
  }) = _RemoteElevation;

  factory RemoteElevation.fromJson(Map<String, dynamic> json) =>
      _$RemoteElevationFromJson(json);
}

@freezed
abstract class RemoteAssets with _$RemoteAssets {
  const factory RemoteAssets({
    String? logoUrl,
    String? splashUrl,
  }) = _RemoteAssets;

  factory RemoteAssets.fromJson(Map<String, dynamic> json) =>
      _$RemoteAssetsFromJson(json);
}
