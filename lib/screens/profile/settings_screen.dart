import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../theme/app_theme_extension.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final localeAsync = ref.watch(localeNotifierProvider);
    final currentLocale = localeAsync.valueOrNull ?? const Locale('zh', 'TW');

    return Scaffold(
      backgroundColor: appTheme.bgSubtle,
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Language section ──────────────────────────────────────
          _SectionHeader(label: l10n.settingsSectionLanguage),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(appTheme.cardRadius)),
            color: Colors.white,
            child: Column(
              children: [
                for (int i = 0; i < supportedLocales.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                  _LanguageTile(
                    locale: supportedLocales[i],
                    isSelected: localeTag(supportedLocales[i]) ==
                        localeTag(currentLocale),
                    onTap: () => ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(supportedLocales[i]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── App info section ──────────────────────────────────────
          _SectionHeader(label: l10n.settingsSectionAbout),
          Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(appTheme.cardRadius)),
            color: Colors.white,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: appTheme.brandPalette.tone50,
                  borderRadius: BorderRadius.circular(appTheme.chipRadius),
                ),
                child: Icon(Icons.info_outline,
                    size: 20, color: appTheme.brandPalette.tone500),
              ),
              title: Text(l10n.settingsAppVersion),
              trailing: Text(
                _version.isEmpty ? '—' : '$_version (build $_buildNumber)',
                style: TextStyle(color: appTheme.fgMuted, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.appTheme.fgMuted,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tag = localeTag(locale);
    final displayName = localeDisplayNames[tag] ?? tag;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.appTheme.brandPalette.tone50,
          borderRadius: BorderRadius.circular(context.appTheme.chipRadius),
        ),
        child: Icon(Icons.language,
            size: 20, color: context.appTheme.brandPalette.tone500),
      ),
      title: Text(displayName),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: context.appTheme.brandPalette.tone500)
          : Icon(Icons.radio_button_unchecked,
              color: context.appTheme.muted),
      onTap: onTap,
    );
  }
}
