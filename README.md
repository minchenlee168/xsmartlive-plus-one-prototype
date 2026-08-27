# xSmartLive Plus One

Flutter 直播購物 White-Label App，支援多商家品牌（Multi-Flavor）與執行期遠端主題（Remote Theme）。

- **版本**：1.1.2+10
- **Flutter SDK**：^3.11.1

## 架構概覽

```
編譯期（Flavor）   → 每個商家獨立 APK/IPA，各自的 appName、appId、baseUrl、App Icon
執行期（Remote Theme） → App 啟動即從 API 取得商家主題，動態套用品牌色彩/字型/圓角
狀態管理          → MVVM + Riverpod（Notifier / AsyncNotifier）
路由              → go_router，未登入自動導向 /login，已登入預設進 /home
本地化            → Flutter 官方 ARB 工作流，支援 8 種語系
```

## 支援 Flavor

| Flavor | App 名稱 | Application ID | Base URL |
|--------|----------|----------------|----------|
| `merchantA` | Brand A Live | `com.xsmartlive.plus.one.merchant_a` | `https://api-uat-1.xsmartlive.com` |
| `merchantB` | Brand B Shop | `com.xsmartlive.plus.one.merchant_b` | `https://api.merchant-b.com` |
| `merchantC` | Brand C Live | `com.xsmartlive.plus.one.merchant_c` | `https://api.merchant-c.com` |

> `merchantB` / `merchantC` 目前為示範用 placeholder URL，需在 `lib/main_merchant_[b|c].dart` 中替換成實際 API 位址。

## 快速開始

### 執行（開發模式）

```bash
# Merchant A
flutter run --flavor merchantA -t lib/main_merchant_a.dart

# Merchant B
flutter run --flavor merchantB -t lib/main_merchant_b.dart

# Merchant C
flutter run --flavor merchantC -t lib/main_merchant_c.dart
```

### Codegen（Freezed / json_serializable / Riverpod）

修改 model 或 provider 後執行：

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 多國語言（i18n）

新增/修改 `.arb` 後重新產生 Dart 檔：

```bash
flutter gen-l10n
```

### 打包 APK

```bash
flutter build apk --flavor merchantA -t lib/main_merchant_a.dart
flutter build apk --flavor merchantB -t lib/main_merchant_b.dart
flutter build apk --flavor merchantC -t lib/main_merchant_c.dart
```

### 打包 iOS（需 macOS + Xcode）

```bash
flutter build ios --flavor merchantA -t lib/main_merchant_a.dart
```

> iOS 需在 Xcode 手動建立 3 個 Scheme（merchantA / merchantB / merchantC），各自對應 `ios/Flutter/MerchantA.xcconfig` 等設定檔。
> CI 採 Xcode Cloud，相關腳本位於 `ios/ci_scripts/`，已內建網路重試容錯機制。

## 登入 / Session

- 使用 Laravel session cookie（`laravel_session`），由 `dio_cookie_manager` + `PersistCookieJar` 自動儲存到磁碟。
- 登入流程：登入 → cookie 寫入 → 進入主畫面。
- 重開 APP：`restoreUser()` 讀取本地快取 user → 呼叫 `mallIsLogin` 驗證 → 成功進入 `/home`；失敗（success: false）則清除快取並導向 `/login`。
- 401 / session 過期統一由 `DioClient` 攔截處理。

詳見 [API_DOCUMENT.json](API_DOCUMENT.json)。

## 專案結構

```
lib/
├── main.dart                  # 預設入口（dev / 共用初始化）
├── main_merchant_a.dart       # Flavor A 入口
├── main_merchant_b.dart       # Flavor B 入口
├── main_merchant_c.dart       # Flavor C 入口
├── app.dart                   # MyApp（MaterialApp.router + Locale + Theme 注入）
│
├── config/
│   ├── flavor_config.dart     # Flavor 編譯期注入（singleton）
│   └── api_constants.dart     # 所有 API endpoint（從 FlavorConfig 組成）
│
├── core/errors/               # AppException sealed class 體系
│
├── data/
│   ├── dio_client.dart        # Dio + CookieManager + 401 攔截
│   ├── session_service.dart   # Session 狀態服務
│   ├── token_storage.dart     # JWT（flutter_secure_storage）
│   ├── theme_cache_storage.dart   # Theme JSON 快取（shared_preferences）
│   └── repositories/
│       ├── address_repository.dart
│       ├── auth_repository.dart
│       ├── bonus_repository.dart
│       ├── cart_repository.dart
│       ├── checkout_repository.dart
│       ├── combo_repository.dart
│       ├── content_repository.dart
│       ├── coupon_repository.dart
│       ├── live_repository.dart
│       ├── market_repository.dart
│       ├── product_repository.dart
│       ├── purchase_repository.dart
│       └── theme_repository.dart
│
├── models/                    # Freezed 資料模型 + mock_data.dart
│
├── theme/
│   ├── remote_theme_model.dart      # Freezed: RemoteThemeModel
│   ├── app_theme_extension.dart     # ThemeExtension + lerp + context.appTheme
│   ├── remote_theme_builder.dart    # RemoteThemeModel → ThemeData
│   ├── remote_theme_notifier.dart   # 快取優先 + 背景更新 + fallback
│   └── theme_state.dart             # Freezed union: initial/loading/cached/loaded/error
│
├── providers/                 # Riverpod providers（auth / theme / locale / live / product / cart / coupon / checkout / profile / notification 等）
├── router/app_router.dart     # go_router + redirect guard
├── l10n/                      # ARB 翻譯檔 + 產生的 Dart 檔
│
├── widgets/                   # 共用 widgets（cart_fly_animation / shop_product_card 等）
│
└── screens/
    ├── home/                  # 首頁
    ├── live/                  # 直播列表 + 直播間（含播放、留言、商品卡）
    ├── shop/                  # 商城（含 product_detail、checkout）
    ├── cart/                  # 購物車
    ├── favorites/             # 收藏
    ├── coupons/               # 優惠券
    ├── notifications/         # 通知
    ├── search/                # 搜尋
    ├── support/               # 客服
    ├── profile/               # 個人中心（orders / settings / 綁定手機 / 改密碼 / 切換語言 / 切換主題）
    ├── login/                 # 登入 / 註冊 / 忘記密碼
    └── main_shell.dart        # 主框架（含底部導航 + global header）
```

## 多國語言 (i18n)

使用 `flutter_localizations` + `intl`，採 Flutter 官方 ARB 工作流。

| Locale | 顯示名稱 | 檔案 |
|--------|----------|------|
| `zh-TW` | 繁體中文（預設） | `app_zh_TW.arb` |
| `zh-CN` | 简体中文 | `app_zh_CN.arb` |
| `zh` | 繁體中文（fallback） | `app_zh.arb` |
| `en` | English | `app_en.arb` |
| `ja` | 日本語 | `app_ja.arb` |
| `ko` | 한국어 | `app_ko.arb` |
| `th` | ภาษาไทย | `app_th.arb` |
| `ms` | Bahasa Malaysia | `app_ms.arb` |

- 設定檔：[l10n.yaml](./l10n.yaml)（template: `app_en.arb`，output: `lib/l10n/app_localizations.dart`）
- 使用者語系存於 `SharedPreferences`（key: `app_locale`），透過 `LocaleNotifier` 管理。
- 使用方式：`final l10n = AppLocalizations.of(context)!;` → `l10n.keyName`

## UI 設計規範

### 背景色

主要頁面（live、shop、cart、favorites、coupons、notifications、search、profile）統一使用灰色底色：

```dart
backgroundColor: const Color(0xFFF3F4F6)  // Tailwind gray-100
```

**例外**：`login` 頁面使用全版漸層背景（`primaryGradient`），不套用灰色底色。

### Edge-to-Edge

所有 main entry point 啟動時設定：

```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
SystemChrome.setSystemUIOverlayStyle(...); // status bar & nav bar 透明
```

Inset 處理三種固定模式：

- **頂部**：`MediaQuery.of(context).viewPadding.top` — 用於 global header（main_shell.dart）
- **底部按鈕**：`MediaQuery.of(context).padding.bottom` + 加到按鈕 padding — 用於 product_detail、checkout
- **鍵盤彈起**：`MediaQuery.of(context).viewInsets.bottom` — 用於 live 直播留言輸入框

例外：

- 直播全螢幕播放時切換為 `SystemUiMode.immersiveSticky`，dispose 時還原 `edgeToEdge`。
- `login` / `register` / `cart_drawer` 使用 `SafeArea` widget 處理。

### 卡片規範

- 背景：`Colors.white`
- 圓角：`BorderRadius.circular(12)`
- 各 item 採獨立 `Card`（非全部塞入同一 Card），配合灰色底色形成層次感
- 陰影：`elevation: 0.5` ~ `2`（依視覺層級決定）

### Header

- 漸層色使用 `appTheme.primaryGradient`（由 Remote Theme 動態決定，fallback 為 purple→pink）
- 顯示：頭像 + 姓名 + VIP badge + email

### Badge / 數量提示

紅色圓角 pill（`Colors.red`，`BorderRadius.circular(10)`），不使用 Flutter 內建 `Badge` widget。直播商品卡的購物車 badge 跟隨主題色。

## Remote Theme 機制

```
App 啟動
  └─▶ ThemeNotifier.build()
        ├─ 1. 讀取 shared_preferences 快取 → 立即顯示舊主題
        └─ 2. 背景呼叫 GET /theme/{merchantId}（無需 auth）
              ├─ 成功 → 寫入快取，更新 ThemeState.loaded
              └─ 失敗 → 保留舊快取 or FlavorConfig.fallbackTheme
```

統一取用入口：`context.appTheme.*`（見 `lib/theme/app_theme_extension.dart`）與 `Theme.of(context).colorScheme / textTheme`。

## Cart 雙系統

- `cartProvider`（`CartNotifier`）：in-memory，UI 快速操作（加減、勾選、動畫）。
- `cartApiProvider`（`CartApiNotifier`）：server-synced，與後端購物車同步。
- `cartCountProvider`：以 server 資料為主，顯示底部導航 badge。

## 依賴清單（核心）

| 套件 | 用途 |
|------|------|
| `flutter_riverpod` + `riverpod_annotation` | 狀態管理 |
| `go_router` | 宣告式路由 |
| `dio` + `dio_cookie_manager` + `cookie_jar` | HTTP client + Laravel session cookie 持久化 |
| `flutter_secure_storage` | 安全儲存（token 等） |
| `shared_preferences` | Theme JSON / Locale 快取 |
| `google_fonts` | 遠端字型（fontFamily 須為 Google Fonts 名稱） |
| `cached_network_image` + `flutter_svg` | 圖片快取 / SVG |
| `freezed_annotation` + `json_annotation` | 不可變資料模型 + JSON 序列化 |
| `video_player` + `chewie` | 直播播放器 |
| `google_sign_in` + `flutter_facebook_auth` + `webview_flutter` | 第三方登入 |
| `flutter_localizations` + `intl` | i18n |
| `package_info_plus` | 取 App 版本（profile footer 用） |

## 靜態分析

```bash
flutter analyze
# No issues found!
```

## API 規格

詳見 [API_DOCUMENT.json](API_DOCUMENT.json)

## 現存限制

- 尚無測試（僅 `test/widget_test.dart` skeleton）。
