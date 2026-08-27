import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the last-known [User] JSON so [AuthRepository.restoreUser]
/// can rebuild the Dart object without a round-trip on every cold start.
/// Session validity is verified separately via the [mallIsLogin] endpoint.
class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _userKey = 'user_data';

  Future<void> saveUser(String userJson) =>
      _storage.write(key: _userKey, value: userJson);

  Future<String?> readUser() => _storage.read(key: _userKey);

  Future<void> clearUser() => _storage.delete(key: _userKey);

  /// Alias kept so call-sites that used [clearTokens] still compile.
  Future<void> clearTokens() => clearUser();
}
