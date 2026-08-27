import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../theme/remote_theme_model.dart';

class ThemeCacheStorage {
  static const String _prefix = 'theme_cache_';

  Future<RemoteThemeModel?> read(String merchantId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_prefix$merchantId');
    if (json == null) return null;
    try {
      return RemoteThemeModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String merchantId, RemoteThemeModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix$merchantId',
      jsonEncode(model.toJson()),
    );
  }

  Future<void> clear(String merchantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$merchantId');
  }
}
