import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/preset_theme_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../theme/preset_themes.dart';

/// Lets the user choose between the 6 built-in preset themes (warm /
/// minimal / vibrant / ecom / night / diva) or revert to the merchant's
/// remote theme. Selection is persisted via [PresetThemeNotifier] and the
/// app re-themes immediately on tap (no restart needed).
class ThemePickerScreen extends ConsumerWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final activePreset = ref.watch(activePresetProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themePickerTitle),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: appTheme.spacingLg,
          vertical: appTheme.spacingMd,
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: appTheme.spacingXs,
              vertical: appTheme.spacingSm,
            ),
            child: Text(
              l10n.themePickerDescription,
              style: TextStyle(
                fontSize: 13,
                color: appTheme.fgMuted,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: appTheme.spacingMd),

          // ── Section: Presets ──────────────────────────────────────
          _SectionLabel(text: l10n.themePickerSectionPresets),
          SizedBox(height: appTheme.spacingSm),
          ...PresetId.values.map((id) {
            final preset = kPresetThemes[id]!;
            return Padding(
              padding: EdgeInsets.only(bottom: appTheme.spacingSm),
              child: _PresetCard(
                preset: preset,
                selected: activePreset == id,
                label: _localizedPresetLabel(l10n, id),
                onTap: () =>
                    ref.read(presetThemeProvider.notifier).setPreset(id),
              ),
            );
          }),

          SizedBox(height: appTheme.spacingLg),

          // ── Section: Merchant default reset ───────────────────────
          _SectionLabel(text: l10n.themePickerSectionDefault),
          SizedBox(height: appTheme.spacingSm),
          _MerchantDefaultCard(
            selected: activePreset == null,
            label: l10n.themePickerOptionMerchant,
            description: l10n.themePickerOptionMerchantDesc,
            onTap: () =>
                ref.read(presetThemeProvider.notifier).setPreset(null),
          ),

          SizedBox(height: appTheme.spacingXxxl),
        ],
      ),
    );
  }

  String _localizedPresetLabel(AppLocalizations l10n, PresetId id) {
    switch (id) {
      case PresetId.warm:
        return l10n.themeWarm;
      case PresetId.minimal:
        return l10n.themeMinimal;
      case PresetId.vibrant:
        return l10n.themeVibrant;
      case PresetId.ecom:
        return l10n.themeEcom;
      case PresetId.night:
        return l10n.themeNight;
      case PresetId.diva:
        return l10n.themeDiva;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: appTheme.spacingXs),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: appTheme.fgMuted,
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final PresetTheme preset;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final tokens = preset.tokens;
    final outlineColor = selected
        ? Theme.of(context).colorScheme.primary
        : appTheme.divider;

    return Material(
      color: appTheme.bgElev,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: outlineColor,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(appTheme.spacingLg),
          child: Row(
            children: [
              // Swatch — gradient + tone dots preview
              _PresetSwatch(preset: preset),
              SizedBox(width: appTheme.spacingLg),
              // Name + en subtitle + (optional) "currently applied" hint
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: appTheme.fg,
                      ),
                    ),
                    SizedBox(height: appTheme.spacingXxs),
                    Text(
                      preset.nameEn,
                      style: TextStyle(
                        fontSize: 12,
                        color: appTheme.fgMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (selected) ...[
                      SizedBox(height: appTheme.spacingXs),
                      Text(
                        AppLocalizations.of(context)!.themeCurrentlyApplied,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: tokens.brandPalette.tone500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: appTheme.muted,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetSwatch extends StatelessWidget {
  const _PresetSwatch({required this.preset});
  final PresetTheme preset;

  @override
  Widget build(BuildContext context) {
    final tokens = preset.tokens;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: preset.previewGradient,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: const Color(0x1F000000)),
      ),
      child: Stack(
        children: [
          // Three corner-tone dots showing the surface palette
          Positioned(
            left: 6,
            bottom: 6,
            child: _ToneDot(color: tokens.bgSubtle),
          ),
          Positioned(
            right: 6,
            bottom: 6,
            child: _ToneDot(color: tokens.accent),
          ),
        ],
      ),
    );
  }
}

class _ToneDot extends StatelessWidget {
  const _ToneDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.2),
      ),
    );
  }
}

class _MerchantDefaultCard extends StatelessWidget {
  const _MerchantDefaultCard({
    required this.selected,
    required this.label,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final outlineColor = selected
        ? Theme.of(context).colorScheme.primary
        : appTheme.divider;

    return Material(
      color: appTheme.bgElev,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: outlineColor,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(appTheme.spacingLg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: appTheme.bgSubtle,
                  borderRadius:
                      BorderRadius.circular(appTheme.cardRadius),
                  border: Border.all(color: appTheme.divider),
                ),
                child: Icon(Icons.storefront_outlined,
                    color: appTheme.fgMuted, size: 28),
              ),
              SizedBox(width: appTheme.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: appTheme.fg,
                      ),
                    ),
                    SizedBox(height: appTheme.spacingXxs),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: appTheme.fgMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: appTheme.muted,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
