#!/bin/sh
# Xcode Cloud Pre-Build Script for Flutter
# Script location: ci_scripts/ci_pre_xcodebuild.sh (repo root level)
# -> ci_scripts/ -> repo root

set -e

# ── 路徑計算（從 script 位置推算，不依賴 $CI_WORKSPACE）────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "▶ SCRIPT_DIR : $SCRIPT_DIR"
echo "▶ REPO_ROOT  : $REPO_ROOT"
echo "▶ CI_WORKSPACE: $CI_WORKSPACE"

# ── Flutter 版本（與本地開發一致）──────────────────────────────
FLUTTER_VERSION="3.41.4"
FLUTTER_HOME="$HOME/flutter"
export PATH="$FLUTTER_HOME/bin:$PATH"

# ── 安裝 Flutter（版本不符時強制重裝）───────────────────────
INSTALLED_VERSION=""
if [ -f "$FLUTTER_HOME/bin/flutter" ]; then
  INSTALLED_VERSION="$("$FLUTTER_HOME/bin/flutter" --version --machine 2>/dev/null | grep '"frameworkVersion"' | sed 's/.*: *"\([^"]*\)".*/\1/' || echo "")"
fi

if [ "$INSTALLED_VERSION" != "$FLUTTER_VERSION" ]; then
  echo "▶ Flutter version mismatch (installed: $INSTALLED_VERSION, required: $FLUTTER_VERSION). Re-installing ..."
  rm -rf "$FLUTTER_HOME"
  git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    "$FLUTTER_HOME"
else
  echo "▶ Flutter $FLUTTER_VERSION already installed."
fi

echo "▶ Flutter version:"
flutter --version

# ── Flutter precache iOS artifacts（確保 Flutter.xcframework 可用）──
echo "▶ Running flutter precache --ios ..."
flutter precache --ios

# ── CocoaPods（Xcode Cloud 已預裝，確認版本即可）────────────
echo "▶ CocoaPods version: $(pod --version)"

# ── Flutter pub get（產生 Generated.xcconfig）────────────────
echo "▶ Running flutter pub get in $REPO_ROOT ..."
cd "$REPO_ROOT"
flutter pub get

# ── 清空 Pods 舊快取（避免殘留舊 state 導致 integrate 失敗）──
echo "▶ Cleaning old Pods ..."
rm -rf "$REPO_ROOT/ios/Pods" "$REPO_ROOT/ios/Podfile.lock"

# ── Pod install（產生 xcfilelist 等 Pods 相關檔案）───────────
echo "▶ Running pod install in $REPO_ROOT/ios ..."
cd "$REPO_ROOT/ios"
pod install

echo "✅ Pre-build script completed."
