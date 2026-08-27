# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run by flavor
flutter run --flavor merchantA -t lib/main_merchant_a.dart
flutter run --flavor merchantB -t lib/main_merchant_b.dart
flutter run --flavor merchantC -t lib/main_merchant_c.dart

# Build APK
flutter build apk --flavor merchantA -t lib/main_merchant_a.dart

# Regenerate Freezed models & JSON serialization (required after model changes)
flutter pub run build_runner build

# Static analysis
flutter analyze
```

**iOS**: Requires manually creating 3 Schemes in Xcode (merchantA/merchantB/merchantC), each pointing to `ios/Flutter/MerchantX.xcconfig`.

**Mock login**: Any non-empty account + password works in current implementation.

## Architecture

**MVVM + Riverpod + go_router**. Three entry points (`main_merchant_a/b/c.dart`) each initialize `FlavorConfig` (singleton) before `runApp()`.

### Layer Stack

```
lib/
├── config/           # FlavorConfig singleton + API endpoint constants
├── core/errors/      # Sealed AppException hierarchy
├── models/           # Freezed immutable models (User, Product, LiveStream, etc.)
├── data/
│   ├── dio_client.dart          # HTTP + auth interceptor (token injection + 401 refresh)
│   ├── token_storage.dart       # flutter_secure_storage wrapper
│   ├── theme_cache_storage.dart # shared_preferences wrapper
│   └── repositories/            # HTTP/storage abstraction (auth, theme, live, product)
├── theme/            # Remote theme: JSON → ThemeData pipeline
├── providers/        # Riverpod: repositories → notifiers → UI
├── router/           # go_router with auth redirect guard
└── screens/          # UI (login, live, shop, favorites, notifications, profile)
```

### Provider Dependency Chain

```
tokenStorage → dioClient → repositories → notifiers (auth/theme/product/live)
```

All providers are wired in `lib/providers/repository_providers.dart`.

### Flavor System (Compile-time)

Each flavor has its own `applicationId`, `baseUrl`, `merchantId`, and `appName`. Configured in:
- Android: `android/app/build.gradle.kts` (productFlavors block)
- iOS: `ios/Flutter/MerchantX.xcconfig`
- Dart: `lib/config/flavor_config.dart` (runtime singleton)

### Remote Theme System (Runtime)

1. `ThemeNotifier` loads cached theme from SharedPreferences immediately (cache-first)
2. Fetches fresh theme from `/theme/{merchantId}` in background (no auth required)
3. `ThemeState` is a sealed class: `initial → loading → cached/loaded/error`
4. `RemoteThemeBuilder` converts API JSON → `ThemeData`
5. `AppThemeExtension` exposes `context.appTheme` for brand colors

### Auth Flow

- `DioClient` auth interceptor injects `Bearer` token on every request; on 401 attempts token refresh, then clears tokens on failure
- `AuthNotifier` (AsyncNotifier): mock login delays 500ms; real path POSTs to `/auth/login`
- Route guard: unauthenticated → `/login`; authenticated on `/login` → `/live`

### Key Patterns

- **Immutable models**: All models use Freezed (`copyWith`, equality, JSON). Run `build_runner` after changes.
- **Sealed exceptions**: `AppException` → `NetworkException / UnauthorizedException / ServerException / CacheException / UnknownException`
- **Cart**: Client-side only `CartNotifier` (Riverpod Notifier); no server sync yet
- **API endpoints**: All derived dynamically from `FlavorConfig` via `ApiConstants` static getters — never hardcoded strings

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management (Notifier/AsyncNotifier) |
| `go_router` | Routing + auth guards |
| `dio` | HTTP client |
| `freezed` | Immutable models + code generation |
| `flutter_secure_storage` | Encrypted JWT storage |
| `shared_preferences` | Theme JSON cache |
| `video_player` + `chewie` | Livestream playback |

## What's Not Yet Implemented

- No tests (only skeleton `test/widget_test.dart`)
- Cart is client-side only (no server sync)
- Auth uses mock data; real API integration is stubbed
