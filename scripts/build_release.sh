#!/usr/bin/env bash
# build_release.sh — Builds a release APK/AAB with obfuscation enabled.
#
# Usage:
#   ./scripts/build_release.sh apk     # builds release APK
#   ./scripts/build_release.sh appbundle  # builds release AAB (for Play Store)
#
# Obfuscation flags:
#   --obfuscate                 Obfuscates Dart symbol names in the AOT snapshot
#   --split-debug-info=...      Writes symbol map to build/debug-info/ (keep private)
#
# Prerequisites:
#   - android/key.properties must exist and point to a valid keystore
#   - flutter SDK on PATH

set -euo pipefail

TARGET="${1:-appbundle}"
DEBUG_INFO_DIR="build/debug-info"

mkdir -p "$DEBUG_INFO_DIR"

echo "Building release $TARGET with obfuscation..."
flutter build "$TARGET" \
  --release \
  --obfuscate \
  --split-debug-info="$DEBUG_INFO_DIR"

echo ""
echo "Build complete."
echo "  Debug symbols written to: $DEBUG_INFO_DIR"
echo "  Keep this directory PRIVATE — it is needed to decode crash stack traces."
echo "  DO NOT commit debug-info/ to version control."
