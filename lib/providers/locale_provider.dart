import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

const supportedLocales = [
  Locale('zh', 'TW'),
  Locale('zh', 'CN'),
  Locale('en'),
  Locale('ja'),
  Locale('ko'),
  Locale('th'),
  Locale('ms'),
];

const localeDisplayNames = {
  'zh-TW': '繁體中文',
  'zh-CN': '简体中文',
  'en': 'English',
  'ja': '日本語',
  'ko': '한국어',
  'th': 'ภาษาไทย',
  'ms': 'Bahasa Malaysia',
};

String localeTag(Locale locale) =>
    locale.countryCode != null ? '${locale.languageCode}-${locale.countryCode}' : locale.languageCode;

Locale _parseTag(String tag) {
  final parts = tag.split('-');
  return parts.length >= 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
}

class LocaleNotifier extends AsyncNotifier<Locale> {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLocaleKey);
    if (saved == null) return const Locale('zh', 'TW');
    return _parseTag(saved);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, localeTag(locale));
    state = AsyncData(locale);
  }
}

final localeNotifierProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
