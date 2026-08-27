// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_theme_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteThemeModel _$RemoteThemeModelFromJson(Map<String, dynamic> json) =>
    _RemoteThemeModel(
      colors: RemoteColors.fromJson(json['colors'] as Map<String, dynamic>),
      typography: RemoteTypography.fromJson(
        json['typography'] as Map<String, dynamic>,
      ),
      shape: RemoteShape.fromJson(json['shape'] as Map<String, dynamic>),
      assets: RemoteAssets.fromJson(json['assets'] as Map<String, dynamic>),
      spacing: json['spacing'] == null
          ? null
          : RemoteSpacing.fromJson(json['spacing'] as Map<String, dynamic>),
      elevation: json['elevation'] == null
          ? null
          : RemoteElevation.fromJson(json['elevation'] as Map<String, dynamic>),
      brandPalette: json['brandPalette'] == null
          ? null
          : RemoteBrandPalette.fromJson(
              json['brandPalette'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$RemoteThemeModelToJson(_RemoteThemeModel instance) =>
    <String, dynamic>{
      'colors': instance.colors,
      'typography': instance.typography,
      'shape': instance.shape,
      'assets': instance.assets,
      'spacing': instance.spacing,
      'elevation': instance.elevation,
      'brandPalette': instance.brandPalette,
    };

_RemoteBrandPalette _$RemoteBrandPaletteFromJson(Map<String, dynamic> json) =>
    _RemoteBrandPalette(
      tone50: json['tone50'] as String? ?? '#F2EBFF',
      tone100: json['tone100'] as String? ?? '#E0D0FC',
      tone200: json['tone200'] as String? ?? '#C29FFA',
      tone300: json['tone300'] as String? ?? '#A370F7',
      tone400: json['tone400'] as String? ?? '#8441F5',
      tone500: json['tone500'] as String? ?? '#7008E7',
      tone600: json['tone600'] as String? ?? '#5218C2',
      tone700: json['tone700'] as String? ?? '#3D0F91',
      tone800: json['tone800'] as String? ?? '#290661',
      tone900: json['tone900'] as String? ?? '#270251',
      tone950: json['tone950'] as String? ?? '#130128',
    );

Map<String, dynamic> _$RemoteBrandPaletteToJson(_RemoteBrandPalette instance) =>
    <String, dynamic>{
      'tone50': instance.tone50,
      'tone100': instance.tone100,
      'tone200': instance.tone200,
      'tone300': instance.tone300,
      'tone400': instance.tone400,
      'tone500': instance.tone500,
      'tone600': instance.tone600,
      'tone700': instance.tone700,
      'tone800': instance.tone800,
      'tone900': instance.tone900,
      'tone950': instance.tone950,
    };

_RemoteColors _$RemoteColorsFromJson(Map<String, dynamic> json) =>
    _RemoteColors(
      primary: json['primary'] as String? ?? '#9333EA',
      onPrimary: json['onPrimary'] as String? ?? '#FFFFFF',
      secondary: json['secondary'] as String? ?? '#EC4899',
      surface: json['surface'] as String? ?? '#FFFFFF',
      background: json['background'] as String? ?? '#F9FAFB',
      error: json['error'] as String? ?? '#EF4444',
      success: json['success'] as String? ?? '#10B981',
      warning: json['warning'] as String? ?? '#F59E0B',
      info: json['info'] as String? ?? '#3B82F6',
      divider: json['divider'] as String? ?? '#E5E7EB',
      muted: json['muted'] as String? ?? '#9CA3AF',
      authGradientStart: json['authGradientStart'] as String? ?? '#64C6EC',
      authGradientEnd: json['authGradientEnd'] as String? ?? '#F032FF',
    );

Map<String, dynamic> _$RemoteColorsToJson(_RemoteColors instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'onPrimary': instance.onPrimary,
      'secondary': instance.secondary,
      'surface': instance.surface,
      'background': instance.background,
      'error': instance.error,
      'success': instance.success,
      'warning': instance.warning,
      'info': instance.info,
      'divider': instance.divider,
      'muted': instance.muted,
      'authGradientStart': instance.authGradientStart,
      'authGradientEnd': instance.authGradientEnd,
    };

_RemoteTypography _$RemoteTypographyFromJson(Map<String, dynamic> json) =>
    _RemoteTypography(
      fontFamily: json['fontFamily'] as String? ?? 'Noto Sans TC',
      headingSize: (json['headingSize'] as num?)?.toDouble() ?? 24.0,
      titleSize: (json['titleSize'] as num?)?.toDouble() ?? 16.0,
      bodySize: (json['bodySize'] as num?)?.toDouble() ?? 14.0,
      labelSize: (json['labelSize'] as num?)?.toDouble() ?? 12.0,
      captionSize: (json['captionSize'] as num?)?.toDouble() ?? 11.0,
    );

Map<String, dynamic> _$RemoteTypographyToJson(_RemoteTypography instance) =>
    <String, dynamic>{
      'fontFamily': instance.fontFamily,
      'headingSize': instance.headingSize,
      'titleSize': instance.titleSize,
      'bodySize': instance.bodySize,
      'labelSize': instance.labelSize,
      'captionSize': instance.captionSize,
    };

_RemoteShape _$RemoteShapeFromJson(Map<String, dynamic> json) => _RemoteShape(
  cardRadius: (json['cardRadius'] as num?)?.toDouble() ?? 12.0,
  buttonRadius: (json['buttonRadius'] as num?)?.toDouble() ?? 8.0,
  chipRadius: (json['chipRadius'] as num?)?.toDouble() ?? 8.0,
  dialogRadius: (json['dialogRadius'] as num?)?.toDouble() ?? 16.0,
  sheetRadius: (json['sheetRadius'] as num?)?.toDouble() ?? 20.0,
  avatarRadius: (json['avatarRadius'] as num?)?.toDouble() ?? 999.0,
);

Map<String, dynamic> _$RemoteShapeToJson(_RemoteShape instance) =>
    <String, dynamic>{
      'cardRadius': instance.cardRadius,
      'buttonRadius': instance.buttonRadius,
      'chipRadius': instance.chipRadius,
      'dialogRadius': instance.dialogRadius,
      'sheetRadius': instance.sheetRadius,
      'avatarRadius': instance.avatarRadius,
    };

_RemoteSpacing _$RemoteSpacingFromJson(Map<String, dynamic> json) =>
    _RemoteSpacing(
      xxs: (json['xxs'] as num?)?.toDouble() ?? 2.0,
      xs: (json['xs'] as num?)?.toDouble() ?? 4.0,
      sm: (json['sm'] as num?)?.toDouble() ?? 8.0,
      md: (json['md'] as num?)?.toDouble() ?? 12.0,
      lg: (json['lg'] as num?)?.toDouble() ?? 16.0,
      xl: (json['xl'] as num?)?.toDouble() ?? 20.0,
      xxl: (json['xxl'] as num?)?.toDouble() ?? 24.0,
      xxxl: (json['xxxl'] as num?)?.toDouble() ?? 32.0,
    );

Map<String, dynamic> _$RemoteSpacingToJson(_RemoteSpacing instance) =>
    <String, dynamic>{
      'xxs': instance.xxs,
      'xs': instance.xs,
      'sm': instance.sm,
      'md': instance.md,
      'lg': instance.lg,
      'xl': instance.xl,
      'xxl': instance.xxl,
      'xxxl': instance.xxxl,
    };

_RemoteElevation _$RemoteElevationFromJson(Map<String, dynamic> json) =>
    _RemoteElevation(
      level1Color: json['level1Color'] as String? ?? '#0A000000',
      level1Blur: (json['level1Blur'] as num?)?.toDouble() ?? 4.0,
      level1OffsetY: (json['level1OffsetY'] as num?)?.toDouble() ?? 1.0,
      level2Color: json['level2Color'] as String? ?? '#14000000',
      level2Blur: (json['level2Blur'] as num?)?.toDouble() ?? 8.0,
      level2OffsetY: (json['level2OffsetY'] as num?)?.toDouble() ?? 2.0,
      level3Color: json['level3Color'] as String? ?? '#1F000000',
      level3Blur: (json['level3Blur'] as num?)?.toDouble() ?? 16.0,
      level3OffsetY: (json['level3OffsetY'] as num?)?.toDouble() ?? 4.0,
    );

Map<String, dynamic> _$RemoteElevationToJson(_RemoteElevation instance) =>
    <String, dynamic>{
      'level1Color': instance.level1Color,
      'level1Blur': instance.level1Blur,
      'level1OffsetY': instance.level1OffsetY,
      'level2Color': instance.level2Color,
      'level2Blur': instance.level2Blur,
      'level2OffsetY': instance.level2OffsetY,
      'level3Color': instance.level3Color,
      'level3Blur': instance.level3Blur,
      'level3OffsetY': instance.level3OffsetY,
    };

_RemoteAssets _$RemoteAssetsFromJson(Map<String, dynamic> json) =>
    _RemoteAssets(
      logoUrl: json['logoUrl'] as String?,
      splashUrl: json['splashUrl'] as String?,
    );

Map<String, dynamic> _$RemoteAssetsToJson(_RemoteAssets instance) =>
    <String, dynamic>{
      'logoUrl': instance.logoUrl,
      'splashUrl': instance.splashUrl,
    };
