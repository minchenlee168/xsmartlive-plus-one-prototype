import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/locale_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../widgets/back_leading_button.dart';

/// Language picker — lists every supported locale as a tappable card.
/// Selection is persisted via [LocaleNotifier] and the app re-localizes
/// immediately. Style mirrors [ThemePickerScreen] (card list, accent
/// border on the active row, native-name labels).
class LanguagePickerScreen extends ConsumerWidget {
  const LanguagePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final localeAsync = ref.watch(localeNotifierProvider);
    final activeTag = localeAsync.valueOrNull == null
        ? 'zh-TW'
        : localeTag(localeAsync.value!);

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        leading: const BackLeadingButton(fallbackLocation: '/settings'),
        backgroundColor: appTheme.bgElev,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          '語言 / Language',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: appTheme.fg,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: appTheme.spacingLg,
          vertical: appTheme.spacingMd,
        ),
        children: [
          for (final locale in supportedLocales) ...[
            _LanguageCard(
              tag: localeTag(locale),
              displayName: localeDisplayNames[localeTag(locale)] ??
                  localeTag(locale),
              selected: localeTag(locale) == activeTag,
              onTap: () => ref
                  .read(localeNotifierProvider.notifier)
                  .setLocale(locale),
            ),
            SizedBox(height: appTheme.spacingSm),
          ],
          SizedBox(height: appTheme.spacingXxxl),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.tag,
    required this.displayName,
    required this.selected,
    required this.onTap,
  });

  final String tag;
  final String displayName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = Theme.of(context).colorScheme.primary;
    final outlineColor = selected ? accent : appTheme.divider;
    return Material(
      color: appTheme.bgElev,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: outlineColor,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: appTheme.fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        color: appTheme.fgMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, size: 22, color: accent)
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: appTheme.divider),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
