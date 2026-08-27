import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'repository_providers.dart';

/// Becomes true when the server session expires mid-session.
/// Reset to false after the user acknowledges the dialog.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // Subscribe to session-expiry events from the Dio interceptor.
    final sessionService = ref.watch(sessionServiceProvider);
    final sub = sessionService.sessionExpiredStream.listen((_) {
      _onSessionExpired();
    });
    ref.onDispose(sub.cancel);

    return ref.read(authRepositoryProvider).restoreUser();
  }

  void _onSessionExpired() {
    // Only fire when we are in a confirmed-logged-in AsyncData state.
    // Prevents false logouts during the initial loading phase or when the
    // user is already on the login screen (unauthenticated API calls that
    // return code 40000 must not trigger a redundant logout).
    if (state is! AsyncData) return;
    if (state.valueOrNull == null) return;
    state = const AsyncData(null);
    ref.read(sessionExpiredProvider.notifier).state = true;
  }

  Future<void> login({
    required String mobile,
    required String password,
    String captcha = '',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            mobile: mobile,
            password: password,
            captcha: captcha,
          ),
    );
  }

  /// Returns true on success. On failure, [state] carries the error.
  Future<bool> register({
    required String name,
    required String country,
    required String mobile,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncLoading();
    bool success = false;
    state = await AsyncValue.guard(() async {
      success = await ref.read(authRepositoryProvider).register(
            name: name,
            country: country,
            mobile: mobile,
            otp: otp,
            password: password,
            confirmPassword: confirmPassword,
          );
      return null; // Registration does not auto-login.
    });
    return success;
  }

  /// Signs in with Facebook (native SDK → login_type 2 / FB ASID).
  Future<void> facebookLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).facebookLogin(),
    );
  }

  /// Signs in with Google (native SDK → login_type 4).
  Future<void> googleLogin() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).googleLogin(),
    );
  }

  /// Completes a server-side OAuth flow after the WebView intercepts the
  /// provider's callback redirect (used for LINE and TikTok).
  Future<void> completeServerCallback(String callbackUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).completeServerCallback(callbackUrl),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).valueOrNull != null;
});
