#!/bin/sh

set -e

# Install Flutter
FLUTTER_VERSION="3.41.4"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Installing Flutter $FLUTTER_VERSION..."
  curl -o flutter.zip https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${FLUTTER_VERSION}-stable.zip
  unzip -q flutter.zip -d "$HOME"
  rm flutter.zip
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo "Flutter version:"
flutter --version

# Get dependencies (generates Generated.xcconfig)
flutter pub get

echo "ci_post_clone done."
