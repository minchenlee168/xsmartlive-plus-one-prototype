# CLAUDE.md - Mall Template Project

## Core Tech
**MVVM + Riverpod + go_router + Freezed**. Multi-tenant system with compile-time Flavors & runtime Remote Themes.

## Common Commands
- **Run**: `flutter run --flavor [merchantA|B|C] -t lib/main_merchant_[a|b|c].dart`
- **Build**: `flutter build apk --flavor merchantA -t lib/main_merchant_a.dart`
- **Codegen**: `dart run build_runner build --delete-conflicting-outputs`

## Project Logic
- **Flavors**: `FlavorConfig` (singleton) holds `baseUrl`, `merchantId`. Setup in `build.gradle` & `.xcconfig`.
- **Theme**: `ThemeNotifier` (Async) loads cached JSON via SharedPreferences -> Fetches from `/theme/{id}` -> `RemoteThemeBuilder` converts to `ThemeData`.
- **Networking**: `DioClient` handles Laravel session & 401 refresh via `token_storage`.
- **Auth**: `AuthNotifier` guards routes. Unauth -> `/login`, Auth -> `/live`.
- **Models**: Use `Freezed`. Run codegen after model changes.

## Directory Guide
- `lib/config/`: Flavor & API constants.
- `lib/theme/`: JSON-to-Theme pipeline.
- `lib/data/`: Dio, Storage, & Repositories.
- `lib/providers/`: Notifiers & DI wiring.
- `lib/screens/`: Live, Shop (含 checkout/cart), Login, Profile, Favorites, Coupons, Notifications, Search.

## Platform Requirements
- **Android & iOS 都必須保持可運行。**
- Android: `android/app/build.gradle.kts`，3 個 productFlavors (merchantA/B/C)。
- iOS: `ios/Flutter/` 下有 MerchantA/B/C.xcconfig，需在 Xcode 建立對應 3 個 Schemes。

## Key Patterns
- **Immutable models**: 所有 model 使用 Freezed。修改 model 後必須跑 codegen。
- **Sealed exceptions**: `AppException` → `NetworkException / UnauthorizedException / ServerException / CacheException / UnknownException`
- **API endpoints**: 透過 `ApiConstants` static getters 從 `FlavorConfig` 組成，不可硬編碼。
- **Cart 雙系統**: `cartProvider`（`CartNotifier`，in-memory，UI 快速操作）與 `cartApiProvider`（`CartApiNotifier`，server-synced）並存。`cartCountProvider` 以 server 資料為主。

## 多國語言 (i18n)

- **套件**：`flutter_localizations` + `intl`，使用 Flutter 官方 ARB 工作流。
- **設定檔**：`l10n.yaml`（template: `app_en.arb`，output: `lib/l10n/app_localizations.dart`）。
- **ARB 目錄**：`lib/l10n/`，每個語系一支 `.arb` 檔。
- **支援語系**（`lib/providers/locale_provider.dart` → `supportedLocales`）：

  | Locale | 顯示名稱 | 檔案 |
  |--------|----------|------|
  | `zh-TW` | 繁體中文 | `app_zh_TW.arb` |
  | `zh-CN` | 简体中文 | `app_zh_CN.arb` |
  | `zh` | 繁體中文（fallback） | `app_zh.arb` |
  | `en` | English | `app_en.arb` |
  | `ja` | 日本語 | `app_ja.arb` |
  | `ko` | 한국어 | `app_ko.arb` |
  | `th` | ภาษาไทย | `app_th.arb` |
  | `ms` | Bahasa Malaysia | `app_ms.arb` |

- **Locale 狀態**：`LocaleNotifier`（AsyncNotifier）存入 `SharedPreferences`，key = `app_locale`，預設 `zh-TW`。
- **注入**：`lib/app.dart` 的 `MaterialApp.router` 讀取 `localeNotifierProvider`，設定 `locale` 與 `supportedLocales`。
- **使用方式**：`final l10n = AppLocalizations.of(context)!;`，所有 UI 字串透過 `l10n.keyName` 取得。
- **新增語系步驟**：
  1. 建立 `lib/l10n/app_<locale>.arb`，複製所有 key 並翻譯。
  2. 在 `locale_provider.dart` 的 `supportedLocales` 加入 `Locale(...)` 並在 `localeDisplayNames` 加上顯示名稱。
  3. 執行 `flutter gen-l10n` 重新產生 Dart 檔。
- **新增 Key 步驟**：在所有 `.arb` 檔加上相同 key，執行 `flutter gen-l10n`，再於畫面使用 `l10n.newKey`。

## Figma MCP 使用
規則由 **`figma-ui` skill** 管理（`.claude/skills/figma-ui/SKILL.md`），使用 `mcp__figma-desktop__*` 工具時自動觸發。
核心原則：Figma 決定「結構」，Theme token 決定「視覺」。**永遠不硬寫** Figma 的顏色 / 字體 / 尺寸 / 字串。
統一取用入口：`context.appTheme.*`（見 `lib/theme/app_theme_extension.dart`）與 `Theme.of(context).colorScheme/textTheme`。

## Current Limitations
- 無測試（只有 skeleton `test/widget_test.dart`）。

## UI & Edge-to-Edge
所有 main entry point 啟動時設定：
```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
SystemChrome.setSystemUIOverlayStyle(...); // status bar & nav bar 透明
```
**Inset 處理三種固定模式：**
- **頂部**：`MediaQuery.of(context).viewPadding.top` — 用於 global header（main_shell.dart）
- **底部按鈕**：`MediaQuery.of(context).padding.bottom` + 加到按鈕 padding — 用於 product_detail、checkout
- **鍵盤彈起**：`MediaQuery.of(context).viewInsets.bottom` — 用於 live 直播留言輸入框

**例外：**
- 直播全螢幕播放時切換為 `SystemUiMode.immersiveSticky`，dispose 時還原 edgeToEdge
- login / register / cart_drawer 用 `SafeArea` widget 處理