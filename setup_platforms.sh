#!/usr/bin/env bash
set -euo pipefail
if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter SDK is required. Install Flutter first: https://docs.flutter.dev/get-started/install'
  exit 1
fi
flutter create --platforms=android,ios .
flutter pub get
