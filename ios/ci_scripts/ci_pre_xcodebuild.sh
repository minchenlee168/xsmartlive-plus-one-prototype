#!/bin/sh
# Xcode Cloud Pre-Build Script for Flutter
# Script location: ios/ci_scripts/ci_pre_xcodebuild.sh
# -> ios/ci_scripts/ -> ios/ -> repo root

set -e

# ── 路徑計算（從 script 位置推算，不依賴 $CI_WORKSPACE）────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "▶ SCRIPT_DIR : $SCRIPT_DIR"
echo "▶ REPO_ROOT  : $REPO_ROOT"
echo "▶ CI_WORKSPACE: $CI_WORKSPACE"

# ── 重試包裝：Xcode Cloud 偶發 DNS / 網路抖動，單次失敗不該整個中止 ──
# 用法：retry <次數> <說明> <command...>
retry() {
  attempts="$1"; label="$2"; shift 2
  n=1
  while true; do
    if "$@"; then
      return 0
    fi
    if [ "$n" -ge "$attempts" ]; then
      echo "✗ '$label' 重試 $attempts 次仍失敗。"
      return 1
    fi
    sleep_for=$((n * 10))
    echo "⚠ '$label' 第 $n 次失敗，${sleep_for}s 後重試 ..."
    sleep "$sleep_for"
    n=$((n + 1))
  done
}

# ── 等待外部網路就緒：Flutter 需從 storage.googleapis.com 取 Dart SDK ──
echo "▶ 等待 storage.googleapis.com DNS / 連線就緒 ..."
i=1
while [ "$i" -le 12 ]; do
  if curl -sSf -o /dev/null --max-time 10 https://storage.googleapis.com/ 2>/dev/null; then
    echo "▶ 網路就緒。"
    break
  fi
  echo "⚠ 第 $i 次連線檢查失敗，5s 後重試 ..."
  sleep 5
  i=$((i + 1))
done

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
  retry 3 "git clone flutter" \
    git clone https://github.com/flutter/flutter.git \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    "$FLUTTER_HOME"
else
  echo "▶ Flutter $FLUTTER_VERSION already installed."
fi

# 首次呼叫 flutter 會觸發下載 Dart SDK / engine，最易受網路抖動影響
echo "▶ Flutter version:"
retry 4 "flutter --version (含 Dart SDK 下載)" flutter --version

# ── Flutter precache iOS artifacts（確保 Flutter.xcframework 可用）──
echo "▶ Running flutter precache --ios ..."
retry 4 "flutter precache --ios" flutter precache --ios

# ── CocoaPods（Xcode Cloud 已預裝，確認版本即可）────────────
echo "▶ CocoaPods version: $(pod --version)"

# ── Flutter pub get（產生 Generated.xcconfig）────────────────
echo "▶ Running flutter pub get in $REPO_ROOT ..."
cd "$REPO_ROOT"
retry 4 "flutter pub get" flutter pub get

# ── 清空 Pods 目錄但 *保留* Podfile.lock ─────────────────────
# 重要：Podfile.lock 一定要保留，否則每次 build 會抓「當前最新版」pod，
# 導致內嵌動態 framework 的 MinimumOSVersion 被拉到 SDK 版本，
# TestFlight 上看不到 build（舊 iOS 裝置被過濾）。lock 已 commit 在 git。
echo "▶ Cleaning old Pods (keeping Podfile.lock) ..."
rm -rf "$REPO_ROOT/ios/Pods"

# ── Pod install（依 Podfile.lock 安裝鎖定版本）───────────────
echo "▶ Running pod install in $REPO_ROOT/ios ..."
cd "$REPO_ROOT/ios"
retry 3 "pod install" pod install

echo "✅ Pre-build script completed."
