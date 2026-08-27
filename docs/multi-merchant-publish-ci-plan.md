# Multi-Merchant Publishing CI — Implementation Plan

> Plan for a CI that builds & publishes all flavors (`default`, `merchantA/B/C`) to their own
> Play / App Store apps. Generated 2026-06-16. Ground truth verified against the repo.

## 1. TL;DR

Lift the proven single-flavor `android-play-internal.yml` into a **reusable workflow
(`workflow_call`) driven by a committed JSON config + matrix**, so all four flavors publish to
their own Play apps from one source of truth, with `fail-fast: false` so one merchant's rejection
never aborts the others. Adding `merchantD` later becomes a pure data PR. Ship **Android first
(Phase 1, ~half a day)**, then **harden versioning/security (Phase 2)**, then add **iOS TestFlight
(Phase 3)**. The iOS Xcode project is in better shape than first assumed (per-flavor
`Debug-`/`Release-` configs already exist and are wired; `ci_pre_xcodebuild.sh` + 4
`ExportOptions-*.plist` are committed), so iOS is gated mostly on **Apple-account setup +
distribution signing**, not pbxproj surgery — and **Xcode Cloud** is the recommended iOS path.

## 2. Current state & gaps

| Capability | Android | iOS |
|---|---|---|
| Per-flavor build works locally | ✅ 4 flavors, distinct `applicationId` | ✅ `Debug-`/`Release-<flavor>` configs exist & wired; `flutter build ipa --flavor merchantA` resolves `Release-merchantA` |
| Per-flavor *profile* build | ✅ | ❌ `Profile-merchant*` configs MISSING (verified: 0 in pbxproj) → `--profile` falls back to default bundle id |
| Distinct store identity per merchant | ✅ `...merchant_a/b/c` (snake_case) | ⚠️ `...merchantA/B/C` (camelCase) — intentional, must match ASC records exactly |
| CI builds all merchants | ❌ only `default` (single AAB) | ❌ no iOS workflow at all |
| Store upload wired | ✅ `r0adkll/upload-google-play@v1`, one `packageName` | ❌ no upload path |
| Signing for CI/distribution | ⚠️ committed keystore + secrets, but hardcoded fallbacks | ❌ `Automatic` + `Apple Development` (dev cert) — cannot archive for App Store headless |
| Store records exist | ✅ default app | ❌ 3 ASC app records for `...merchantA/B/C` unconfirmed |
| Firebase per-merchant | ✅ `google-services.json` has all 4 package_names | ⚠️ single `GoogleService-Info.plist` covers `default` only (latent; iOS Firebase dormant) |
| Version/build number | ❌ shared `+11` → collides on re-upload | ❌ same shared `+11` (per-bundle-id unique, less acute) |
| Release-eng artifacts present | `android-play-internal.yml` | `ios/ci_scripts/ci_pre_xcodebuild.sh`, `ios/ExportOptions-{default,merchantA,B,C}.plist`; no fastlane |

## 3. Blockers to resolve first (severity-ordered)

| # | Severity | Blocker | Concrete fix |
|---|---|---|---|
| B1 | **CRITICAL (sec)** | Signing keystore `android/xsmartlive-plus-one` committed to git (verified tracked; `.jks`-less name evades `.gitignore`). Signs all 4 apps. | Rotate key, enroll **Play App Signing**, purge from history, store as base64 secret decoded to `RUNNER_TEMP` at build, `rm` in `always()`. Until rotated, treat key as compromised. |
| B2 | **CRITICAL (sec)** | Hardcoded password `50810188` at `android/app/build.gradle.kts` lines 78 & 80 (`storePassword`/`keyPassword` env fallback). | Remove both fallbacks → fail hard when env absent. A fresh clone must fail signing if secrets missing (acceptance test). |
| B3 | **HIGH** | Keystore-path fallback mismatch — line 76 defaults to `"xsmartlive-plus-one.jks"` but committed file is `xsmartlive-plus-one` (no ext). | Set `ANDROID_KEYSTORE_PATH=../xsmartlive-plus-one` in every matrix job's build env. |
| B4 | **HIGH** | `versionCode` collision — shared `11` across flavors; Play rejects re-upload of same code. | CI owns the build number: `--build-number=$((11 + GITHUB_RUN_NUMBER))` on every build. pubspec keeps semver as versionName only. Assert with `aapt2 dump badging`. |
| B5 | **HIGH** | Per-merchant store/SA setup missing — each Play app needs its SA invited; iOS needs 3 ASC records. | Create/confirm 4 Play apps; invite SA(s) per app. ASC: 3 app records + 3 App IDs under team `TS68CZJ93T`. ~30–60 min account work. |
| B6 | **HIGH (sec)** | One keystore + one Play SA shared across all merchants → single leak compromises every brand. | GitHub **Environments per merchant**; ideally per-merchant Play SA scoped to one `packageName`. JSON stores the *secret name*; dispatcher uses `secrets: inherit`. |
| B7 | **HIGH (iOS)** | No distribution signing for iOS CI — all configs `Automatic` + `Apple Development`. | **Recommended: Xcode Cloud** (Apple-managed signing; existing artifacts target it). Else GitHub Actions + fastlane + ASC API key + `match`. |
| B8 | **MED (iOS)** | `Profile-merchant*` configs missing. Does NOT block `flutter build ipa` (uses `Release-<flavor>`). | On a Mac, duplicate `Release-merchant*` → `Profile-merchant*` w/ correct bundle id; register in config lists; point each scheme's `ProfileAction`. |
| B9 | **MED (iOS)** | Pods xcconfig inheritance — Runner per-flavor `baseConfigurationReference` → Flutter's `Debug/Release.xcconfig`, not `Pods-Runner.<config>.xcconfig`. Can break static-Firebase linking on archive. | Re-run `pod install` on a Mac after configs exist (repoints automatically). Validate with real `flutter build ipa --flavor merchantA`. |
| B10 | **MED (iOS)** | Single `GoogleService-Info.plist` covers default only → A/B/C ship default Firebase config. Latent. | Register 3 iOS Firebase apps, per-flavor plists under `ios/config/<flavor>/`, copy-by-bundle-id run-script. Defer until iOS Firebase live. |
| B11 | **MED (sec)** | Actions pinned to mutable tags (`@v2`/`@v1`/`@v4`); no `permissions` cap, no approval gate, no concurrency group on a job holding signing keys. | Pin to commit SHAs + Dependabot; `permissions: contents: read`; per-merchant `concurrency`; reviewer gate on production. |
| B12 | **LOW** | Casing footgun: Android `merchant_a` vs iOS `merchantA` vs Pods `merchanta`. | One source of truth (`.github/release-targets.json`) carrying both `androidPackageName` + `iosBundleId`. Never retype a bundle id. |

## 4. Target architecture

**Shape: reusable workflow + JSON-config-driven matrix + thin dispatcher.**
(Rejected: single inline matrix — hard to publish one merchant alone; 4 separate workflows —
guaranteed drift on every keystore/Flutter fix.)

**Config-as-data — `.github/release-targets.json`** (one entry per flavor):

```json
{
  "merchantA": {
    "flavor": "merchantA",
    "entrypoint": "lib/main_merchant_a.dart",
    "androidPackageName": "com.xsmartlive.plus.one.merchant_a",
    "playServiceAccountSecret": "PLAY_SERVICE_ACCOUNT_JSON_MERCHANT_A",
    "mappingFlavorDir": "merchantARelease",
    "iosBundleId": "com.xsmartlive.plus.one.merchantA",
    "publishAndroid": true,
    "publishIos": false
  }
}
```

- **Secrets can't come from JSON directly.** Store the *secret name* in JSON; dispatcher passes
  `secrets: inherit`; reusable workflow indexes `${{ secrets[inputs.sa_secret_name] }}`. Getting
  this wrong = silent auth-as-nobody → verify first.
- **`mappingFlavorDir` must be flavor-specific** — gradle emits `merchantARelease/mapping.txt`.
  Make `mappingFile` conditional (R8 currently off → may not exist; don't fail upload on missing map).
- **Version contract (both platforms):** `BUILD_NAME` = pubspec semver (marketing only);
  `BUILD_NUMBER = 11 + GITHUB_RUN_NUMBER`. Always pass both `--build-name` and `--build-number`.
- **Dispatch inputs:** boolean-per-merchant checkboxes + `track` + `status` + `release_notes`.
  A `prepare` job converts booleans → JSON matrix array.
- **Triggers:** `workflow_dispatch` for subset selection; `push: tags v*` → every
  `publishAndroid:true` target at internal/draft. Remove the tag trigger from the old workflow to
  avoid double-publishing `default`.
- **`default` policy:** build-only QA or hard-capped to `internal` (it points at UAT). Same UAT
  guard for `merchantA` until its `BASE_URL` leaves `api-uat-1`.

## 5. Phased rollout

### Phase 1 — Android multi-merchant (lowest risk, ~half a day)
- **Add** `.github/release-targets.json` (data only).
- **Add** `.github/workflows/_android-publish.yml` — copy existing job body; swap 5 `env:` constants
  for `workflow_call` inputs; dynamic SA via `secrets[inputs.sa_secret_name]`; flavor-scoped artifact
  name; conditional `mappingFile`.
- **Add** `.github/workflows/release.yml` (dispatcher: `prepare` → `android` matrix, `fail-fast: false`,
  `max-parallel: 2`, `secrets: inherit`).
- **Apply B3** (`ANDROID_KEYSTORE_PATH`) + **B4** (`--build-number` + `aapt2` assert).
- **Smoke test:** dispatch with only `merchant_a=true`, internal/draft.
- **Repoint** `android-play-internal.yml` (remove its `v*` trigger).

### Phase 2 — Versioning & security hardening
- **Edit** `android/app/build.gradle.kts` lines 76/78/79/80 → strip all hardcoded fallbacks (B2).
- **B1:** rotate key, enroll Play App Signing, purge keystore from history, base64 secret + cleanup.
  Enable secret scanning + push protection + gitleaks CI gate.
- **B6/B11:** GitHub Environment per merchant; pin actions to SHAs + Dependabot; `permissions`,
  `concurrency`, reviewer gate on production.
- **Document** version model + bundle-id mapping in `CLAUDE.md`.

### Phase 3 — iOS TestFlight (prereqs can start in parallel with Phase 1)
- **Account prereqs (B5):** 3 ASC app records + 3 App IDs (team `TS68CZJ93T`); TestFlight tester group;
  ASC API key (`.p8`).
- **Project fixes on a Mac (B8, B9):** add `Profile-merchant*`; re-run `pod install`; acceptance =
  `flutter build ipa --flavor merchantA -t lib/main_merchant_a.dart` per flavor.
- **Signing path B7 — choose ONE:**
  - **(A, recommended) Xcode Cloud:** one workflow per scheme, Apple-managed signing, free macOS —
    leverages existing `ci_pre_xcodebuild.sh` + `ExportOptions-*.plist`. No certs, no runner cost.
  - **(B) GitHub Actions `macos-15`:** add `ios/Gemfile` + `ios/fastlane/{Fastfile,Matchfile}`
    (one lane: `match appstore --readonly` + `upload_to_testflight`); flip `ExportOptions` to
    `signingStyle=manual`; matrix filtered on `publishIos==true`.
- **B10 (optional):** per-flavor `GoogleService-Info.plist` — only before enabling iOS Firebase.

## 6. Secrets & prerequisites checklist

**Existing (reused):** `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`,
`PLAY_SERVICE_ACCOUNT_JSON`.

**Android per-merchant (GitHub Environments):** `PLAY_SERVICE_ACCOUNT_JSON_MERCHANT_A/_B/_C` — *or*
point all four JSON entries at the existing `PLAY_SERVICE_ACCOUNT_JSON` if one SA is invited to all 4
apps. (After B1) `ANDROID_KEYSTORE_BASE64` + rotated password secrets.

**iOS (path B / fastlane):** `APP_STORE_CONNECT_API_KEY_ID`, `APP_STORE_CONNECT_API_ISSUER_ID`,
`APP_STORE_CONNECT_API_KEY_P8` (base64), `MATCH_GIT_URL`, `MATCH_PASSWORD`,
`MATCH_GIT_BASIC_AUTHORIZATION`, `KEYCHAIN_PASSWORD`. `DEVELOPMENT_TEAM=TS68CZJ93T` is non-secret.
*Path A (Xcode Cloud) needs none of these.*

**Play Console:** confirm 4 apps; enroll Play App Signing; invite SA(s) per app scoped to testing track.
**App Store Connect:** 3 app records + 3 App IDs for `...merchantA/B/C`; decide if `default` is public.
**Firebase (deferred):** 3 iOS apps → 3 plists.

## 7. Open questions for the owner

1. **Publish `default`?** Real public app or internal QA only? If internal, hard-cap to `internal` track.
2. **Are merchant API URLs still UAT?** `merchantA` `BASE_URL=api-uat-1`, `MERCHANT_ID=1` — reconcile
   before any production push.
3. **One Play service account or per-merchant?** Determines whether you create 3 new SA secrets or
   reuse the existing one.
4. **iOS CI: Xcode Cloud vs GitHub Actions?** Existing artifacts favor Xcode Cloud.
5. **Keystore rotation: now or later?** B1/B2 are CRITICAL — rotate before opening new distribution.
6. **Per-merchant release notes / locales?** App supports 8 locales — per-merchant `whatsnew-<locale>`
   or single uniform note?
7. **Does `default` need an iOS App Store presence**, or only A/B/C ship to iOS?

---

**New files (Phase 1):** `.github/release-targets.json`, `.github/workflows/_android-publish.yml`,
`.github/workflows/release.yml`. **(Phase 3, GHA path only):** `ios/Gemfile`,
`ios/fastlane/{Fastfile,Matchfile}`, `.github/workflows/_ios-publish.yml`.
**Files to change:** `android/app/build.gradle.kts` (strip fallbacks), `android-play-internal.yml`
(remove `v*` trigger), `CLAUDE.md` (version model + bundle-id table).
